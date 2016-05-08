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

class ParsingPostfixOperatorExpressionTests: XCTestCase {
  let parser = Parser()

  func testParsePostfixOperatorExpression() {
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
      let testCode = "foo\(testString)"
      parser.setupTestCode(testCode)
      guard let postfixOpExpr = try? parser.parsePostfixOperatorExpression() else {
        XCTFail("Failed in getting a postfix operator expression for code `\(testCode)`.")
        return
      }
      XCTAssertEqual(postfixOpExpr.postfixOperator, testString)
      XCTAssertTrue(postfixOpExpr.postfixExpression is IdentifierExpression)
    }
  }

  func testParseEmbededPostfixOperatorExpression() {
    parser.setupTestCode("foo<>")
    guard let postfixOpExpr = try? parser.parsePostfixOperatorExpression() else {
      XCTFail("Failed in getting a postfix operator expression.")
      return
    }
    XCTAssertEqual(postfixOpExpr.postfixOperator, ">")
    guard let embededPostfixOpExpr = postfixOpExpr.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr.postfixOperator, "<")
    XCTAssertTrue(embededPostfixOpExpr.postfixExpression is IdentifierExpression)
  }

  func testParseMultipleLevelEmbededPostfixOperatorExpression() {
    parser.setupTestCode("foo>>>!!>>")
    guard let postfixOpExpr = try? parser.parsePostfixOperatorExpression() else {
      XCTFail("Failed in getting a postfix operator expression.")
      return
    }
    XCTAssertEqual(postfixOpExpr.postfixOperator, ">")
    guard let embededPostfixOpExpr1 = postfixOpExpr.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr1.postfixOperator, ">")
    guard let embededPostfixOpExpr2 = embededPostfixOpExpr1.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr2.postfixOperator, "!")
    guard let embededPostfixOpExpr3 = embededPostfixOpExpr2.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr3.postfixOperator, "!")
    guard let embededPostfixOpExpr4 = embededPostfixOpExpr3.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr4.postfixOperator, ">")
    guard let embededPostfixOpExpr5 = embededPostfixOpExpr4.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr5.postfixOperator, ">")
    guard let embededPostfixOpExpr6 = embededPostfixOpExpr5.postfixExpression as? PostfixOperatorExpression else {
      XCTFail("Failed in getting an embeded postfix operator expression.")
      return
    }
    XCTAssertEqual(embededPostfixOpExpr6.postfixOperator, ">")
    XCTAssertTrue(embededPostfixOpExpr6.postfixExpression is IdentifierExpression)
  }
}
