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

class ParsingIdentifierExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseSimpleIdentifierExpression() {
    parser.setupTestCode("foo")
    guard let idExpr = try? parser.parseIdentifierExpression() else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    XCTAssertNil(idExpr.generic)
  }

  func testParseIdentifierExpressionWithGeneric() {
    parser.setupTestCode("foo<bar>")
    guard let idExpr = try? parser.parseIdentifierExpression() else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
    guard let genericArgumentClause = idExpr.generic else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause.types.count, 1)
    guard genericArgumentClause.types[0] is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }
  }
}
