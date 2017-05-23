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
import Source

extension Parser {
  func checkOperatorReservation(
    againstModifier modifier: DeclarationModifier?, op: Operator
  ) -> Operator? {
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
        if _lexer.look(ahead: lookAhead + 1).kind
          .isEqual(toKindOf: .dummyIdentifier)
        {
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
        if _lexer.look(ahead: lookAhead + 1).kind
          .isEqual(toKindOf: .dummyIdentifier)
        {
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

  func splitTrailingExlaimsAndQuestions() -> [String] { // TODO: this is a hacking solution, need some serious refactorings
    if case .postfixOperator(let puncs) = _lexer.look().kind {
      var allQnE = true
      var ops = [String]()
      for p in puncs.characters {
        if p == "!" {
          ops.append("!")
        } else if p == "?" {
          ops.append("?")
        } else {
          allQnE = false
          break
        }
      }

      if allQnE {
        _lexer.advance()
        return ops
      }
    }

    return []
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
    return SourceLocation(path: path, line: line, column: column + 1)
  }
}

extension String {
  var containOnlyPositiveDecimals: Bool {
    for c in characters {
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
