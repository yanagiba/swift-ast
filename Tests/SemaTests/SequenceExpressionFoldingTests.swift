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
    ("testMultiplicationHigherThanAddition", testMultiplicationHigherThanAddition),
  ]
}
