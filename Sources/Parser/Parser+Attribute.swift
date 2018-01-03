/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

import AST
import Lexer

extension Parser {
  func parseAttributes() throws -> Attributes {
    var attrs: Attributes = []
    while _lexer.match(.at) {
      let attr = try parseAttribute()
      attrs.append(attr)
    }
    return attrs
  }

  private func parseAttribute() throws -> Attribute {
    guard case let .identifier(id, backticked) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.missingAttributeName)
    }
    let name: Identifier = backticked ? .backtickedName(id) : .name(id)
    let leftParenCp = _lexer.checkPoint()
    guard _lexer.matchUnicodeScalar("(", immediateFollow: true) else {
      return Attribute(name: name)
    }
    let balancedTokens = parseBalancedTokens(expectedClosingCharacter: ")")
    var argumentClause: Attribute.ArgumentClause?
    if _lexer.match([.arrow, .throws, .rethrows]) {
      // when the balanced tokens are followed by
      // an arrow `->`, a `throws`, or a `rethrows`,
      // it could be the function type's argument clause
      _lexer.restore(fromCheckpoint: leftParenCp)
    } else {
      argumentClause = Attribute.ArgumentClause(balancedTokens: balancedTokens)
    }
    return Attribute(name: name, argumentClause: argumentClause)
  }

  private func parseBalancedTokens(
    expectedClosingCharacter: UnicodeScalar
  ) -> [Attribute.ArgumentClause.BalancedToken] {
    var tokens: [Attribute.ArgumentClause.BalancedToken] = []
    var str = ""

    func appendStringToken() {
      if !str.isEmpty {
        tokens.append(.token(str))
      }
      str = ""
    }

    while let look = _lexer.lookUnicodeScalar() {
      _lexer.advanceChar()

      if look == expectedClosingCharacter {
        appendStringToken()
        break
      } else if look == "(" {
        appendStringToken()
        let parenTokens = parseBalancedTokens(expectedClosingCharacter: ")")
        tokens.append(.parenthesis(parenTokens))
      } else if look == "[" {
        appendStringToken()
        let parenTokens = parseBalancedTokens(expectedClosingCharacter: "]")
        tokens.append(.square(parenTokens))
      } else if look == "{" {
        appendStringToken()
        let parenTokens = parseBalancedTokens(expectedClosingCharacter: "}")
        tokens.append(.brace(parenTokens))
      } else {
        str.append(String(look))
      }
    }
    return tokens
  }
}
