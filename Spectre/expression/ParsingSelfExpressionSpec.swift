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

func specSelfExpression() {
  let parser = Parser()

  describe("Parse a basic self expression") {
    $0.it("should return a self expression") {
      parser.setupTestCode("self")
      guard let selfExpr = try? parser.parseSelfExpression() else {
        throw failure("Failed in getting a self expression.")
      }
      guard case let selfExprKind = selfExpr.kind where selfExprKind == .Self else  {
        throw failure("Failed in getting a basic self expression.")
      }
      try expect(selfExpr.methodIdentifier) == ""
      try expect(selfExpr.subscriptExpressions.isEmpty).to.beTrue()
    }
  }

  describe("Parse a self method expression") {
    $0.it("should return a self method expression") {
      parser.setupTestCode("self.foo")
      guard let selfExpr = try? parser.parseSelfExpression() else {
        throw failure("Failed in getting a self expression.")
      }
      guard case let selfExprKind = selfExpr.kind where selfExprKind == .Method else  {
        throw failure("Failed in getting a self method expression.")
      }
      try expect(selfExpr.methodIdentifier) == "foo"
      try expect(selfExpr.subscriptExpressions.isEmpty).to.beTrue()
    }
  }

  describe("Parse a self subscript expression") {
    $0.it("should return a self subscript expression") {
      parser.setupTestCode("self[0]")
      guard let selfExpr = try? parser.parseSelfExpression() else {
        throw failure("Failed in getting a self expression.")
      }
      guard case let selfExprKind = selfExpr.kind where selfExprKind == .Subscript else  {
        throw failure("Failed in getting a self subscript expression.")
      }
      try expect(selfExpr.methodIdentifier) == ""
      try expect(selfExpr.subscriptExpressions.count) == 1
    }
  }

  describe("Parse a self subscript expression with multiple an expression list") {
    $0.it("should return a self subscript expression with multiple an expression list") {
      parser.setupTestCode("self[0, 1, 5]")
      guard let selfExpr = try? parser.parseSelfExpression() else {
        throw failure("Failed in getting a self expression.")
      }
      guard case let selfExprKind = selfExpr.kind where selfExprKind == .Subscript else  {
        throw failure("Failed in getting a self subscript expression.")
      }
      try expect(selfExpr.methodIdentifier) == ""
      try expect(selfExpr.subscriptExpressions.count) == 3
    }
  }

  describe("Parse a self subscript expression with multiple an expression list that has variables") {
    $0.it("should return a self subscript expression with multiple an expression list that has variables") {
      parser.setupTestCode("self [ foo, 0, bar, 1, 5 ] ")
      guard let selfExpr = try? parser.parseSelfExpression() else {
        throw failure("Failed in getting a self expression.")
      }
      guard case let selfExprKind = selfExpr.kind where selfExprKind == .Subscript else  {
        throw failure("Failed in getting a self subscript expression.")
      }
      try expect(selfExpr.methodIdentifier) == ""
      try expect(selfExpr.subscriptExpressions.count) == 5
    }
  }

  describe("Parse a self initializer expression") {
    $0.it("should return a self initializer expression") {
      parser.setupTestCode("self.init")
      guard let selfExpr = try? parser.parseSelfExpression() else {
        throw failure("Failed in getting a self expression.")
      }
      guard case let selfExprKind = selfExpr.kind where selfExprKind == .Initializer else  {
        throw failure("Failed in getting a self initializer expression.")
      }
      try expect(selfExpr.methodIdentifier) == ""
      try expect(selfExpr.subscriptExpressions.isEmpty).to.beTrue()
    }
  }
}
