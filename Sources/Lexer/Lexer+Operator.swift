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

extension Lexer /* operator */ {
  func lexReservedOperator(prev: Role) -> Token.Kind {
    let opString = char.string
    let operatorRole = char.role
    _consume(operatorRole)
    let operatorKind = opString.toOperator(following: prev, followed: char.role)
    switch (operatorRole, operatorKind) {
    case (.lessThan, .prefixOperator):
      return .leftChevron
    case (.greaterThan, .postfixOperator):
      return .rightChevron
    case (.amp, .prefixOperator):
      return .prefixAmp
    case (.question, .prefixOperator):
      return .prefixQuestion
    case (.question, .binaryOperator):
      return .binaryQuestion
    case (.question, .postfixOperator):
      return .postfixQuestion
    case (.exclaim, .postfixOperator):
      return .postfixExclaim
    default:
      return operatorKind
    }
  }

  func lexOperator(prev: Role, enableDotOperator: Bool = false) -> Token.Kind {
    var opString = ""

    repeat {
      opString.append(char.string)
      _consume(char.role)
    } while char.shouldContinue(enableDotOperator: enableDotOperator)

    return opString.toOperator(following: prev, followed: char.role)
  }
}

fileprivate extension Char {
  fileprivate func shouldContinue(enableDotOperator: Bool) -> Bool {
    if self == .eof {
      return false
    }
    switch self.role {
    case .operatorHead, .operatorBody, .lessThan, .greaterThan,
      .amp, .question, .exclaim, .equal, .arrow, .minus,
      .singleLineCommentHead, .multipleLineCommentHead, .multipleLineCommentTail,
      .dotOperatorHead where enableDotOperator,
      .period where enableDotOperator:
      return true
    default:
      return false
    }
  }
}

fileprivate extension String {
  fileprivate func toOperator(following head: Role, followed tail: Role) -> Token.Kind {
    let headSeparated = head.isHeadSeparator
    let tailSeparated = tail.isTailSeparator
    if tail == .eof && !headSeparated {
      return .postfixOperator(self)
    } else if headSeparated && !tailSeparated {
      return .prefixOperator(self)
    } else if !headSeparated && tailSeparated {
      return .postfixOperator(self)
    } else if !headSeparated && (self == "?" || self == "!") {
      return .postfixOperator(self)
    } else {
      return .binaryOperator(self)
    }
  }
}
