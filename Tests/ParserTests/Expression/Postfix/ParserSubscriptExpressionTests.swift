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

import XCTest

@testable import AST

class ParserSubscriptExpressionTests: XCTestCase {
  func testSingleExpr() {
    parseExpressionAndTest("foo[0]", "foo[0]", testClosure: { expr in
      XCTAssertTrue(expr is SubscriptExpression)
    })
  }

  func testMultipleExprs() {
    parseExpressionAndTest("foo[0, 1, 2]", "foo[0, 1, 2]")
  }

  func testVariables() {
    parseExpressionAndTest("foo [ a ,0, b ,1 , 5,_]", "foo[a, 0, b, 1, 5, _]")
    parseExpressionAndTest("foo [n-1, n--1]", "foo[n - 1, n -- 1]")
    parseExpressionAndTest("foo [n+1]", "foo[n + 1]")
    parseExpressionAndTest("foo [bar()]", "foo[bar()]")
    parseExpressionAndTest("foo [try bar()]", "foo[try bar()]")
  }

  func testArgumentWithIdentifier() {
    // https://github.com/yanagiba/swift-ast/issues/38
    parseExpressionAndTest("foo[bar: 0]", "foo[bar: 0]", testClosure: { expr in
      XCTAssertTrue(expr is SubscriptExpression)
    })
    parseExpressionAndTest("foo[a: 0, b: 1, c: 2]", "foo[a: 0, b: 1, c: 2]")
    parseExpressionAndTest("foo [bar: n+1]", "foo[bar: n + 1]")
    parseExpressionAndTest("foo [bar: bar()]", "foo[bar: bar()]")
    parseExpressionAndTest("foo [bar: try bar()]", "foo[bar: try bar()]")
  }

  func testArgumentListOnSameLine() {
    parseExpressionAndTest("foo\n[bar]", "foo")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo[0]", 7),
      ("foo[0, 1, 2]", 13),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testSingleExpr", testSingleExpr),
    ("testMultipleExprs", testMultipleExprs),
    ("testVariables", testVariables),
    ("testArgumentWithIdentifier", testArgumentWithIdentifier),
    ("testArgumentListOnSameLine", testArgumentListOnSameLine),
    ("testSourceRange", testSourceRange),
  ]
}
