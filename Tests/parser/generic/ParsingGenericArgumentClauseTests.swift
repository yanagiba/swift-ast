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

class ParsingGenericArgumentClauseTests: XCTestCase {
  let parser = Parser()

  func testParseGenericArgumentClauseWithOneType() {
    parser.setupTestCode("<String>")
    guard let genericArgumentClause = try? parser.parseGenericArgumentClause() else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause.types.count, 1)
    guard genericArgumentClause.types[0] is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }
  }

  func testParseGenericArgumentClauseWithMultipleTypes() {
    parser.setupTestCode("<[Int], protocol<String, Double>>")
    guard let genericArgumentClause = try? parser.parseGenericArgumentClause() else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause.types.count, 2)
    guard genericArgumentClause.types[0] is ArrayType else {
      XCTFail("Failed in getting an arrayType")
      return
    }
    guard genericArgumentClause.types[1] is ProtocolCompositionType else {
      XCTFail("Failed in getting a protocolCompositionType")
      return
    }
  }

  func testParseGenericArgumentClauseWithGenericArgumentClauses() {
    parser.setupTestCode("<A<B, protocol<C, D>>>")
    guard let genericArgumentClause = try? parser.parseGenericArgumentClause() else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(genericArgumentClause.types.count, 1)
    guard let typeIdentifierA = genericArgumentClause.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifierA.namedTypes.count, 1)
    XCTAssertEqual(typeIdentifierA.namedTypes[0].name, "A")
    guard let genericArgumentClauseA = typeIdentifierA.namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }

    XCTAssertEqual(genericArgumentClauseA.types.count, 2)
    guard let typeIdentifierB = genericArgumentClauseA.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifierB.namedTypes[0].name, "B")
    XCTAssertNil(typeIdentifierB.namedTypes[0].generic)
    guard let protocolCompositionType = genericArgumentClauseA.types[1] as? ProtocolCompositionType else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 2)
  }
}
