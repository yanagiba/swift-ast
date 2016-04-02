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

func specSuperclassExpression() {
  let parser = Parser()

  describe("Parse a superclass method expression") {
    $0.it("should return a superclass method expression") {
      parser.setupTestCode("super.foo")
      guard let superExpr = try? parser.parseSuperclassExpression() else {
        throw failure("Failed in getting a superclass expression.")
      }
      guard case let superExprKind = superExpr.kind where superExprKind == .Method else  {
        throw failure("Failed in getting a superclass method expression.")
      }
      try expect(superExpr.methodIdentifier) == "foo"
      try expect(superExpr.subscriptExpressions.isEmpty).to.beTrue()
    }
  }

  describe("Parse a superclass subscript expression") {
    $0.it("should return a superclass subscript expression") {
      parser.setupTestCode("super[0]")
      guard let superExpr = try? parser.parseSuperclassExpression() else {
        throw failure("Failed in getting a superclass expression.")
      }
      guard case let superExprKind = superExpr.kind where superExprKind == .Subscript else  {
        throw failure("Failed in getting a superclass subscript expression.")
      }
      try expect(superExpr.methodIdentifier) == ""
      try expect(superExpr.subscriptExpressions.count) == 1
    }
  }

  describe("Parse a superclass subscript expression with multiple an expression list") {
    $0.it("should return a superclass subscript expression with multiple an expression list") {
      parser.setupTestCode("super[0, 1, 5]")
      guard let superExpr = try? parser.parseSuperclassExpression() else {
        throw failure("Failed in getting a superclass expression.")
      }
      guard case let superExprKind = superExpr.kind where superExprKind == .Subscript else  {
        throw failure("Failed in getting a superclass subscript expression.")
      }
      try expect(superExpr.methodIdentifier) == ""
      try expect(superExpr.subscriptExpressions.count) == 3
    }
  }

  describe("Parse a superclass subscript expression with multiple an expression list that has variables") {
    $0.it("should return a superclass subscript expression with multiple an expression list that has variables") {
      parser.setupTestCode("super [ foo, 0, bar, 1, 5 ] ")
      guard let superExpr = try? parser.parseSuperclassExpression() else {
        throw failure("Failed in getting a superclass expression.")
      }
      guard case let superExprKind = superExpr.kind where superExprKind == .Subscript else  {
        throw failure("Failed in getting a superclass subscript expression.")
      }
      try expect(superExpr.methodIdentifier) == ""
      try expect(superExpr.subscriptExpressions.count) == 5
    }
  }

  describe("Parse a superclass initializer expression") {
    $0.it("should return a superclass initializer expression") {
      parser.setupTestCode("super.init")
      guard let superExpr = try? parser.parseSuperclassExpression() else {
        throw failure("Failed in getting a superclass expression.")
      }
      guard case let superExprKind = superExpr.kind where superExprKind == .Initializer else  {
        throw failure("Failed in getting a superclass initializer expression.")
      }
      try expect(superExpr.methodIdentifier) == ""
      try expect(superExpr.subscriptExpressions.isEmpty).to.beTrue()
    }
  }
}
