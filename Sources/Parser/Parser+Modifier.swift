/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
  func parseModifiers() -> [DeclarationModifier] {
    var modifiers: [DeclarationModifier] = []
    while let modifier = parseModifier() {
      modifiers.append(modifier)
    }
    return modifiers
  }

  func parseModifier() -> DeclarationModifier? {
    if let accessLevelModifier = parseAccessLevelModifier() {
      return .accessLevel(accessLevelModifier)
    } else if let mutationModifier = parseMutationModifier() {
      return .mutation(mutationModifier)
    }

    switch _lexer.read(Token.Kind.declarationModifiers) {
    case .class:
      return .class
    case .convenience:
      return .convenience
    case .dynamic:
      return .dynamic
    case .final:
      return .final
    case .infix:
      return .infix
    case .lazy:
      return .lazy
    case .optional:
      return .optional
    case .override:
      return .override
    case .postfix:
      return .postfix
    case .prefix:
      return .prefix
    case .required:
      return .required
    case .static:
      return .static
    case .unowned:
      guard _lexer.match(.leftParen) else {
        return .unowned
      }

      switch _lexer.read([.safe, .unsafe]) {
      case .safe:
        guard _lexer.match(.rightParen) else { return nil }
        return .unownedSafe
      case .unsafe:
        guard _lexer.match(.rightParen) else { return nil }
        return .unownedUnsafe
      default:
        return nil
      }
    case .weak:
      return .weak
    default:
      return nil
    }
  }

  func parseMutationModifier() -> MutationModifier? {
    switch _lexer.read(Token.Kind.mutationModifiers) {
    case .mutating:
      return .mutating
    case .nonmutating:
      return .nonmutating
    default:
      return nil
    }
  }

  func parseAccessLevelModifier() -> AccessLevelModifier? {
    func isSetKeyword() -> Bool {
      guard _lexer.match(.leftParen) else { return false }
      guard _lexer.match(.set) else { return false }
      guard _lexer.match(.rightParen) else { return false }

      return true
    }

    switch _lexer.read(Token.Kind.accessLevelModifiers) {
    case .private:
      return isSetKeyword() ? .privateSet : .private
    case .fileprivate:
      return isSetKeyword() ? .fileprivateSet : .fileprivate
    case .internal:
      return isSetKeyword() ? .internalSet : .internal
    case .public:
      return isSetKeyword() ? .publicSet : .public
    case .open:
      return isSetKeyword() ? .openSet : .open
    default:
      return nil
    }
  }
}
