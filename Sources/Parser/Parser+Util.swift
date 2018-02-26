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

import AST
import Source

extension Parser {
  func checkOperatorReservation(againstModifier modifier: DeclarationModifier?, op: Operator) -> Operator? {
    if modifier == .prefix && (op == "&" || op == "<" || op == "?") {
      return nil
    } else if modifier == .infix && op == "?" {
      return nil
    } else if modifier == .postfix && (op == "!" || op == ">" || op == "?") {
      return nil
    } else if modifier == nil && op == "?" {
      return nil
    } else {
      return op
    }
  }

  func isPotentialTrailingClosure() -> Bool {
    return !isWillSetDidSetBlockHead() && !isGetterSetterBlockHead()
  }

  func isWillSetDidSetBlockHead() -> Bool {
    var lookAhead = 1
    while true {
      let aheadToken = _lexer.look(ahead: lookAhead).kind
      switch aheadToken {
      case .willSet, .didSet:
        return true
      case .at:
        if _lexer.look(ahead: lookAhead + 1).kind.isEqual(toKindOf: .dummyIdentifier) {
          lookAhead += 2
        } else {
          return false
        }
      default:
        return false
      }
    }
  }

  func isGetterSetterBlockHead() -> Bool {
    var lookAhead = 1
    while true {
      let aheadToken = _lexer.look(ahead: lookAhead).kind
      switch aheadToken {
      case .get, .set:
        return true
      case .at:
        if _lexer.look(ahead: lookAhead + 1).kind.isEqual(toKindOf: .dummyIdentifier) {
          lookAhead += 2
        } else {
          return false
        }
      case .mutating, .nonmutating:
        lookAhead += 1
      default:
        return false
      }
    }
  }

  func testAmp() -> Bool {
    switch _lexer.look().kind {
    case .binaryOperator("&"):
      _lexer.advance()
      return true
    case .postfixOperator("&"):
      _lexer.advance()
      return true
    default:
      return false
    }
  }

  func splitTrailingExclaimsAndQuestions() -> [String] {
    // TODO: this is a hacking solution, need some serious refactorings
    guard case .postfixOperator(let puncs) = _lexer.look().kind else {
      return []
    }
    return splitExclaimsAndQuestions(puncs: puncs)
  }

  func splitNextExclaimsAndQuestions() -> [String] {
    // TODO: this is a hacking solution, need some serious refactorings
    switch _lexer.look().kind {
    case .postfixOperator(let puncs):
      return splitExclaimsAndQuestions(puncs: puncs)
    case .binaryOperator(let puncs):
      return splitExclaimsAndQuestions(puncs: puncs)
    case .prefixOperator(let puncs):
      return splitExclaimsAndQuestions(puncs: puncs)
    default:
      return []
    }
  }

  fileprivate func splitExclaimsAndQuestions(puncs: String) -> [String] {
    var ops = [String]()
    for p in puncs {
      if p == "!" {
        ops.append("!")
      } else if p == "?" {
        ops.append("?")
      } else {
        return []
      }
    }
    _lexer.advance()
    return ops
  }

  func splitDoubleRawToTwoIntegers(_ raw: String) -> (Int, Int)? {
    let versionComponents = raw.components(separatedBy: ".")
    guard versionComponents.count == 2,
      let first = Int(versionComponents[0]),
      let second = Int(versionComponents[1])
    else {
      return nil
    }
    return (first, second)
  }

  func removeTrailingSemicolons() {
    // TODO: this method is good, but I feel its applications to container declarations are
    //       sort of a quick fix for issues/61, should think about a more general solution
    while _lexer.match(.semicolon) {}
  }

  func getLookedRange() -> SourceRange {
    return _lexer.look().sourceRange
  }

  func getStartLocation() -> SourceLocation {
    return getLookedRange().start
  }

  func getEndLocation() -> SourceLocation {
    return getLookedRange().end
  }
}

extension SourceLocation {
  var nextColumn: SourceLocation {
    return SourceLocation(identifier: identifier, line: line, column: column + 1)
  }
}

extension String {
  var containOnlyPositiveDecimals: Bool {
    for c in self {
      switch c {
      case "0"..."9":
        continue
      default:
        return false
      }
    }

    return true
  }
}
