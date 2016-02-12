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

import Spectre

@testable import parser
@testable import ast

func specFunctionCallExpression() {
  let parser = Parser()

  describe("Parse a function call expression with empty parameter") {
    $0.it("should return a function call expression with empty parameter") {
      parser.setupTestCode("foo()")
      guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
        throw failure("Failed in getting a function call expression.")
      }
      try expect(funcCallExpr.kind) == .Parenthesized
      guard let idExpr = funcCallExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      guard let parenExpr = funcCallExpr.parenthesizedExpression else {
        throw failure("Failed in getting a parenthesize expression.")
      }
      try expect(parenExpr.expressions.count) == 0
      try expect(funcCallExpr.trailingClosure).to.beNil()
    }
  }

  describe("Parse a function call expression with one parameter") {
    $0.it("should return a function call expression with one parameter") {
      parser.setupTestCode("foo(a: 1)")
      guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
        throw failure("Failed in getting a function call expression.")
      }
      try expect(funcCallExpr.kind) == .Parenthesized
      guard let idExpr = funcCallExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      guard let parenExpr = funcCallExpr.parenthesizedExpression else {
        throw failure("Failed in getting a parenthesize expression.")
      }
      try expect(parenExpr.expressions.count) == 1
      try expect(funcCallExpr.trailingClosure).to.beNil()
    }
  }

  describe("Parse a function call expression with multiple parameters") {
    $0.it("should return a function call expression with multiple parameters") {
      parser.setupTestCode("foo(a: 1, b: [x: true, y: false], c: (1, 2, 3))")
      guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
        throw failure("Failed in getting a function call expression.")
      }
      try expect(funcCallExpr.kind) == .Parenthesized
      guard let idExpr = funcCallExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      guard let parenExpr = funcCallExpr.parenthesizedExpression else {
        throw failure("Failed in getting a parenthesize expression.")
      }
      try expect(parenExpr.expressions.count) == 3
      try expect(funcCallExpr.trailingClosure).to.beNil()
    }
  }

  describe("Parse nested function call expressions") {
    $0.it("should return nested function call expressions") {
      parser.setupTestCode("foo()()()")
      guard let funcCallExpr = try? parser.parseFunctionCallExpression() else {
        throw failure("Failed in getting a function call expression.")
      }
      try expect(funcCallExpr.kind) == .Parenthesized
      guard let parenExpr = funcCallExpr.parenthesizedExpression else {
        throw failure("Failed in getting a parenthesize expression.")
      }
      try expect(parenExpr.expressions.count) == 0
      try expect(funcCallExpr.trailingClosure).to.beNil()

      guard let funcCallExpr1 = funcCallExpr.postfixExpression as? FunctionCallExpression else {
        throw failure("Failed in getting a function call expression.")
      }
      try expect(funcCallExpr1.kind) == .Parenthesized
      guard let parenExpr1 = funcCallExpr1.parenthesizedExpression else {
        throw failure("Failed in getting a parenthesize expression.")
      }
      try expect(parenExpr1.expressions.count) == 0
      try expect(funcCallExpr1.trailingClosure).to.beNil()

      guard let funcCallExpr2 = funcCallExpr1.postfixExpression as? FunctionCallExpression else {
        throw failure("Failed in getting a function call expression.")
      }
      try expect(funcCallExpr2.kind) == .Parenthesized
      guard let parenExpr2 = funcCallExpr2.parenthesizedExpression else {
        throw failure("Failed in getting a parenthesize expression.")
      }
      try expect(parenExpr2.expressions.count) == 0
      try expect(funcCallExpr2.trailingClosure).to.beNil()
      guard let idExpr = funcCallExpr2.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }


}
