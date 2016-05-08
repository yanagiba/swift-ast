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

class ParsingExplicitMemberExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseExplicitMemberExpressionForTuple() {
    let testMembers = ["0", "1", "23"]
    for testMember in testMembers {
      parser.setupTestCode("foo.\(testMember)")
      guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
        XCTFail("Failed in getting an explicit member expression.")
        return
      }
      XCTAssertEqual(explicitMemberExpr.kind, ExplicitMemberExpression.Kind.Tuple)
      guard let idExpr = explicitMemberExpr.postfixExpression as? IdentifierExpression else {
        XCTFail("Failed in getting an identifier expression.")
        return
      }
      XCTAssertEqual(idExpr.identifier, "foo")
      guard let integerLiteralExpression = explicitMemberExpr.decimalIntegerLiteralExpression else {
        XCTFail("Failed in getting an integer literal expression.")
        return
      }
      XCTAssertEqual(integerLiteralExpression.kind, IntegerLiteralExpression.Kind.Decimal)
      XCTAssertEqual(integerLiteralExpression.rawString, testMember)
      XCTAssertNil(explicitMemberExpr.identifierExpression)
    }
  }

  func testParseExplicitMemberExpressionForNamedTypeWithOnlyIdentifier() {
    parser.setupTestCode("foo.someProperty")
    guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
      XCTFail("Failed in getting an explicit member expression.")
      return
    }
    XCTAssertEqual(explicitMemberExpr.kind, ExplicitMemberExpression.Kind.NamedType)
    guard let idExpr = explicitMemberExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    XCTAssertNil(explicitMemberExpr.decimalIntegerLiteralExpression)
    guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(memberIdExpr.identifier, "someProperty")
    XCTAssertNil(memberIdExpr.generic)
  }

  func testParseExplicitMemberExpressionForNamedTypeWithIdentifierAndGenericArgumentClause() {
    parser.setupTestCode("foo.someProperty<U>")
    guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
      XCTFail("Failed in getting an explicit member expression.")
      return
    }
    XCTAssertEqual(explicitMemberExpr.kind, ExplicitMemberExpression.Kind.NamedType)
    guard let idExpr = explicitMemberExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    XCTAssertNil(explicitMemberExpr.decimalIntegerLiteralExpression)
    guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(memberIdExpr.identifier, "someProperty")
    guard let genericArgumentClause = memberIdExpr.generic else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause.types.count, 1)
    guard genericArgumentClause.types[0] is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }
  }

  func testParseExplicitMemberExpressionThatBothHaveGenericArgumentClauses() {
    parser.setupTestCode("foo.someProperty<U>.anotherProperty<V>")
    guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
      XCTFail("Failed in getting an explicit member expression.")
      return
    }
    XCTAssertEqual(explicitMemberExpr.kind, ExplicitMemberExpression.Kind.NamedType)
    XCTAssertNil(explicitMemberExpr.decimalIntegerLiteralExpression)
    guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(memberIdExpr.identifier, "anotherProperty")
    guard let genericArgumentClause = memberIdExpr.generic else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause.types.count, 1)
    guard genericArgumentClause.types[0] is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }

    guard let explicitMemberExpr1 = explicitMemberExpr.postfixExpression as? ExplicitMemberExpression else {
      XCTFail("Failed in getting an explicit member expression.")
      return
    }
    XCTAssertEqual(explicitMemberExpr1.kind, ExplicitMemberExpression.Kind.NamedType)
    guard let idExpr1 = explicitMemberExpr1.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr1.identifier, "foo")
    XCTAssertNil(explicitMemberExpr1.decimalIntegerLiteralExpression)
    guard let memberIdExpr1 = explicitMemberExpr1.identifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(memberIdExpr1.identifier, "someProperty")
    guard let genericArgumentClause1 = memberIdExpr1.generic else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause1.types.count, 1)
    guard genericArgumentClause1.types[0] is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }
  }

  func testParseNestedExplicitMemberExpression() {
    parser.setupTestCode("locations.0.latitude")
    guard let explicitMemberExpr = try? parser.parseExplicitMemberExpression() else {
      XCTFail("Failed in getting an explicit member expression.")
      return
    }

    XCTAssertEqual(explicitMemberExpr.kind, ExplicitMemberExpression.Kind.NamedType)
    XCTAssertNil(explicitMemberExpr.decimalIntegerLiteralExpression)
    guard let memberIdExpr = explicitMemberExpr.identifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(memberIdExpr.identifier, "latitude")
    XCTAssertNil(memberIdExpr.generic)

    guard let explicitMemberExpr1 = explicitMemberExpr.postfixExpression as? ExplicitMemberExpression else {
      XCTFail("Failed in getting an explicit member expression.")
      return
    }
    XCTAssertEqual(explicitMemberExpr1.kind, ExplicitMemberExpression.Kind.Tuple)
    guard let idExpr = explicitMemberExpr1.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "locations")
    guard let integerLiteralExpression = explicitMemberExpr1.decimalIntegerLiteralExpression else {
      XCTFail("Failed in getting an integer literal expression.")
      return
    }
    XCTAssertEqual(integerLiteralExpression.kind, IntegerLiteralExpression.Kind.Decimal)
    XCTAssertEqual(integerLiteralExpression.rawString, "0")
    XCTAssertNil(explicitMemberExpr1.identifierExpression)
  }
}
