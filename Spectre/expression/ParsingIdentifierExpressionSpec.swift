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

func specIdentifierExpression() {
  let parser = Parser()

  describe("Parse a simple identifier expression") {
    $0.it("should return an identifier expression") {
      parser.setupTestCode("foo")
      guard let idExpr = try? parser.parseIdentifierExpression() else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      try expect(idExpr.generic).to.beNil()
    }
  }

  describe("Parse an identifier expression with generic") {
    $0.it("should return an identifier expression and its generic argument clause") {
      parser.setupTestCode("foo<bar>")
      guard let idExpr = try? parser.parseIdentifierExpression() else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      guard let genericArgumentClause = idExpr.generic else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClause.types.count) == 1
      guard genericArgumentClause.types[0] is TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }
    }
  }
}
