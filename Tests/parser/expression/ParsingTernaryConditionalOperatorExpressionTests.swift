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

class ParsingTernaryConditionalOperatorExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseTernaryConditionalOperatorExpression() {
    let testCode = "condition ? true : false"
    parser.setupTestCode(testCode)
    guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      return
    }
    XCTAssertTrue(ternaryOpExpr.conditionExpression is IdentifierExpression)
    XCTAssertTrue(ternaryOpExpr.trueExpression is LiteralExpression)
    XCTAssertTrue(ternaryOpExpr.falseExpression is LiteralExpression)
  }

  func testParseTernaryConditionalOperatorExpressionWithFunctions() {
    let testCode = "c() ? t() : f()"
    parser.setupTestCode(testCode)
    guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      return
    }
    XCTAssertTrue(ternaryOpExpr.conditionExpression is FunctionCallExpression)
    XCTAssertTrue(ternaryOpExpr.trueExpression is FunctionCallExpression)
    XCTAssertTrue(ternaryOpExpr.falseExpression is FunctionCallExpression)
  }

  func testParseTernaryConditionalOperatorExpressionWithTryOperators() {
    let testCode = "try? c() ? try t() : try! f()"
    parser.setupTestCode(testCode)
    guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      return
    }
    XCTAssertTrue(ternaryOpExpr.conditionExpression is TryOperatorExpression)
    XCTAssertTrue(ternaryOpExpr.trueExpression is TryOperatorExpression)
    XCTAssertTrue(ternaryOpExpr.falseExpression is TryOperatorExpression)
  }

  func testParseTernaryConditionalOperatorExpressionWithEmbeddedTernaryConditionalOperatorExpression() {
    let testCode = "a ? b ? c : d : e ? f ? g : h : i" // (a ? (b ? c : d) : e) ? (f ? g : h) : i
    parser.setupTestCode(testCode)
    guard let ternaryOpExpr = try? parser.parseTernaryConditionalOperatorExpression() else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `\(testCode)`.")
      return
    }

    XCTAssertTrue(ternaryOpExpr.falseExpression is IdentifierExpression)

    guard let trueTernaryOpExpr = ternaryOpExpr.trueExpression as? TernaryConditionalOperatorExpression else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `f ? g : h`.")
      return
    }
    XCTAssertTrue(trueTernaryOpExpr.conditionExpression is IdentifierExpression)
    XCTAssertTrue(trueTernaryOpExpr.trueExpression is IdentifierExpression)
    XCTAssertTrue(trueTernaryOpExpr.falseExpression is IdentifierExpression)

    guard let condTernaryOpExpr = ternaryOpExpr.conditionExpression as? TernaryConditionalOperatorExpression else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `a ? (b ? c : d) : e`.")
      return
    }
    XCTAssertTrue(condTernaryOpExpr.conditionExpression is IdentifierExpression)
    XCTAssertTrue(condTernaryOpExpr.falseExpression is IdentifierExpression)

    guard let condTrueTernaryOpExpr = condTernaryOpExpr.trueExpression as? TernaryConditionalOperatorExpression else {
      XCTFail("Failed in getting a ternary conditional operator expression for code `b ? c : d`.")
      return
    }
    XCTAssertTrue(condTrueTernaryOpExpr.conditionExpression is IdentifierExpression)
    XCTAssertTrue(condTrueTernaryOpExpr.trueExpression is IdentifierExpression)
    XCTAssertTrue(condTrueTernaryOpExpr.falseExpression is IdentifierExpression)
  }
}
