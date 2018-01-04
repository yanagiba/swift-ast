/*
   Copyright 2015-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

import Foundation
import Source

public class Lexer {
  private let _source: SourceFile
  let _scanner: Scanner
  var char: Char {
    return _scanner.scan()
  }

  var _loadedTokens: [Token]
  var _checkpoints: [String: [Token]]
  private var _consumedRoles: [Role]
  var _prevRole: Role {
    return _consumedRoles.last ?? .lineFeed
  }
  private var _exprevRole: Role {
    let exIdx = _consumedRoles.endIndex - 2
    if exIdx >= 0 {
      return _consumedRoles[exIdx]
    }
    return .lineFeed
  }

  public var comments = CommentSet()

  public init(source: SourceFile) {
    _source = source
    _scanner = Scanner(content: source.content)
    _loadedTokens = []
    _consumedRoles = []
    _checkpoints = [:]
  }

  func _consume(_ consumed: Role? = nil, andAdvanceScannerBy numerOfUnicodeScalar: Int = 1) {
    if let consumed = consumed {
      _consumedRoles.append(consumed)
    }
    _scanner.advance(by: numerOfUnicodeScalar)
  }

  public func _getCurrentLocation() -> SourceLocation {
    return SourceLocation(identifier: _source.identifier, line: _scanner.line, column: _scanner.column)
  }

  public func matchUnicodeScalar( /*
    swift-lint:rule_configure(CYCLOMATIC_COMPLEXITY=19)
    swift-lint:suppress(high_ncss)
    */
    _ startingCharacter: UnicodeScalar,
    splitOperator: Bool = true,
    immediateFollow: Bool = false
  ) -> Bool {
    let looked = look()
    let startStr = String(startingCharacter)

    func consumeTokenAndAdvance() -> Bool {
      advance()
      return true
    }

    func consumeOperatorToken(_ p: String, newToken: (String) -> Token.Kind) -> Bool {
      if p == startStr {
        return consumeTokenAndAdvance()
      } else if p.hasPrefix(startStr) && splitOperator {
        let newOperator = String(p[p.index(after: p.startIndex)...])
        let newKind = newToken(newOperator)
        let oldStart = looked.sourceRange.start
        let newStart = SourceLocation(
          identifier: oldStart.identifier, line: oldStart.line, column: oldStart.column + 1)
        let newRange = SourceRange(start: newStart, end: looked.sourceRange.end)
        _loadedTokens[0] = Token(kind: newKind, sourceRange: newRange, roles: [])
        return true
      } else {
        return false
      }
    }

    if immediateFollow && !looked.roles.filter({ $0 == .space || $0 == .lineFeed }).isEmpty {
      return false
    }

    switch looked.kind {
    case .leftParen where startStr == "(":
      return consumeTokenAndAdvance()
    case .rightParen where startStr == ")":
      return consumeTokenAndAdvance()
    case .rightChevron where startingCharacter == ">":
      return consumeTokenAndAdvance()
    case .leftChevron where startingCharacter == "<":
      return consumeTokenAndAdvance()
    case .prefixAmp where startingCharacter == "&":
      return consumeTokenAndAdvance()
    case .postfixExclaim where startingCharacter == "!":
      return consumeTokenAndAdvance()
    case .prefixQuestion where startingCharacter == "?":
      return consumeTokenAndAdvance()
    case .binaryQuestion where startingCharacter == "?":
      return consumeTokenAndAdvance()
    case .postfixQuestion where startingCharacter == "?":
      return consumeTokenAndAdvance()
    case .prefixOperator(let p):
      return consumeOperatorToken(p) { .prefixOperator($0) }
    case .binaryOperator(let p):
      return consumeOperatorToken(p) { .binaryOperator($0) }
    case .postfixOperator(let p):
      return consumeOperatorToken(p) { .postfixOperator($0) }
    default:
      break
    }

    return false
  }

  public func match(_ kinds: [Token.Kind], exactMatch: Bool = false) -> Bool {
    return examine(kinds, exactMatch: exactMatch).0
  }

  public func match(_ kind: Token.Kind, exactMatch: Bool = false) -> Bool {
    return match([kind], exactMatch: exactMatch)
  }

  public func read(_ kinds: [Token.Kind], exactMatch: Bool = false) -> Token.Kind {
    return examine(kinds, exactMatch: exactMatch).1
  }

  public func read(_ kind: Token.Kind, exactMatch: Bool = false) -> Token.Kind {
    return read([kind], exactMatch: exactMatch)
  }

  public func readNext(_ kinds: [Token.Kind], exactMatch: Bool = false) -> Token.Kind {
    return examine(kinds, next: true, exactMatch: exactMatch).1
  }

  public func readNext(_ kind: Token.Kind, exactMatch: Bool = false) -> Token.Kind {
    return readNext([kind], exactMatch: exactMatch)
  }

  public func examine(
    _ kinds: [Token.Kind], next: Bool = false, exactMatch: Bool = false
  ) -> (Bool, Token.Kind) {
    let lookOffset = next ? 1 : 0
    let skipLineFeed = !kinds.contains(.lineFeed)
    let tokenKind = look(ahead: lookOffset, skipLineFeed: skipLineFeed).kind
    if kinds.filter({
      (exactMatch && tokenKind == $0) || // use isEqual(to:) for exact examination
      (!exactMatch && tokenKind.isEqual(toKindOf: $0)) // use isEqual(toKindOf:) otherwise
    }).isEmpty {
      return (false, tokenKind)
    }
    advance(by: lookOffset + 1, skipLineFeed: skipLineFeed)
    return (true, tokenKind)
  }

  public func lookUnicodeScalar() -> UnicodeScalar? {
    let looked = _scanner.scan()
    return looked == .eof ? nil : looked.unicodeScalar
  }

  public func lookLineFeed() -> Bool {
    return look(skipLineFeed: false).kind == .lineFeed
  }

  public func look(ahead: Int = 0, skipLineFeed: Bool = true) -> Token {
    var offset = ahead
    if offset >= _loadedTokens.count {
      for _ in (_loadedTokens.count-1)..<offset {
        _loadedTokens.append(lex())
      }
    }

    guard skipLineFeed else {
      return _loadedTokens[offset]
    }

    var i = 0
    while (i < offset) {
      if _loadedTokens[i].kind == .lineFeed {
        offset += 1
        if offset >= _loadedTokens.count {
          _loadedTokens.append(lex())
        }
      }
      i += 1
    }

    let token = _loadedTokens[offset]
    if token.kind == .lineFeed {
      return look(ahead: offset + 1, skipLineFeed: false)
    }
    return token
  }

  public func advanceChar() {
    _consume()
  }

  public func advance(by tokenCount: Int = 1, skipLineFeed: Bool = true) {
    guard tokenCount > 0 else {
      return
    }
    let first = _loadedTokens.removeFirst()
    if skipLineFeed && first.kind == .lineFeed {
      advance(by: tokenCount, skipLineFeed: skipLineFeed)
    } else {
      advance(by: tokenCount - 1, skipLineFeed: skipLineFeed)
    }
  }

  func lex(previousRoles: [Role] = []) -> Token { // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    var location = _getCurrentLocation()
    var loadedRoles = previousRoles
    let head = char.role

    func appendHead() {
      loadedRoles += [head]
    }

    func produce(_ kind: Token.Kind) -> Token {
      let range = SourceRange(start: location, end: _getCurrentLocation())
      return Token(kind: kind, sourceRange: range, roles: loadedRoles)
    }

    func consumeAndProduce(_ kind: Token.Kind) -> Token {
      _consume(head)
      return produce(kind)
    }

    switch head {
    case .arrow:
      appendHead()
      _consume(head, andAdvanceScannerBy: 2)
      return produce(.arrow)
    /////////////////////////////////////////////////////////////
    case .lessThan, .greaterThan, .amp, .question, .exclaim:
      return produce(lexReservedOperator(prev: _prevRole))
    case .operatorHead:
      return produce(lexOperator(prev: _prevRole))
    case .dotOperatorHead:
      guard _scanner.peek() == "." else {
        return produce(.invalid(.dotOperatorRequiresTwoDots)) // TODO: which is not always true
      }
      return produce(lexOperator(prev: _prevRole, enableDotOperator: true))
    case .dollar:
      _consume(.dollar)
      return produce(lexImplicitParameterName())
    case .backtick:
      _consume(.backtick)
      return produce(lexBacktickIdentifier())
    case .minus:
      if _prevRole.isHeadSeparator {
        return produce(lexNumericLiteral())
      }
      return produce(lexOperator(prev: _prevRole))
    case .digit:
      return produce(lexNumericLiteral())
    case .doubleQuote:
      _consume(.doubleQuote)
      if char.role == .doubleQuote && _scanner.peek() == "\"" {
        _consume(andAdvanceScannerBy: 2)
        return produce(lexStringLiteral(isMultiline: true))
      }
      return produce(lexStringLiteral())
    case .identifierHead:
      return produce(lexIdentifierOrKeyword())
    /////////////////////////////////////////////////////////////
    case .singleLineCommentHead:
      _consume(andAdvanceScannerBy: 2)
      return lexSingleLineComment(startLocation: location)
    case .multipleLineCommentHead:
      _consume(andAdvanceScannerBy: 2)
      return lexMultipleLineComment(startLocation: location)
    case .multipleLineCommentTail:
      _consume(andAdvanceScannerBy: 2)
      return produce(.invalid(.reserved))
    /////////////////////////////////////////////////////////////
    case .carriageReturn:
      _consume()
      return lex(previousRoles: loadedRoles)
    case .lineFeed:
      if _prevRole == .lineFeed || (_prevRole == .space && _exprevRole == .lineFeed) {
        repeat {
          loadedRoles += [char.role]
          _consume()
        } while char.role == .lineFeed
        return lex(previousRoles: loadedRoles)
      }
      appendHead()
      return consumeAndProduce(.lineFeed)
    case .space:
      if _prevRole == .space {
        repeat {
          loadedRoles += [char.role]
          _consume()
        } while char.role == .space
        return lex(previousRoles: loadedRoles)
      }
      appendHead()
      _consume(head)
      return lex(previousRoles: loadedRoles)
    case .eof:
      appendHead()
      return produce(.eof)
    /////////////////////////////////////////////////////////////
    default:
      if let kind = roleTokenKindMapping[head] {
        return consumeAndProduce(kind)
      }

      _consume()
      return produce(.invalid(.badChar))
    }
  }
}

fileprivate let roleTokenKindMapping: [Role: Token.Kind] = [
  .leftParen: .leftParen,
  .rightParen: .rightParen,
  .leftBrace: .leftBrace,
  .rightBrace: .rightBrace,
  .leftSquare: .leftSquare,
  .rightSquare: .rightSquare,
  .equal: .assignmentOperator,
  .at: .at,
  .hash: .hash,
  .backslash: .backslash,
  .colon: .colon,
  .comma: .comma,
  .period: .dot,
  .semi: .semicolon,
  .underscore: .underscore,
]

/*-
 * Thie file contains code derived from
 * https://github.com/demmys/treeswift/blob/master/src/Parser/TokenStream.swift
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
