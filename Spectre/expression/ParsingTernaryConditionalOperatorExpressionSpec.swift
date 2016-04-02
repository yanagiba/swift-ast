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

func specTernaryConditionalOperatorExpression() {
  let parser = Parser()

  describe("Parse ternary conditional operator expression") {
    $0.it("should return ternary conditional operator expression") {
      let testCode = "condition ? true : false"
      parser.setupTestCode(testCode)
      guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
        throw failure("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      }
      try expect(ternaryOpExpr.conditionExpression is IdentifierExpression).to.beTrue()
      try expect(ternaryOpExpr.trueExpression is LiteralExpression).to.beTrue()
      try expect(ternaryOpExpr.falseExpression is LiteralExpression).to.beTrue()
    }
  }

  describe("Parse ternary conditional operator expression with functions") {
    $0.it("should return ternary conditional operator expression with functions") {
      let testCode = "c() ? t() : f()"
      parser.setupTestCode(testCode)
      guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
        throw failure("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      }
      try expect(ternaryOpExpr.conditionExpression is FunctionCallExpression).to.beTrue()
      try expect(ternaryOpExpr.trueExpression is FunctionCallExpression).to.beTrue()
      try expect(ternaryOpExpr.falseExpression is FunctionCallExpression).to.beTrue()
    }
  }

  describe("Parse ternary conditional operator expression with try operators") {
    $0.it("should return ternary conditional operator expression with try operators") {
      let testCode = "try? c() ? try t() : try! f()"
      parser.setupTestCode(testCode)
      guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
        throw failure("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      }
      try expect(ternaryOpExpr.conditionExpression is TryOperatorExpression).to.beTrue()
      try expect(ternaryOpExpr.trueExpression is TryOperatorExpression).to.beTrue()
      try expect(ternaryOpExpr.falseExpression is TryOperatorExpression).to.beTrue()
    }
  }

  describe("Parse ternary conditional operator expression with embedded ternary conditional operator expressions") {
    $0.it("should return ternary conditional operator expression with embedded ternary conditional operator expressions") {
      let testCode = "a ? b ? c : d : e ? f ? g : h : i" // (a ? (b ? c : d) : e) ? (f ? g : h) : i
      parser.setupTestCode(testCode)
      guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
        throw failure("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      }

      try expect(ternaryOpExpr.falseExpression is IdentifierExpression).to.beTrue()

      guard let trueTernaryOpExpr = ternaryOpExpr.trueExpression as? TernaryConditionalOperatorExpression else {
        throw failure("Failed in getting a ternary conditional operator expression for code `f ? g : h`.")
      }
      try expect(trueTernaryOpExpr.conditionExpression is IdentifierExpression).to.beTrue()
      try expect(trueTernaryOpExpr.trueExpression is IdentifierExpression).to.beTrue()
      try expect(trueTernaryOpExpr.falseExpression is IdentifierExpression).to.beTrue()

      guard let condTernaryOpExpr = ternaryOpExpr.conditionExpression as? TernaryConditionalOperatorExpression else {
        throw failure("Failed in getting a ternary conditional operator expression for code `a ? (b ? c : d) : e`.")
      }
      try expect(condTernaryOpExpr.conditionExpression is IdentifierExpression).to.beTrue()
      try expect(condTernaryOpExpr.falseExpression is IdentifierExpression).to.beTrue()

      guard let condTrueTernaryOpExpr = condTernaryOpExpr.trueExpression as? TernaryConditionalOperatorExpression else {
        throw failure("Failed in getting a ternary conditional operator expression for code `b ? c : d`.")
      }
      try expect(condTrueTernaryOpExpr.conditionExpression is IdentifierExpression).to.beTrue()
      try expect(condTrueTernaryOpExpr.trueExpression is IdentifierExpression).to.beTrue()
      try expect(condTrueTernaryOpExpr.falseExpression is IdentifierExpression).to.beTrue()
    }
  }
}
