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

func specBinaryOperatorExpression() {
  let parser = Parser()

  describe("Parse a binary operator expression") {
    $0.it("should return a binary operator expression") {
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
          throw failure("Failed in getting a binary operator expression for code `\(testCode)`.")
        }
        try expect(biOpExpr.binaryOperator) == testString
        try expect(biOpExpr.leftExpression is IdentifierExpression).to.beTrue()
        try expect(biOpExpr.rightExpression is IdentifierExpression).to.beTrue()
      }
    }
  }

  describe("Parse a binary operator expression without spaces") {
    $0.it("should return a binary operator expression as usual") {
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
          throw failure("Failed in getting a binary operator expression for code `\(testCode)`.")
        }
        try expect(biOpExpr.binaryOperator) == testString
        try expect(biOpExpr.leftExpression is IdentifierExpression).to.beTrue()
        try expect(biOpExpr.rightExpression is IdentifierExpression).to.beTrue()
      }
    }
  }

  describe("Parse a binary operator expression with lhs as try operator") {
    $0.it("should return a binary operator expression with lhs as try operator") {
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
          throw failure("Failed in getting a binary operator expression for code `\(testCode)`.")
        }
        try expect(biOpExpr.binaryOperator) == testString
        try expect(biOpExpr.leftExpression is TryOperatorExpression).to.beTrue()
        try expect(biOpExpr.rightExpression is IdentifierExpression).to.beTrue()
      }
    }
  }
}
