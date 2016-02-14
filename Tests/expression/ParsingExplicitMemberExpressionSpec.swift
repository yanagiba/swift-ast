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

func specExplicitMemberExpression() {
  let parser = Parser()

  describe("Parse an explicit member expression for tuple") {
    $0.it("should return an explicit member expression for tuple") {
      let testMembers = ["0", "1", "23"]
      for testMember in testMembers {
        parser.setupTestCode("foo.\(testMember)")
        guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
          throw failure("Failed in getting an explicit member expression.")
        }
        try expect(explicitMemberExpr.kind) == .Tuple
        guard let idExpr = explicitMemberExpr.postfixExpression as? IdentifierExpression else {
          throw failure("Failed in getting an identifier expression.")
        }
        try expect(idExpr.identifier) == "foo"
        guard let integerLiteralExpression = explicitMemberExpr.decimalIntegerLiteralExpression else {
          throw failure("Failed in getting an integer literal expression.")
        }
        try expect(integerLiteralExpression.kind) == .Decimal
        try expect(integerLiteralExpression.rawString) == testMember
        try expect(explicitMemberExpr.identifierExpression).to.beNil()
      }
    }
  }

  describe("Parse an explicit member expression for named type with only identifier") {
    $0.it("should return an explicit member expression for named type with only identifier") {
      parser.setupTestCode("foo.someProperty")
      guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
        throw failure("Failed in getting an explicit member expression.")
      }
      try expect(explicitMemberExpr.kind) == .NamedType
      guard let idExpr = explicitMemberExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      try expect(explicitMemberExpr.decimalIntegerLiteralExpression).to.beNil()
      guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(memberIdExpr.identifier) == "someProperty"
      try expect(memberIdExpr.generic).to.beNil()
    }
  }

  describe("Parse an explicit member expression for named type with identifier and generic argument clause") {
    $0.it("should return an explicit member expression for named type with identifier and generic argument clause") {
      parser.setupTestCode("foo.someProperty<U>")
      guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
        throw failure("Failed in getting an explicit member expression.")
      }
      try expect(explicitMemberExpr.kind) == .NamedType
      guard let idExpr = explicitMemberExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
      try expect(explicitMemberExpr.decimalIntegerLiteralExpression).to.beNil()
      guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(memberIdExpr.identifier) == "someProperty"
      guard let genericArgumentClause = memberIdExpr.generic else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClause.types.count) == 1
      guard genericArgumentClause.types[0] is TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }
    }
  }

  describe("Parse nested explicit member expressions that both have generic argument clauses") {
    $0.it("should return correct explicit member expressions") {
      parser.setupTestCode("foo.someProperty<U>.anotherProperty<V>")
      guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
        throw failure("Failed in getting an explicit member expression.")
      }
      try expect(explicitMemberExpr.kind) == .NamedType
      try expect(explicitMemberExpr.decimalIntegerLiteralExpression).to.beNil()
      guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(memberIdExpr.identifier) == "anotherProperty"
      guard let genericArgumentClause = memberIdExpr.generic else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClause.types.count) == 1
      guard genericArgumentClause.types[0] is TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }

      guard let explicitMemberExpr1 = explicitMemberExpr.postfixExpression as? ExplicitMemberExpression else {
        throw failure("Failed in getting an explicit member expression.")
      }
      try expect(explicitMemberExpr1.kind) == .NamedType
      guard let idExpr1 = explicitMemberExpr1.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr1.identifier) == "foo"
      try expect(explicitMemberExpr1.decimalIntegerLiteralExpression).to.beNil()
      guard let memberIdExpr1 = explicitMemberExpr1.identifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(memberIdExpr1.identifier) == "someProperty"
      guard let genericArgumentClause1 = memberIdExpr1.generic else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClause1.types.count) == 1
      guard genericArgumentClause1.types[0] is TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }
    }
  }

  describe("Parse nested explicit member expressions") {
    $0.it("should return nested explicit member expressions") {
      parser.setupTestCode("locations.0.latitude")
      guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
        throw failure("Failed in getting an explicit member expression.")
      }

      try expect(explicitMemberExpr.kind) == .NamedType
      try expect(explicitMemberExpr.decimalIntegerLiteralExpression).to.beNil()
      guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(memberIdExpr.identifier) == "latitude"
      try expect(memberIdExpr.generic).to.beNil()

      guard let explicitMemberExpr1 = explicitMemberExpr.postfixExpression as? ExplicitMemberExpression else {
        throw failure("Failed in getting an explicit member expression.")
      }
      try expect(explicitMemberExpr1.kind) == .Tuple
      guard let idExpr = explicitMemberExpr1.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "locations"
      guard let integerLiteralExpression = explicitMemberExpr1.decimalIntegerLiteralExpression else {
        throw failure("Failed in getting an integer literal expression.")
      }
      try expect(integerLiteralExpression.kind) == .Decimal
      try expect(integerLiteralExpression.rawString) == "0"
      try expect(explicitMemberExpr1.identifierExpression).to.beNil()
    }
  }
}
