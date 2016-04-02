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

func specParenthesizedExpression() {
  let parser = Parser()

  describe("Parse a parenthesized expression with no expression") {
    $0.it("should return a parenthesized expression with no expression") {
      for testString in ["()", "( )", "(          )    "] {
        parser.setupTestCode(testString)
        guard let parenExpr = try? parser.parseParenthesizedExpression() else {
          throw failure("Failed in getting a parenthesized expression.")
        }
        try expect(parenExpr.expressions.count) == 0
      }
    }
  }

  describe("Parse a parenthesized expression with one expression") {
    $0.it("should return a parenthesized expression with one expression") {
      parser.setupTestCode("(foo)")
      guard let parenExpr = try? parser.parseParenthesizedExpression() else {
        throw failure("Failed in getting a parenthesized expression.")
      }
      try expect(parenExpr.expressions.count) == 1
      let expression = parenExpr.expressions[0]
      try expect(expression.identifier).to.beNil()
      try expect(expression.expression is IdentifierExpression).to.beTrue()
    }
  }

  describe("Parse a parenthesized expression with multiple expressions") {
    $0.it("should return a parenthesized expression with multiple expressions") {
      parser.setupTestCode("(foo, bar, ())")
      guard let parenExpr = try? parser.parseParenthesizedExpression() else {
        throw failure("Failed in getting a parenthesized expression.")
      }
      try expect(parenExpr.expressions.count) == 3
      try expect(parenExpr.expressions[0].identifier).to.beNil()
      try expect(parenExpr.expressions[0].expression is IdentifierExpression).to.beTrue()
      try expect(parenExpr.expressions[1].identifier).to.beNil()
      try expect(parenExpr.expressions[1].expression is IdentifierExpression).to.beTrue()
      try expect(parenExpr.expressions[2].identifier).to.beNil()
      try expect(parenExpr.expressions[2].expression is ParenthesizedExpression).to.beTrue()
    }
  }

  describe("Parse a parenthesized expression with one expression and identifier") {
    $0.it("should return a parenthesized expression with one expression and identifier") {
      parser.setupTestCode("(x: foo)")
      guard let parenExpr = try? parser.parseParenthesizedExpression() else {
        throw failure("Failed in getting a parenthesized expression.")
      }
      try expect(parenExpr.expressions.count) == 1
      let expression = parenExpr.expressions[0]
      try expect(expression.identifier) == "x"
      try expect(expression.expression is IdentifierExpression).to.beTrue()
    }
  }

  describe("Parse a parenthesized expression with multiple expressions and identifiers") {
    $0.it("should return a parenthesized expression with multiple expressions and identifiers") {
      parser.setupTestCode("(a: foo, b: bar, c:())")
      guard let parenExpr = try? parser.parseParenthesizedExpression() else {
        throw failure("Failed in getting a parenthesized expression.")
      }
      try expect(parenExpr.expressions.count) == 3
      try expect(parenExpr.expressions[0].identifier) == "a"
      try expect(parenExpr.expressions[0].expression is IdentifierExpression).to.beTrue()
      try expect(parenExpr.expressions[1].identifier) == "b"
      try expect(parenExpr.expressions[1].expression is IdentifierExpression).to.beTrue()
      try expect(parenExpr.expressions[2].identifier) == "c"
      try expect(parenExpr.expressions[2].expression is ParenthesizedExpression).to.beTrue()
    }
  }

  describe("Parse a parenthesized expression with multiple expressions and some identifiers") {
    $0.it("should return a parenthesized expression with multiple expressions and some identifiers") {
      parser.setupTestCode("(foo, b: bar, c:())")
      guard let parenExpr = try? parser.parseParenthesizedExpression() else {
        throw failure("Failed in getting a parenthesized expression.")
      }
      try expect(parenExpr.expressions.count) == 3
      try expect(parenExpr.expressions[0].identifier).to.beNil()
      try expect(parenExpr.expressions[0].expression is IdentifierExpression).to.beTrue()
      try expect(parenExpr.expressions[1].identifier) == "b"
      try expect(parenExpr.expressions[1].expression is IdentifierExpression).to.beTrue()
      try expect(parenExpr.expressions[2].identifier) == "c"
      try expect(parenExpr.expressions[2].expression is ParenthesizedExpression).to.beTrue()
    }
  }
}
