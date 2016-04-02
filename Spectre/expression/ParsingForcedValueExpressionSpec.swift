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

func specForcedValueExpression() {
  let parser = Parser()

  describe("Parse one forced value expression") {
    $0.it("should return a forced value expression") {
      parser.setupTestCode("foo!")
      guard let forcedValueExpr = try? parser.parseForcedValueExpression() else {
        throw failure("Failed in getting a forced value expression.")
      }
      guard let idExpr = forcedValueExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }

  describe("Parse one forced value expression that wraps another forced value expression") {
    $0.it("should return a forced value expression that wraps another forced value expression") {
      parser.setupTestCode("foo!!")
      guard let forcedValueExpr = try? parser.parseForcedValueExpression() else {
        throw failure("Failed in getting a forced value expression.")
      }
      guard let innerForcedValueExpr = forcedValueExpr.postfixExpression as? ForcedValueExpression else {
        throw failure("Failed in getting an inner forced value expression.")
      }
      guard let idExpr = innerForcedValueExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }

  describe("Parse one forced value expression that wraps an optional chaining expression") {
    $0.it("should return a forced value expression that wraps an optional chaining expression") {
      parser.setupTestCode("foo?!")
      guard let forcedValueExpr = try? parser.parseForcedValueExpression() else {
        throw failure("Failed in getting a forced value expression.")
      }
      guard let optionalChainingExpression = forcedValueExpr.postfixExpression as? OptionalChainingExpression else {
        throw failure("Failed in getting an optional chaining expression.")
      }
      guard let idExpr = optionalChainingExpression.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }

  describe("Parse ! doesn't follow the postfix expression immediately") {
    $0.it("should return the postfix expression directly without wrapping into a forced value expression") {
      parser.setupTestCode("foo !")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting a type.")
      }
      if expr is ForcedValueExpression {
        throw failure("Should not be a forced value expression.")
      }
      guard let idExpr = expr as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }
}
