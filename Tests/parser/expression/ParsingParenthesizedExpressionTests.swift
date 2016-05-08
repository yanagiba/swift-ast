/*
   Copyright 2016 Ryuichi Saito, LLC

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

@testable import parser
@testable import ast

class ParsingParenthesizedExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseParenthesizedExpressionWithNoExpression() {
    for testString in ["()", "( )", "(          )    "] {
      parser.setupTestCode(testString)
      guard let parenExpr = try? parser.parseParenthesizedExpression() else {
        XCTFail("Failed in getting a parenthesized expression.")
        return
      }
      XCTAssertEqual(parenExpr.expressions.count, 0)
    }
  }

  func testParseParenthesizedExpressionWithOneExpression() {
    parser.setupTestCode("(foo)")
    guard let parenExpr = try? parser.parseParenthesizedExpression() else {
      XCTFail("Failed in getting a parenthesized expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 1)
    let expression = parenExpr.expressions[0]
    XCTAssertNil(expression.identifier)
    XCTAssertTrue(expression.expression is IdentifierExpression)
  }

  func testParseParenthesizedExpressionWithMultipleExpressions() {
    parser.setupTestCode("(foo, bar, ())")
    guard let parenExpr = try? parser.parseParenthesizedExpression() else {
      XCTFail("Failed in getting a parenthesized expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 3)
    XCTAssertNil(parenExpr.expressions[0].identifier)
    XCTAssertTrue(parenExpr.expressions[0].expression is IdentifierExpression)
    XCTAssertNil(parenExpr.expressions[1].identifier)
    XCTAssertTrue(parenExpr.expressions[1].expression is IdentifierExpression)
    XCTAssertNil(parenExpr.expressions[2].identifier)
    XCTAssertTrue(parenExpr.expressions[2].expression is ParenthesizedExpression)
  }

  func testParseParenthesizedExpressionWithOneExpressionAndIdentifier() {
    parser.setupTestCode("(x: foo)")
    guard let parenExpr = try? parser.parseParenthesizedExpression() else {
      XCTFail("Failed in getting a parenthesized expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 1)
    let expression = parenExpr.expressions[0]
    XCTAssertEqual(expression.identifier, "x")
    XCTAssertTrue(expression.expression is IdentifierExpression)
  }

  func testParseParenthesizedExpressionWithMultipleExpressionsAndIdentifiers() {
    parser.setupTestCode("(a: foo, b: bar, c:())")
    guard let parenExpr = try? parser.parseParenthesizedExpression() else {
      XCTFail("Failed in getting a parenthesized expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 3)
    XCTAssertEqual(parenExpr.expressions[0].identifier, "a")
    XCTAssertTrue(parenExpr.expressions[0].expression is IdentifierExpression)
    XCTAssertEqual(parenExpr.expressions[1].identifier, "b")
    XCTAssertTrue(parenExpr.expressions[1].expression is IdentifierExpression)
    XCTAssertEqual(parenExpr.expressions[2].identifier, "c")
    XCTAssertTrue(parenExpr.expressions[2].expression is ParenthesizedExpression)
  }

  func testParseParenthesizedExpressionWithMultipleExpressionsAndSomeIdentifiers() {
    parser.setupTestCode("(foo, b: bar, c:())")
    guard let parenExpr = try? parser.parseParenthesizedExpression() else {
      XCTFail("Failed in getting a parenthesized expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 3)
    XCTAssertNil(parenExpr.expressions[0].identifier)
    XCTAssertTrue(parenExpr.expressions[0].expression is IdentifierExpression)
    XCTAssertEqual(parenExpr.expressions[1].identifier, "b")
    XCTAssertTrue(parenExpr.expressions[1].expression is IdentifierExpression)
    XCTAssertEqual(parenExpr.expressions[2].identifier, "c")
    XCTAssertTrue(parenExpr.expressions[2].expression is ParenthesizedExpression)
  }
}
