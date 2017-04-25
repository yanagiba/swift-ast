/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class ParserAssignmentOperatorExpressionTests: XCTestCase {
  func testAssignment() {
    parseExpressionAndTest("foo = bar", "foo = bar", testClosure: { expr in
      guard let assignOpExpr = expr as? AssignmentOperatorExpression else {
        XCTFail("Failed in getting an assignment operator expression")
        return
      }

      XCTAssertTrue(assignOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(assignOpExpr.rightExpression is IdentifierExpression)
    })
  }

  func testRhsIsTryOperator() {
    for tryOp in ["try", "try?", "try!"] {
      parseExpressionAndTest("foo  =  \(tryOp)  bar", "foo = \(tryOp) bar", testClosure: { expr in
        guard let assignOpExpr = expr as? AssignmentOperatorExpression else {
          XCTFail("Failed in getting an assignment operator expression")
          return
        }

        XCTAssertTrue(assignOpExpr.leftExpression is IdentifierExpression)
        XCTAssertTrue(assignOpExpr.rightExpression is TryOperatorExpression)
      })
    }
  }

  func testAssignments() {
    parseExpressionAndTest("foo = bar = true", "foo = bar = true", testClosure: { expr in
      guard let outterExpr = expr as? AssignmentOperatorExpression else {
        XCTFail("Failed in getting an assignment operator expression")
        return
      }

      XCTAssertTrue(outterExpr.rightExpression is LiteralExpression)

      guard let innerExpr = outterExpr.leftExpression as? AssignmentOperatorExpression else {
        XCTFail("Failed in getting an assignment operator expression")
        return
      }

      XCTAssertTrue(innerExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(innerExpr.rightExpression is IdentifierExpression)
    })
  }

  func testTupleAssignment() {
    parseExpressionAndTest("(a, _, (b, c)) = (\"test\", 9.45, (12, 3))", "(a, _, (b, c)) = (\"test\", 9.45, (12, 3))")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo = bar", 10),
      ("(a, b) = (1, 2)", 16),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testAssignment", testAssignment),
    ("testRhsIsTryOperator", testRhsIsTryOperator),
    ("testAssignments", testAssignments),
    ("testTupleAssignment", testTupleAssignment),
    ("testSourceRange", testSourceRange),
  ]
}
