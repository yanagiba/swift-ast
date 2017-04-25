/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
  public func lexStringLiteral() -> Token.Kind {
    var literal = ""
    var rawRepresentation = "\""

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

    while char != .eof {
      appendRaw()

      switch char.role {
      case .lineFeed, .carriageReturn: // multi-line string literal is not supported
        return .invalid(.badChar)
      case .doubleQuote: // end of a static string literal
        consumeChar()
        return .staticStringLiteral(
          literal, rawRepresentation: rawRepresentation)
      case .backslash: // escaping
        consumeChar()

        appendRaw()
        switch char.unicodeScalar {
        case "(": // head of an interpolated string literal
          consumeChar()
          return .interpolatedStringLiteralHead(
            literal, rawRepresentation: rawRepresentation)
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
          literal.append(char.string)
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
