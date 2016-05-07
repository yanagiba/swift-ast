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

class ParsingBinaryOperatorExpressionTests: XCTestCase {
  let parser = Parser()

  func testBinaryOperatorExpression() {
    let testStrings = [
      // regular operators
      "/",
      "-",
      "+",
      "--",
      "++",
      "+=",
      "=-",
      "==",
      "!*",
      "*<",
      "<!>",
      ">?>?>",
      "&|^~?",
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]
    for testString in testStrings {
      let testCode = "foo \(testString) bar"
      parser.setupTestCode(testCode)
      guard let biOpExpr = try? parser.parseBinaryOperatorExpression() else {
        XCTFail("Failed in getting a binary operator expression for code `\(testCode)`.")
        return
      }
      XCTAssertEqual(biOpExpr.binaryOperator, testString)
      XCTAssertTrue(biOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(biOpExpr.rightExpression is IdentifierExpression)
    }
  }

  func testBinaryOperatorExpressionWithoutSpaces() {
    let testStrings = [
      // regular operators
      "/",
      "-",
      "+",
      "--",
      "++",
      "+=",
      "=-",
      "==",
      "!*",
      "*<",
      "<!>",
      ">?>?>",
      "&|^~?",
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]
    for testString in testStrings {
      let testCode = "foo\(testString)bar"
      parser.setupTestCode(testCode)
      guard let biOpExpr = try? parser.parseBinaryOperatorExpression() else {
        XCTFail("Failed in getting a binary operator expression for code `\(testCode)`.")
        return
      }
      XCTAssertEqual(biOpExpr.binaryOperator, testString)
      XCTAssertTrue(biOpExpr.leftExpression is IdentifierExpression)
      XCTAssertTrue(biOpExpr.rightExpression is IdentifierExpression)
    }
  }

  func testBinaryOperatorExpressionWithLhsAsTryOperator() {
    let testStrings = [
      // regular operators
      "/",
      "-",
      "+",
      "--",
      "++",
      "+=",
      "=-",
      "==",
      "!*",
      "*<",
      "<!>",
      ">?>?>",
      "&|^~?",
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]
    for testString in testStrings {
      let testCode = "try? foo \(testString) bar"
      parser.setupTestCode(testCode)
      guard let biOpExpr = try? parser.parseBinaryOperatorExpression() else {
        XCTFail("Failed in getting a binary operator expression for code `\(testCode)`.")
        return
      }
      XCTAssertEqual(biOpExpr.binaryOperator, testString)
      XCTAssertTrue(biOpExpr.leftExpression is TryOperatorExpression)
      XCTAssertTrue(biOpExpr.rightExpression is IdentifierExpression)
    }
  }
}