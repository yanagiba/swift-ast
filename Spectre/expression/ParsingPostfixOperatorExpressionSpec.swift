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

func specPostfixOperatorExpression() {
  let parser = Parser()

  describe("Parse a postfix operator expression") {
    $0.it("should return a postfix operator expression") {
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
          throw failure("Failed in getting a postfix operator expression for code `\(testCode)`.")
        }
        try expect(postfixOpExpr.postfixOperator) == testString
        try expect(postfixOpExpr.postfixExpression is IdentifierExpression).to.beTrue()
      }
    }
  }

  describe("Parse a embeded postfix operator expression") {
    $0.it("should return a embeded postfix operator expression") {
      parser.setupTestCode("foo<>")
      guard let postfixOpExpr = try? parser.parsePostfixOperatorExpression() else {
        throw failure("Failed in getting a postfix operator expression.")
      }
      try expect(postfixOpExpr.postfixOperator) == ">"
      guard let embededPostfixOpExpr = postfixOpExpr.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr.postfixOperator) == "<"
      try expect(embededPostfixOpExpr.postfixExpression is IdentifierExpression).to.beTrue()
    }
  }

  describe("Parse a multiple-level embeded postfix operator expression") {
    $0.it("should return a multiple-level embeded postfix operator expression") {
      parser.setupTestCode("foo>>>!!>>")
      guard let postfixOpExpr = try? parser.parsePostfixOperatorExpression() else {
        throw failure("Failed in getting a postfix operator expression.")
      }
      try expect(postfixOpExpr.postfixOperator) == ">"
      guard let embededPostfixOpExpr1 = postfixOpExpr.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr1.postfixOperator) == ">"
      guard let embededPostfixOpExpr2 = embededPostfixOpExpr1.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr2.postfixOperator) == "!"
      guard let embededPostfixOpExpr3 = embededPostfixOpExpr2.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr3.postfixOperator) == "!"
      guard let embededPostfixOpExpr4 = embededPostfixOpExpr3.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr4.postfixOperator) == ">"
      guard let embededPostfixOpExpr5 = embededPostfixOpExpr4.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr5.postfixOperator) == ">"
      guard let embededPostfixOpExpr6 = embededPostfixOpExpr5.postfixExpression as? PostfixOperatorExpression else {
        throw failure("Failed in getting an embeded postfix operator expression.")
      }
      try expect(embededPostfixOpExpr6.postfixOperator) == ">"
      try expect(embededPostfixOpExpr6.postfixExpression is IdentifierExpression).to.beTrue()
    }
  }
}
