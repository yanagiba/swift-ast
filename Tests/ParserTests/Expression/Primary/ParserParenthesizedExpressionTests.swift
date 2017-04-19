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

class ParserParenthesizedExpressionTests: XCTestCase {
  func testParenthesizedExpression() {
    parseExpressionAndTest("(3)", "(3)", testClosure: { expr in
      guard let parenExpr = expr as? ParenthesizedExpression else {
        XCTFail("Failed in getting a parenthesized expression")
        return
      }
      XCTAssertTrue(parenExpr.expression is LiteralExpression)
    })
  }

  func testContainsTupleExpression() {
    parseExpressionAndTest("((1, 2, 3))", "((1, 2, 3))", testClosure: { expr in
      guard let parenExpr = expr as? ParenthesizedExpression else {
        XCTFail("Failed in getting a parenthesized expression")
        return
      }
      XCTAssertTrue(parenExpr.expression is TupleExpression)
    })
  }

  func testHasIdentifier() {
    parseExpressionAndTest("(foo: 3)", "(foo: 3)", testClosure: { expr in
      XCTAssertFalse(expr is ParenthesizedExpression)
      XCTAssertTrue(expr is TupleExpression)
    })
  }

  func testZeroElement() {
    parseExpressionAndTest("()", "()", testClosure: { expr in
      XCTAssertFalse(expr is ParenthesizedExpression)
      XCTAssertTrue(expr is TupleExpression)
    })
  }

  func testMoreThanOneElement() {
    parseExpressionAndTest("(1, 2, 3)", "(1, 2, 3)", testClosure: { expr in
      XCTAssertFalse(expr is ParenthesizedExpression)
      XCTAssertTrue(expr is TupleExpression)
    })
  }

  func testSourceRange() {
    parseExpressionAndTest("(foo)", "(foo)", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 6))
    })
  }

  static var allTests = [
    ("testParenthesizedExpression", testParenthesizedExpression),
    ("testContainsTupleExpression", testContainsTupleExpression),
    ("testHasIdentifier", testHasIdentifier),
    ("testZeroElement", testZeroElement),
    ("testMoreThanOneElement", testMoreThanOneElement),
    ("testSourceRange", testSourceRange),
  ]
}
