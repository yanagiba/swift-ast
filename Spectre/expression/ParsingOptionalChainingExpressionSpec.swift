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

func specOptionalChainingExpression() {
  let parser = Parser()

  describe("Parse one optional chaining expression") {
    $0.it("should return an optional chaining expression") {
      parser.setupTestCode("foo?")
      guard let optionalChainingExpr = try? parser.parseOptionalChainingExpression() else {
        throw failure("Failed in getting an optional chaining expression.")
      }
      guard let idExpr = optionalChainingExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }

  describe("Parse one optional chaining expression that wraps another optional chaining expression") {
    $0.it("should return an optional chaining expression that wraps another optional chaining expression") {
      parser.setupTestCode("foo??")
      guard let optionalChainingExpr = try? parser.parseOptionalChainingExpression() else {
        throw failure("Failed in getting an optional chaining expression.")
      }
      guard let innerOptionalChainingExpr = optionalChainingExpr.postfixExpression as? OptionalChainingExpression else {
        throw failure("Failed in getting an inner optional chaining expression.")
      }
      guard let idExpr = innerOptionalChainingExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }

  describe("Parse one optional chaining expression that wraps a forced value expression") {
    $0.it("should return an optional chaining expression that wraps a forced value expression") {
      parser.setupTestCode("foo!?")
      guard let optionalChainingExpr = try? parser.parseOptionalChainingExpression() else {
        throw failure("Failed in getting an optional chaining expression.")
      }
      guard let forcedValueExpr = optionalChainingExpr.postfixExpression as? ForcedValueExpression else {
        throw failure("Failed in getting a forced value expression.")
      }
      guard let idExpr = forcedValueExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }

  describe("Parse ? doesn't follow the postfix expression immediately") {
    $0.it("should return the postfix expression directly without wrapping into an optional chaining expression") {
      parser.setupTestCode("foo ?")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting a type.")
      }
      if expr is OptionalChainingExpression {
        throw failure("Should not be an optional chaining expression.")
      }
      guard let idExpr = expr as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }
}
