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

class ParserTryOperatorExpressionTests: XCTestCase {
  func testTry() {
    parseExpressionAndTest("try foo", "try foo", testClosure: { expr in
      guard let tryOpExpr = expr as? TryOperatorExpression,
        case .try(let tryExpr) = tryOpExpr.kind else {
        XCTFail("Failed in getting a try operator expression")
        return
      }

      XCTAssertTrue(tryExpr is IdentifierExpression)
    })
  }

  func testForcedTry() {
    parseExpressionAndTest("try! foo", "try! foo")
  }

  func testOptionalTry() {
    parseExpressionAndTest("try? foo", "try? foo")
  }

  func testTryBinaryExpressions() {
    parseExpressionAndTest("try foo = bar == true", "try foo = bar == true", testClosure: { expr in
      guard let tryOpExpr = expr as? TryOperatorExpression,
        case .try(let tryExpr) = tryOpExpr.kind else {
        XCTFail("Failed in getting a try operator expression")
        return
      }

      guard let biOpExpr = tryExpr as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a binary operator expression")
        return
      }

      XCTAssertTrue(biOpExpr.leftExpression is AssignmentOperatorExpression)
      XCTAssertTrue(biOpExpr.rightExpression is LiteralExpression)
    })
  }

  func testTryScopes() {
    parseExpressionAndTest("try someThrowingFunction() + anotherThrowingFunction()", "try someThrowingFunction() + anotherThrowingFunction()")
    parseExpressionAndTest("try (someThrowingFunction() + anotherThrowingFunction())", "try (someThrowingFunction() + anotherThrowingFunction())")
    parseExpressionAndTest("(try someThrowingFunction()) + anotherThrowingFunction()", "(try someThrowingFunction()) + anotherThrowingFunction()")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("try foo", 8),
      ("try? foo", 9),
      ("try! foo", 9),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testTry", testTry),
    ("testForcedTry", testForcedTry),
    ("testOptionalTry", testOptionalTry),
    ("testTryBinaryExpressions", testTryBinaryExpressions),
    ("testTryScopes", testTryScopes),
    ("testSourceRange", testSourceRange),
  ]
}
