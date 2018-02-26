/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

extension Lexer /* string literal */ {
  public func lexStringLiteral( /*
    swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    */
    isMultiline: Bool = false,
    postponeCaliberation: Bool = false
  ) -> Token.Kind {
    var literal = ""
    var rawRepresentation = isMultiline ? "\"\"\"" : "\""

    func appendRaw() {
      rawRepresentation += char.string
    }

    func consumeChar() {
      _consume(char.role)
    }

    func lexUnicodeLiteral() -> UnicodeScalar? {
      appendRaw()
      guard char.role == .leftBrace else {
        return nil
      }
      var hex = 0
      consumeChar()

      while char != .eof {
        appendRaw()
        let unicodeScalar = char.unicodeScalar
        switch unicodeScalar {
        case "0"..."9", "a"..."f", "A"..."F":
          guard let unicodeHex = unicodeScalar.hex else {
            return nil
          }
          hex = hex * 16 + unicodeHex
          consumeChar()
        case "}":
          return UnicodeScalar(hex)
        default:
          return nil
        }
      }
      return nil
    }

    func isLastRawCharEscaping() -> Bool {
      var rawRepresentationLines = rawRepresentation.components(separatedBy: .newlines)
      rawRepresentationLines.removeLast()
      let lastRawContentLine = rawRepresentationLines.removeLast()
      let lastRawChar = lastRawContentLine.reversed().drop(while: { $0 == " " || $0 == "\t" }).first
      return lastRawChar == "\\"
    }

    func caliberateMultlineStringLiteral() -> Token.Kind {
      if isLastRawCharEscaping() {
        return .invalid(.newlineEscapesNotAllowedOnLastLine)
      }

      var lines = literal.components(separatedBy: .newlines)
      let indentationPrefix = lines.removeLast()
      guard indentationPrefix.filter({ $0 != " " && $0 != "\t"}).isEmpty else {
        return .invalid(.newLineExpectedAtTheClosingOfMultilineStringLiteral)
      }
      if lines.isEmpty {
        return .staticStringLiteral("", rawRepresentation: rawRepresentation)
      }
      let indentationLength = indentationPrefix.count
      var caliberatedLines: [String] = []
      for origLine in lines {
        if origLine.isEmpty {
          caliberatedLines.append(origLine)
          continue
        }
        guard origLine.hasPrefix(indentationPrefix) else {
          return .invalid(.insufficientIndentationOfLineInMultilineStringLiteral)
        }
        let startIndex = origLine.index(origLine.startIndex, offsetBy: indentationLength)
        let caliberatedLine = origLine[startIndex...]
        caliberatedLines.append(String(caliberatedLine))
      }
      let caliberatedLiteral = caliberatedLines.joined(separator: "\n")
      return .staticStringLiteral(caliberatedLiteral, rawRepresentation: rawRepresentation)
    }

    if isMultiline && !postponeCaliberation {
      guard char.role == .lineFeed else {
        return .invalid(.newLineExpectedAtTheBeinningOfMultilineStringLiteral)
      }
      appendRaw()
      consumeChar()
    }

    while char != .eof {
      appendRaw()

      switch char.role {
      case .lineFeed:
        guard isMultiline else {
          return .invalid(.badChar)
        }
        literal.append("\n" as Character)
      case .carriageReturn:
        guard isMultiline else {
          return .invalid(.badChar)
        }
        literal.append("\r" as Character)
      case .doubleQuote:
        if isMultiline {
          if _scanner.peek() == "\"" { // see next one is a double quote
            consumeChar() // consumes the first double quote
            appendRaw() // add second double quote to rawRepresentation
            if _scanner.peek() == "\"" { // see if next one is still a double quote
              consumeChar() // consumes the second double quote
              appendRaw() // add third double quote to rawRepresentation
              consumeChar() // consume the third double quote

              if postponeCaliberation {
                return .staticStringLiteral(literal, rawRepresentation: rawRepresentation)
              }

              return caliberateMultlineStringLiteral()
            } else {
              literal.append("\"" as Character)
              literal.append("\"" as Character)
            }
          } else {
            literal.append("\"" as Character)
          }
        } else {
          consumeChar()
          return .staticStringLiteral(literal, rawRepresentation: rawRepresentation)
        }
      case .backslash: // escaping
        consumeChar()

        appendRaw()
        switch char.unicodeScalar {
        case "(": // head of an interpolated string literal
          consumeChar()
          return .interpolatedStringLiteralHead(literal, rawRepresentation: rawRepresentation)
        case "0":
          literal.append("\0" as Character)
        case "\\":
          literal.append("\\" as Character)
        case "t":
          literal.append("\t" as Character)
        case "n":
          literal.append("\n" as Character)
        case "r":
          literal.append("\r" as Character)
        case "\"":
          literal.append("\"" as Character)
        case "'":
          literal.append("\'" as Character)
        case "u": // unicode
          consumeChar()
          guard let unicodeLiteral = lexUnicodeLiteral() else {
            return .invalid(.unicodeLiteralExpected)
          }
          literal.append(unicodeLiteral.string)
        default:
          while char.role == .space {
            consumeChar()
            appendRaw()
          }
          guard char.role == .lineFeed else {
            return .invalid(.invalidEscapeSequenceInStringLiteral)
          }
          guard isMultiline else {
            return .invalid(.newlineEscapesNotSupportedInStringLiteral)
          }
        }
      default: // just append the current unicode scalar to the string
        literal.append(char.string)
      }

      consumeChar()
    }

    return .invalid(.unexpectedEndOfFile)
  }
}

/*-
 * Thie file contains code derived from
 * https://github.com/demmys/treeswift/blob/master/src/Parser/StringLiteralComposer.swift
 * with the following license:
 *
 * BSD 2-clause "Simplified" License
 *
 * Copyright (c) 2014, Atsuki Demizu
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
