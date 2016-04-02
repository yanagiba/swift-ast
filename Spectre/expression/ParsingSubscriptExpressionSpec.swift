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

func specSubscriptExpression() {
  let parser = Parser()

  describe("Parse a subscript expression") {
    $0.it("should return a subscript expression") {
      parser.setupTestCode("foo[0]")
      guard let subscriptExpr = try? parser.parseSubscriptExpression() else {
        throw failure("Failed in getting a subscript expression.")
      }
      guard let idExpr = subscriptExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      try expect(subscriptExpr.indexExpressions.count) == 1
    }
  }

  describe("Parse a subscript expression with a list of multiple expressions") {
    $0.it("should return a subscript expression with a list of multiple expressions") {
      parser.setupTestCode("foo[0, 1, 5]")
      guard let subscriptExpr = try? parser.parseSubscriptExpression() else {
        throw failure("Failed in getting a subscript expression.")
      }
      guard let idExpr = subscriptExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      try expect(subscriptExpr.indexExpressions.count) == 3
    }
  }

  describe("Parse a subscript expression with a list of multiple expressions that also contain variables") {
    $0.it("should return a subscript expression with a list of multiple expressions that also contain variables") {
      parser.setupTestCode("foo [ a, 0, b, 1, 5 ] ")
      guard let subscriptExpr = try? parser.parseSubscriptExpression() else {
        throw failure("Failed in getting a subscript expression.")
      }
      guard let idExpr = subscriptExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      try expect(subscriptExpr.indexExpressions.count) == 5
    }
  }
}
