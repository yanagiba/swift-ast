/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import XCTest

@testable import AST
@testable import Sema

class SequenceExpressionFoldingTests: XCTestCase {
  // These tests focus on the folding logic, check out SemaIntegrationTests
  // for testing where to perform the folding.

  func testBitwiseShiftHigherThanMultiplication() {
    semaSeqExprFoldingAndTest("1*a<<2", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let multiBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1*a<<2`.")
        return
      }
      XCTAssertEqual(multiBiOpExpr.sourceRange, getRange(1, 1, 1, 7))
      XCTAssertEqual(multiBiOpExpr.binaryOperator, "*")
      XCTAssertTrue(multiBiOpExpr.leftExpression is LiteralExpression)
      guard let shiftBiOpExpr = multiBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a<<2`.")
        return
      }
      XCTAssertEqual(shiftBiOpExpr.sourceRange, getRange(1, 3, 1, 7))
      XCTAssertEqual(shiftBiOpExpr.binaryOperator, "<<")
      XCTAssertTrue(shiftBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(shiftBiOpExpr.rightExpression is LiteralExpression)
    })
  }

  func testMultiplicationHigherThanAddition() { // swift-lint:suppress(high_ncss)
    semaSeqExprFoldingAndTest("1+a*2", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let addBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1+a*2`.")
        return
      }
      XCTAssertEqual(addBiOpExpr.sourceRange, getRange(1, 1, 1, 6))
      XCTAssertEqual(addBiOpExpr.binaryOperator, "+")
      XCTAssertTrue(addBiOpExpr.leftExpression is LiteralExpression)
      guard let multiBiOpExpr = addBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a*2`.")
        return
      }
      XCTAssertEqual(multiBiOpExpr.sourceRange, getRange(1, 3, 1, 6))
      XCTAssertEqual(multiBiOpExpr.binaryOperator, "*")
      XCTAssertTrue(multiBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(multiBiOpExpr.rightExpression is LiteralExpression)
    })

    semaSeqExprFoldingAndTest("a/1-b", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let minusBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a/1-b`.")
        return
      }
      XCTAssertEqual(minusBiOpExpr.sourceRange, getRange(1, 1, 1, 6))
      XCTAssertEqual(minusBiOpExpr.binaryOperator, "-")
      XCTAssertTrue(minusBiOpExpr.rightExpression is IdentifierExpression)
      guard let divBiOpExpr = minusBiOpExpr.leftExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a/1`.")
        return
      }
      XCTAssertEqual(divBiOpExpr.sourceRange, getRange(1, 1, 1, 4))
      XCTAssertEqual(divBiOpExpr.binaryOperator, "/")
      XCTAssertTrue(divBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(divBiOpExpr.rightExpression is LiteralExpression)
    })

    semaSeqExprFoldingAndTest("a&+1%b&-2", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 7)
    }, testFolded: { expr in
      guard let outerAddBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a&+1%b&-2`.")
        return
      }
      XCTAssertEqual(outerAddBiOpExpr.sourceRange, getRange(1, 1, 1, 10))
      XCTAssertEqual(outerAddBiOpExpr.binaryOperator, "&-")
      XCTAssertTrue(outerAddBiOpExpr.rightExpression is LiteralExpression)
      guard let innerAddBiOpExpr = outerAddBiOpExpr.leftExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a&+1%b`.")
        return
      }
      XCTAssertEqual(innerAddBiOpExpr.sourceRange, getRange(1, 1, 1, 7))
      XCTAssertEqual(innerAddBiOpExpr.binaryOperator, "&+")
      XCTAssertTrue(innerAddBiOpExpr.leftExpression is IdentifierExpression)
      guard let multiBiOpExpr = innerAddBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1%b`.")
        return
      }
      XCTAssertEqual(multiBiOpExpr.sourceRange, getRange(1, 4, 1, 7))
      XCTAssertEqual(multiBiOpExpr.binaryOperator, "%")
      XCTAssertTrue(multiBiOpExpr.leftExpression is LiteralExpression)
      XCTAssertTrue(multiBiOpExpr.rightExpression is IdentifierExpression)
    })

    semaSeqExprFoldingAndTest("1/a^2/b", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 7)
    }, testFolded: { expr in
      guard let minusBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1/a^2/b`.")
        return
      }
      XCTAssertEqual(minusBiOpExpr.sourceRange, getRange(1, 1, 1, 8))
      XCTAssertEqual(minusBiOpExpr.binaryOperator, "^")
      guard let leftDivBiOpExpr = minusBiOpExpr.leftExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1/a`.")
        return
      }
      XCTAssertEqual(leftDivBiOpExpr.sourceRange, getRange(1, 1, 1, 4))
      XCTAssertEqual(leftDivBiOpExpr.binaryOperator, "/")
      XCTAssertTrue(leftDivBiOpExpr.leftExpression is LiteralExpression)
      XCTAssertTrue(leftDivBiOpExpr.rightExpression is IdentifierExpression)
      guard let rightDivBiOpExpr = minusBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1*b`.")
        return
      }
      XCTAssertEqual(rightDivBiOpExpr.sourceRange, getRange(1, 5, 1, 8))
      XCTAssertEqual(rightDivBiOpExpr.binaryOperator, "/")
      XCTAssertTrue(rightDivBiOpExpr.leftExpression is LiteralExpression)
      XCTAssertTrue(rightDivBiOpExpr.rightExpression is IdentifierExpression)
    })
  }

  func testAdditionHigherThanRangeFormation() {
    semaSeqExprFoldingAndTest("1...a+2", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let rangeBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1...a+2`.")
        return
      }
      XCTAssertEqual(rangeBiOpExpr.sourceRange, getRange(1, 1, 1, 8))
      XCTAssertEqual(rangeBiOpExpr.binaryOperator, "...")
      XCTAssertTrue(rangeBiOpExpr.leftExpression is LiteralExpression)
      guard let addBiOpExpr = rangeBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a+2`.")
        return
      }
      XCTAssertEqual(addBiOpExpr.sourceRange, getRange(1, 5, 1, 8))
      XCTAssertEqual(addBiOpExpr.binaryOperator, "+")
      XCTAssertTrue(addBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(addBiOpExpr.rightExpression is LiteralExpression)
    })
  }

  func testRangeFormationHigherThanNilCoalescing() {
    semaSeqExprFoldingAndTest("a??1..<b", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let nilBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a??1..<b`.")
        return
      }
      XCTAssertEqual(nilBiOpExpr.sourceRange, getRange(1, 1, 1, 9))
      XCTAssertEqual(nilBiOpExpr.binaryOperator, "??")
      XCTAssertTrue(nilBiOpExpr.leftExpression is IdentifierExpression)
      guard let rangeBiOpExpr = nilBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1..<b`.")
        return
      }
      XCTAssertEqual(rangeBiOpExpr.sourceRange, getRange(1, 4, 1, 9))
      XCTAssertEqual(rangeBiOpExpr.binaryOperator, "..<")
      XCTAssertTrue(rangeBiOpExpr.leftExpression is LiteralExpression)
      XCTAssertTrue(rangeBiOpExpr.rightExpression is IdentifierExpression)
    })
  }

  func testRangeFormationHigherThanCasting() {
    for c in ["is", "as", "as?", "as!"] {
      semaSeqExprFoldingAndTest("1 ..< b \(c) Foo", testFlat: { seqExpr in
        XCTAssertEqual(seqExpr.elements.count, 4)
      }, testFolded: { expr in
        XCTAssertTrue(expr is TypeCastingOperatorExpression)
      })
    }
  }

  func testCastingHigherThanNilCoalescing() {
    for c in ["is", "as", "as?", "as!"] {
      semaSeqExprFoldingAndTest("a ?? b \(c) Foo", testFlat: { seqExpr in
        XCTAssertEqual(seqExpr.elements.count, 4)
      }, testFolded: { expr in
        guard let nilBiOpExpr = expr as? BinaryOperatorExpression else {
          XCTFail("Failed in getting a binary operator expression for `a ?? b \(c) Foo`.")
          return
        }
        XCTAssertEqual(nilBiOpExpr.binaryOperator, "??")
        XCTAssertTrue(nilBiOpExpr.leftExpression is IdentifierExpression)
        XCTAssertTrue(nilBiOpExpr.rightExpression is TypeCastingOperatorExpression)
      })
    }
  }

  func testNilCoalescingHigherThanComparison() {
    semaSeqExprFoldingAndTest("1<b??2", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let compBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1<b??2`.")
        return
      }
      XCTAssertEqual(compBiOpExpr.sourceRange, getRange(1, 1, 1, 7))
      XCTAssertEqual(compBiOpExpr.binaryOperator, "<")
      XCTAssertTrue(compBiOpExpr.leftExpression is LiteralExpression)
      guard let nilBiOpExpr = compBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `b??2`.")
        return
      }
      XCTAssertEqual(nilBiOpExpr.sourceRange, getRange(1, 3, 1, 7))
      XCTAssertEqual(nilBiOpExpr.binaryOperator, "??")
      XCTAssertTrue(nilBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(nilBiOpExpr.rightExpression is LiteralExpression)
    })
  }

  func testComparisonHigherThanLogicalConjunction() {
    semaSeqExprFoldingAndTest("true&&b<2", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let conjBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `true&&b<2`.")
        return
      }
      XCTAssertEqual(conjBiOpExpr.sourceRange, getRange(1, 1, 1, 10))
      XCTAssertEqual(conjBiOpExpr.binaryOperator, "&&")
      XCTAssertTrue(conjBiOpExpr.leftExpression is LiteralExpression)
      guard let compBiOpExpr = conjBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `b<2`.")
        return
      }
      XCTAssertEqual(compBiOpExpr.sourceRange, getRange(1, 7, 1, 10))
      XCTAssertEqual(compBiOpExpr.binaryOperator, "<")
      XCTAssertTrue(compBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(compBiOpExpr.rightExpression is LiteralExpression)
    })
  }

  func testLogicalConjunctionHigherThanLogicalDisjunction() {
    semaSeqExprFoldingAndTest("false||b&&true", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let disjBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `false||b&&true`.")
        return
      }
      XCTAssertEqual(disjBiOpExpr.sourceRange, getRange(1, 1, 1, 15))
      XCTAssertEqual(disjBiOpExpr.binaryOperator, "||")
      XCTAssertTrue(disjBiOpExpr.leftExpression is LiteralExpression)
      guard let conjBiOpExpr = disjBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `b&&true`.")
        return
      }
      XCTAssertEqual(conjBiOpExpr.sourceRange, getRange(1, 8, 1, 15))
      XCTAssertEqual(conjBiOpExpr.binaryOperator, "&&")
      XCTAssertTrue(conjBiOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(conjBiOpExpr.rightExpression is LiteralExpression)
    })
  }

  func testLogicalDisjunctionHigherThanAssignment() {
    semaSeqExprFoldingAndTest("a=false||b", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let assignOpExpr = expr as? AssignmentOperatorExpression else {
        XCTFail("Failed in getting an assignment expression for `a=false||b`.")
        return
      }
      XCTAssertEqual(assignOpExpr.sourceRange, getRange(1, 1, 1, 11))
      XCTAssertTrue(assignOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(assignOpExpr.rightExpression is BinaryOperatorExpression)
    })

    semaSeqExprFoldingAndTest("a+=1+b", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 5)
    }, testFolded: { expr in
      guard let assignBiOpExpr = expr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `a+=1+b`.")
        return
      }
      XCTAssertEqual(assignBiOpExpr.sourceRange, getRange(1, 1, 1, 7))
      XCTAssertEqual(assignBiOpExpr.binaryOperator, "+=")
      XCTAssertTrue(assignBiOpExpr.leftExpression is IdentifierExpression)
      guard let addBiOpExpr = assignBiOpExpr.rightExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression for `1+b`.")
        return
      }
      XCTAssertEqual(addBiOpExpr.sourceRange, getRange(1, 4, 1, 7))
      XCTAssertEqual(addBiOpExpr.binaryOperator, "+")
      XCTAssertTrue(addBiOpExpr.leftExpression is LiteralExpression)
      XCTAssertTrue(addBiOpExpr.rightExpression is IdentifierExpression)
    })
  }

  func testLogicalDisjunctionHigherThanDefaultHigherThanTernary() {
    semaSeqExprFoldingAndTest("b ? true : bar || foo <> c", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 7)
    }, testFolded: { expr in
      guard let ternaryCondOpExpr = expr as? TernaryConditionalOperatorExpression else {
        XCTFail("Failed in getting a ternary expression for `b ? true : bar || foo <> c`.")
        return
      }
      XCTAssertEqual(ternaryCondOpExpr.sourceRange, getRange(1, 1, 1, 27))
      XCTAssertTrue(ternaryCondOpExpr.conditionExpression is IdentifierExpression)
      XCTAssertTrue(ternaryCondOpExpr.trueExpression is LiteralExpression)
      guard let biOpExpr = ternaryCondOpExpr.falseExpression as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a ternary conditional operator expression for `bar || foo <> c`.")
        return
      }
      XCTAssertEqual(biOpExpr.sourceRange, getRange(1, 12, 1, 27))
      XCTAssertEqual(biOpExpr.binaryOperator, "<>")
      XCTAssertTrue(biOpExpr.leftExpression is BinaryOperatorExpression)
      XCTAssertTrue(biOpExpr.rightExpression is IdentifierExpression)
    })
  }

  func testLogicalDisjunctionHigherThanTernaryHigherThanAssignment() {
    semaSeqExprFoldingAndTest("a = b ? true : bar || foo", testFlat: { seqExpr in
      XCTAssertEqual(seqExpr.elements.count, 7)
    }, testFolded: { expr in
      guard let assignOpExpr = expr as? AssignmentOperatorExpression else {
        XCTFail("Failed in getting an assignment expression for `a = b ? true : bar || foo`.")
        return
      }
      XCTAssertEqual(assignOpExpr.sourceRange, getRange(1, 1, 1, 26))
      XCTAssertTrue(assignOpExpr.leftExpression is IdentifierExpression)
      guard let ternaryCondOpExpr = assignOpExpr.rightExpression as? TernaryConditionalOperatorExpression else {
        XCTFail("Failed in getting a ternary conditional operator expression for `b ? true : bar || foo`.")
        return
      }
      XCTAssertEqual(ternaryCondOpExpr.sourceRange, getRange(1, 5, 1, 26))
      XCTAssertTrue(ternaryCondOpExpr.conditionExpression is IdentifierExpression)
      XCTAssertTrue(ternaryCondOpExpr.trueExpression is LiteralExpression)
      XCTAssertTrue(ternaryCondOpExpr.falseExpression is BinaryOperatorExpression)
    })
  }

  private func semaSeqExprFoldingAndTest(
    _ content: String,
    testFlat: (SequenceExpression) -> Void,
    testFolded: (Expression) -> Void
  ) {
    let topLevelDecl = parse(content)
    guard let seqExpr = topLevelDecl.statements.first as? SequenceExpression else {
      XCTFail("Failed in parsing a sequence expression with content `\(content)`.")
      return
    }
    testFlat(seqExpr)
    let seqExprFolding = SequenceExpressionFolding()
    seqExprFolding.fold([topLevelDecl])
    guard let foldedExpr = topLevelDecl.statements.first as? Expression else {
      XCTFail("Failed in folding sequence expression.")
      return
    }
    testFolded(foldedExpr)
  }

  static var allTests = [
    ("testBitwiseShiftHigherThanMultiplication", testBitwiseShiftHigherThanMultiplication),
    ("testMultiplicationHigherThanAddition", testMultiplicationHigherThanAddition),
    ("testAdditionHigherThanRangeFormation", testAdditionHigherThanRangeFormation),
    ("testRangeFormationHigherThanNilCoalescing", testRangeFormationHigherThanNilCoalescing),
    ("testRangeFormationHigherThanCasting", testRangeFormationHigherThanCasting),
    ("testCastingHigherThanNilCoalescing", testCastingHigherThanNilCoalescing),
    ("testNilCoalescingHigherThanComparison", testNilCoalescingHigherThanComparison),
    ("testComparisonHigherThanLogicalConjunction", testComparisonHigherThanLogicalConjunction),
    ("testLogicalConjunctionHigherThanLogicalDisjunction", testLogicalConjunctionHigherThanLogicalDisjunction),
    ("testLogicalDisjunctionHigherThanAssignment", testLogicalDisjunctionHigherThanAssignment),
    ("testLogicalDisjunctionHigherThanDefaultHigherThanTernary",
      testLogicalDisjunctionHigherThanDefaultHigherThanTernary),
    ("testLogicalDisjunctionHigherThanTernaryHigherThanAssignment",
      testLogicalDisjunctionHigherThanTernaryHigherThanAssignment),
  ]
}
