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

class ParserOptionalChainingExpressionTests: XCTestCase {
  func testOptional() {
    parseExpressionAndTest("foo?", "foo?", testClosure: { expr in
      XCTAssertTrue(expr is OptionalChainingExpression)
    })
  }

  func testTwoOptional() {
    parseExpressionAndTest("foo??", "foo??", testClosure: { expr in
      XCTAssertTrue(expr is OptionalChainingExpression)
    })
  }

  func testOptionalForced() {
    parseExpressionAndTest("foo!?", "foo!?", testClosure: { expr in
      XCTAssertTrue(expr is OptionalChainingExpression)
    })
  }

  func testNotImmediateFollow() {
    parseExpressionAndTest("foo ?", "foo")
  }

  func testQuestionInTheMiddle() {
    parseExpressionAndTest("someDictionary[a]?[0]", "someDictionary[a]?[0]", testClosure: { expr in
      guard let subscriptExpr = expr as? SubscriptExpression else {
        XCTFail("Failed in getting a subscript expression.")
        return
      }
      XCTAssertTrue(subscriptExpr.postfixExpression is OptionalChainingExpression)
    })
    parseExpressionAndTest("Foo.bar?()", "Foo.bar?()", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a func call expression.")
        return
      }
      XCTAssertTrue(funcCallExpr.postfixExpression is OptionalChainingExpression)
    })
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo?", 5),
      ("foo??", 6),
      ("foo!?", 6),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testOptional", testOptional),
    ("testTwoOptional", testTwoOptional),
    ("testOptionalForced", testOptionalForced),
    ("testNotImmediateFollow", testNotImmediateFollow),
    ("testQuestionInTheMiddle", testQuestionInTheMiddle),
    ("testSourceRange", testSourceRange),
  ]
}
