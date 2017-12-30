/*
   Copyright 2016-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

enum Role {
  case unknown

  case leftParen
  case rightParen
  case leftBrace
  case rightBrace
  case leftSquare
  case rightSquare

  case period
  case comma
  case colon
  case semi
  case equal
  case at
  case amp
  case arrow
  case backtick
  case exclaim
  case question
  case backslash
  case dollar // TODO: pay attention there is a proposal about this
  case doubleQuote
  case lessThan
  case greaterThan
  case hash
  case minus
  case underscore

  case identifierHead
  case identifierBody

  case operatorHead
  case operatorBody
  case dotOperatorHead

  case digit

  case singleLineCommentHead
  case multipleLineCommentHead
  case multipleLineCommentTail

  case space
  case lineFeed
  case carriageReturn
  case eof
}

extension Role {
  static func role(of current: UnicodeScalar, followedBy peek: UnicodeScalar?) -> Role {
    return current.getRole(followedBy: peek)
  }
}

fileprivate extension UnicodeScalar {
  fileprivate func getRole( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    followedBy peek: UnicodeScalar? = nil
  ) -> Role {
    switch self {
    case "\n":
      return .lineFeed
    case "\r":
      return .carriageReturn
    case "(":
      return .leftParen
    case ")":
      return .rightParen
    case "{":
      return .leftBrace
    case "}":
      return .rightBrace
    case "[":
      return .leftSquare
    case "]":
      return .rightSquare
    case ".":
      if peek == "." {
        return .dotOperatorHead
      }
      return .period
    case ",":
      return .comma
    case ":":
      return .colon
    case ";":
      return .semi
    case "=":
      return isOperatorHead(or: .equal, followedBy: peek)
    case "@":
      return .at
    case "&":
      return isOperatorHead(or: .amp, followedBy: peek)
    case "-":
      if let peek = peek {
        switch peek {
        case ">":
          return .arrow
        case "0"..."9":
          return .minus
        default:
          break
        }
      }
      return .operatorHead
    case "`":
      return .backtick
    case "\\":
      return .backslash
    case "$":
      return .dollar
    case "\"":
      return .doubleQuote
    case "!":
      return isOperatorHead(or: .exclaim, followedBy: peek)
    case "?":
      return isOperatorHead(or: .question, followedBy: peek)
    case "<":
      return isOperatorHead(or: .lessThan, followedBy: peek)
    case ">":
      return isOperatorHead(or: .greaterThan, followedBy: peek)
    case "#":
      return .hash
    case "_":
      return isIdentifierHead(or: .underscore, followedBy: peek)
    case "/":
      switch peek {
      case "*"?:
        return .multipleLineCommentHead
      case "/"?:
        return .singleLineCommentHead
      default:
        return .operatorHead
      }
    case "*":
      if peek == "/" {
        return .multipleLineCommentTail
      }
      return .operatorHead
    case "0"..."9":
      return .digit
    default:
      if isSpace {
        return .space
      } else if isIdentifierBody {
        return .identifierBody
      } else if isOperatorBody {
        return .operatorBody
      } else if isOperatorHead {
        return .operatorHead
      } else if isIdentifierHead {
        return .identifierHead
      } else {
        return .unknown
      }
    }
  }

  private func isOperatorHead(or segment: Role, followedBy peek: UnicodeScalar?) -> Role {
    if let peek = peek, peek.isOperatorCharacter {
      return .operatorHead
    }
    return segment
  }

  private func isIdentifierHead(or segment: Role, followedBy peek: UnicodeScalar?) -> Role {
    if let peek = peek, peek.isIdentifierCharacter {
      return .identifierHead
    }
    return segment
  }

  private var isSpace: Bool {
    switch self {
    case " ",
      "\t",
      "\0",
      "\u{000b}",
      "\u{000c}":
      return true
    default:
      return false
    }
  }

  private var isOperatorHead: Bool {
    switch self {
    case "/",
      "=",
      "-",
      "+",
      "!",
      "*",
      "%",
      "<",
      ">",
      "&",
      "|",
      "^",
      "~",
      "?",
      "\u{00A1}"..."\u{00A7}",
      "\u{00A9}",
      "\u{00AB}",
      "\u{00AC}",
      "\u{00AE}",
      "\u{00B0}",
      "\u{00B1}",
      "\u{00B6}",
      "\u{00BB}",
      "\u{00BF}",
      "\u{00D7}",
      "\u{00F7}",
      "\u{2016}",
      "\u{2017}",
      "\u{2020}"..."\u{2027}",
      "\u{2030}"..."\u{203E}",
      "\u{2041}"..."\u{2053}",
      "\u{2055}"..."\u{205E}",
      "\u{2190}"..."\u{23FF}",
      "\u{2500}"..."\u{2775}",
      "\u{2794}"..."\u{2BFF}",
      "\u{2E00}"..."\u{2E7F}",
      "\u{3001}"..."\u{3003}",
      "\u{3008}"..."\u{3030}":
      return true
    default:
      return false
    }
  }

  private var isOperatorBody: Bool {
    switch self {
    case "\u{0300}"..."\u{036F}",
      "\u{1DC0}"..."\u{1DFF}",
      "\u{20D0}"..."\u{20FF}",
      "\u{FE00}"..."\u{FE0F}",
      "\u{FE20}"..."\u{FE2F}",
      "\u{E0100}"..."\u{E01EF}":
      return true
    default:
      return false
    }
  }

  private var isOperatorCharacter: Bool {
    return isOperatorBody || isOperatorHead
  }

  private var isIdentifierHead: Bool {
    switch self {
    case "A"..."Z",
      "a"..."z",
      "_",
      "\u{00A8}",
      "\u{00AA}",
      "\u{00AD}",
      "\u{00AF}",
      "\u{00B2}"..."\u{00B5}",
      "\u{00B7}"..."\u{00BA}",
      "\u{00BC}"..."\u{00BE}",
      "\u{00C0}"..."\u{00D6}",
      "\u{00D8}"..."\u{00F6}",
      "\u{00F8}"..."\u{00FF}",
      "\u{0100}"..."\u{02FF}",
      "\u{0370}"..."\u{167F}",
      "\u{1681}"..."\u{180D}",
      "\u{180F}"..."\u{1DBF}",
      "\u{1E00}"..."\u{1FFF}",
      "\u{200B}"..."\u{200D}",
      "\u{202A}"..."\u{202E}",
      "\u{203F}"..."\u{2040}",
      "\u{2054}",
      "\u{2060}"..."\u{206F}",
      "\u{2070}"..."\u{20CF}",
      "\u{2100}"..."\u{218F}",
      "\u{2460}"..."\u{24FF}",
      "\u{2776}"..."\u{2793}",
      "\u{2C00}"..."\u{2DFF}",
      "\u{2E80}"..."\u{2FFF}",
      "\u{3004}"..."\u{3007}",
      "\u{3021}"..."\u{302F}",
      "\u{3031}"..."\u{303F}",
      "\u{3040}"..."\u{D7FF}",
      "\u{F900}"..."\u{FD3D}",
      "\u{FD40}"..."\u{FDCF}",
      "\u{FDF0}"..."\u{FE1F}",
      "\u{FE30}"..."\u{FE44}",
      "\u{FE47}"..."\u{FFFD}",
      "\u{10000}"..."\u{1FFFD}",
      "\u{20000}"..."\u{2FFFD}",
      "\u{30000}"..."\u{3FFFD}",
      "\u{40000}"..."\u{4FFFD}",
      "\u{50000}"..."\u{5FFFD}",
      "\u{60000}"..."\u{6FFFD}",
      "\u{70000}"..."\u{7FFFD}",
      "\u{80000}"..."\u{8FFFD}",
      "\u{90000}"..."\u{9FFFD}",
      "\u{A0000}"..."\u{AFFFD}",
      "\u{B0000}"..."\u{BFFFD}",
      "\u{C0000}"..."\u{CFFFD}",
      "\u{D0000}"..."\u{DFFFD}",
      "\u{E0000}"..."\u{EFFFD}":
      return true
    default:
      return false
    }
  }

  private var isIdentifierBody: Bool {
    switch self {
    case "0"..."9",
      "\u{0300}"..."\u{036F}",
      "\u{1DC0}"..."\u{1DFF}",
      "\u{20D0}"..."\u{20FF}",
      "\u{FE20}"..."\u{FE2F}":
      return true
    default:
      return false
    }
  }

  private var isIdentifierCharacter: Bool {
    return isIdentifierHead || isIdentifierBody
  }
}

/*-
 * Thie file contains code derived from
 * https://github.com/demmys/treeswift/blob/master/src/Parser/CharacterClassifier.swift
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
