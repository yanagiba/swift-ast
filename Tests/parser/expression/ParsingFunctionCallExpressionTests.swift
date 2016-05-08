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

class ParsingFunctionCallExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseFunctionCallExpressionWithEmptyParameter() {
    parser.setupTestCode("foo()")
    guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let idExpr = funcCallExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    guard let parenExpr = funcCallExpr.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 0)
    XCTAssertNil(funcCallExpr.trailingClosure)
  }

  func testParseFunctionCallExpressionWithOneParameter() {
    parser.setupTestCode("foo(a: 1)")
    guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let idExpr = funcCallExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    guard let parenExpr = funcCallExpr.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 1)
    XCTAssertNil(funcCallExpr.trailingClosure)
  }

  func testParseFunctionCallExpressionWithMultipleParameters() {
    parser.setupTestCode("foo(a: 1, b: [x: true, y: false], c: (1, 2, 3))")
    guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let idExpr = funcCallExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    guard let parenExpr = funcCallExpr.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 3)
    XCTAssertNil(funcCallExpr.trailingClosure)
  }

  func testParseNestedFunctionCallExpressions() {
    parser.setupTestCode("foo()()()")
    guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let parenExpr = funcCallExpr.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 0)
    XCTAssertNil(funcCallExpr.trailingClosure)

    guard let funcCallExpr1 = funcCallExpr.postfixExpression as? FunctionCallExpression else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr1.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let parenExpr1 = funcCallExpr1.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr1.expressions.count, 0)
    XCTAssertNil(funcCallExpr1.trailingClosure)

    guard let funcCallExpr2 = funcCallExpr1.postfixExpression as? FunctionCallExpression else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr2.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let parenExpr2 = funcCallExpr2.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr2.expressions.count, 0)
    XCTAssertNil(funcCallExpr2.trailingClosure)
    guard let idExpr = funcCallExpr2.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testParseFunctionCallExpressionAsConstructorCall() {
    parser.setupTestCode("foo.init(a: 1, b: [x: true, y: false], c: (1, 2, 3))")
    guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
    XCTAssertEqual(funcCallExpr.kind, FunctionCallExpression.Kind.Parenthesized)
    guard let parenExpr = funcCallExpr.parenthesizedExpression else {
      XCTFail("Failed in getting a parenthesize expression.")
      return
    }
    XCTAssertEqual(parenExpr.expressions.count, 3)
    XCTAssertNil(funcCallExpr.trailingClosure)
    guard let initExpr = funcCallExpr.postfixExpression as? InitializerExpression else {
      XCTFail("Failed in getting an initializer expression.")
      return
    }
    guard let idExpr = initExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }
}
