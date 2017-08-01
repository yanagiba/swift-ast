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

class ParserTernaryConditionalOperatorExpressionTests: XCTestCase {
  func testConditional() {
    parseExpressionAndTest("condition ? true : false", "condition ? true : false", testClosure: { expr in
      guard let condExpr = expr as? TernaryConditionalOperatorExpression else {
        XCTFail("Failed in getting a conditional operator expression")
        return
      }

      XCTAssertTrue(condExpr.conditionExpression is IdentifierExpression)
      XCTAssertTrue(condExpr.trueExpression is LiteralExpression)
      XCTAssertTrue(condExpr.falseExpression is LiteralExpression)
    })
  }

  func testFunctions() {
    parseExpressionAndTest("c() ? t() : f()", "c() ? t() : f()", testClosure: { expr in
      guard let condExpr = expr as? TernaryConditionalOperatorExpression else {
        XCTFail("Failed in getting a conditional operator expression")
        return
      }

      XCTAssertTrue(condExpr.conditionExpression is FunctionCallExpression)
      XCTAssertTrue(condExpr.trueExpression is FunctionCallExpression)
      XCTAssertTrue(condExpr.falseExpression is FunctionCallExpression)
    })
  }

  func testTryOperators() {
    parseExpressionAndTest("try? c() ? try t() : try! f()", "try? c() ? try t() : try! f()", testClosure: { expr in
      guard let tryOpExpr = expr as? TryOperatorExpression else {
        XCTFail("Failed in getting a try operator expression")
        return
      }

      guard case .optional(let tryExpr) = tryOpExpr.kind,
        let condExpr = tryExpr as? TernaryConditionalOperatorExpression else {
        XCTFail("Failed in getting a conditional operator expression")
        return
      }

      XCTAssertTrue(condExpr.conditionExpression is FunctionCallExpression)
      XCTAssertTrue(condExpr.trueExpression is TryOperatorExpression)
      XCTAssertTrue(condExpr.falseExpression is TryOperatorExpression)
    })
  }

  func testNested() {
     // a ? (b ? (c ? d : e) : f) : g
    parseExpressionAndTest(
      "a ? b ? c ? d : e : f : g",
      "a ? b ? c ? d : e : f : g",
      testClosure: { expr in
        guard let ternaryOpExpr = expr as? TernaryConditionalOperatorExpression else {
          XCTFail("Failed in getting a ternary cond op expr for code `a ? b ? c ? d : e : f : g`.")
          return
        }

        XCTAssertTrue(ternaryOpExpr.conditionExpression is IdentifierExpression)
        XCTAssertEqual(ternaryOpExpr.conditionExpression.textDescription, "a")
        XCTAssertTrue(ternaryOpExpr.falseExpression is IdentifierExpression)
        XCTAssertEqual(ternaryOpExpr.falseExpression.textDescription, "g")

        guard let trueTernaryOpExpr =
          ternaryOpExpr.trueExpression as? TernaryConditionalOperatorExpression
        else {
          XCTFail("Failed in getting a ternary conditional operator expression for code `f ? g : h`.")
          return
        }
        XCTAssertEqual(trueTernaryOpExpr.textDescription, "b ? c ? d : e : f")
        XCTAssertTrue(trueTernaryOpExpr.conditionExpression is IdentifierExpression)
        XCTAssertEqual(trueTernaryOpExpr.conditionExpression.textDescription, "b")
        XCTAssertTrue(trueTernaryOpExpr.falseExpression is IdentifierExpression)
        XCTAssertEqual(trueTernaryOpExpr.falseExpression.textDescription, "f")

        guard let trueTrueTernaryOpExpr =
          trueTernaryOpExpr.trueExpression as? TernaryConditionalOperatorExpression
        else {
          XCTFail("Failed in getting a ternary conditional operator expression for code `c ? d : e`.")
          return
        }
        XCTAssertEqual(trueTrueTernaryOpExpr.textDescription, "c ? d : e")
        XCTAssertTrue(trueTrueTernaryOpExpr.conditionExpression is IdentifierExpression)
        XCTAssertEqual(trueTrueTernaryOpExpr.conditionExpression.textDescription, "c")
        XCTAssertTrue(trueTrueTernaryOpExpr.trueExpression is IdentifierExpression)
        XCTAssertEqual(trueTrueTernaryOpExpr.trueExpression.textDescription, "d")
        XCTAssertTrue(trueTrueTernaryOpExpr.falseExpression is IdentifierExpression)
        XCTAssertEqual(trueTrueTernaryOpExpr.falseExpression.textDescription, "e")
      }
    )
  }

  func testSourceRange() {
    parseExpressionAndTest("condition ? true : false", "condition ? true : false", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 25))
    })
  }

  static var allTests = [
    ("testConditional", testConditional),
    ("testFunctions", testFunctions),
    ("testTryOperators", testTryOperators),
    ("testNested", testNested),
    ("testSourceRange", testSourceRange),
  ]
}
