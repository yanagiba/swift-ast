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

typealias RequirementType = GenericParameterClause.Requirement.RequirementType

class ParsingGenericParameterClauseTests: XCTestCase {
  let parser = Parser()

  func testParseGenericParameterClauseWithOneParameter() {
    parser.setupTestCode("<S1>")
    guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
      XCTFail("Failed in getting a generic parameter clause.")
      return
    }
    XCTAssertEqual(genericParameterClause.parameters.count, 1)
    XCTAssertEqual(genericParameterClause.parameters[0].typeName, "S1")
    XCTAssertNil(genericParameterClause.parameters[0].typeIdentifier)
    XCTAssertNil(genericParameterClause.parameters[0].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.requirements.count, 0)
  }

  func testParseGenericParameterClauseWithMultipleParameters() {
    parser.setupTestCode("<S1, S2, S3>")
    guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
      XCTFail("Failed in getting a generic parameter clause.")
      return
    }
    XCTAssertEqual(genericParameterClause.parameters.count, 3)
    XCTAssertEqual(genericParameterClause.parameters[0].typeName, "S1")
    XCTAssertNil(genericParameterClause.parameters[0].typeIdentifier)
    XCTAssertNil(genericParameterClause.parameters[0].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.parameters[1].typeName, "S2")
    XCTAssertNil(genericParameterClause.parameters[1].typeIdentifier)
    XCTAssertNil(genericParameterClause.parameters[1].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.parameters[2].typeName, "S3")
    XCTAssertNil(genericParameterClause.parameters[2].typeIdentifier)
    XCTAssertNil(genericParameterClause.parameters[2].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.requirements.count, 0)
  }

  func testParseGenericParameterClauseWithMultipleParametersThatOneHasTypeIdentifierAndOneHasProtocolCompositionType() {
    parser.setupTestCode("<S1, S2: SequenceType, S3: protocol<T1, T2>>")
    guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
      XCTFail("Failed in getting a generic parameter clause.")
      return
    }
    XCTAssertEqual(genericParameterClause.parameters.count, 3)
    XCTAssertEqual(genericParameterClause.parameters[0].typeName, "S1")
    XCTAssertNil(genericParameterClause.parameters[0].typeIdentifier)
    XCTAssertNil(genericParameterClause.parameters[0].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.parameters[1].typeName, "S2")
    guard let typeIdentifier = genericParameterClause.parameters[1].typeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertNil(genericParameterClause.parameters[1].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.parameters[2].typeName, "S3")
    XCTAssertNil(genericParameterClause.parameters[2].typeIdentifier)
    guard let protocolCompositionType = genericParameterClause.parameters[2].protocolCompositionType else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 2)
    XCTAssertEqual(genericParameterClause.requirements.count, 0)
  }

  func testParseGenericParameterClauseWithMultipleParametersAndRequirements() {
    parser.setupTestCode("<T, S1: SequenceType, S2: SequenceType where T: C, T: protocol<P1, P2>, S1.Generator.Element == S2.Generator.Element>")
    guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
      XCTFail("Failed in getting a generic parameter clause.")
      return
    }
    XCTAssertEqual(genericParameterClause.parameters.count, 3)
    XCTAssertEqual(genericParameterClause.parameters[0].typeName, "T")
    XCTAssertNil(genericParameterClause.parameters[0].typeIdentifier)
    XCTAssertNil(genericParameterClause.parameters[0].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.parameters[1].typeName, "S1")
    guard let typeIdentifier1 = genericParameterClause.parameters[1].typeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier1.names.count, 1)
    XCTAssertEqual(typeIdentifier1.names[0], "SequenceType")
    XCTAssertNil(genericParameterClause.parameters[1].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.parameters[2].typeName, "S2")
    guard let typeIdentifier2 = genericParameterClause.parameters[2].typeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier2.names.count, 1)
    XCTAssertEqual(typeIdentifier2.names[0], "SequenceType")
    XCTAssertNil(genericParameterClause.parameters[2].protocolCompositionType)
    XCTAssertEqual(genericParameterClause.requirements.count, 3)
    let requirement0 = genericParameterClause.requirements[0]
    XCTAssertEqual(requirement0.requirementType, RequirementType.Conformance)
    let reqTypeIdentifier0 = requirement0.typeIdentifier
    XCTAssertEqual(reqTypeIdentifier0.names.count, 1)
    XCTAssertEqual(reqTypeIdentifier0.names[0], "T")
    guard let reqType0 = requirement0.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }
    XCTAssertEqual(reqType0.names.count, 1)
    XCTAssertEqual(reqType0.names[0], "C")
    let requirement1 = genericParameterClause.requirements[1]
    XCTAssertEqual(requirement1.requirementType, RequirementType.Conformance)
    let reqTypeIdentifier1 = requirement1.typeIdentifier
    XCTAssertEqual(reqTypeIdentifier1.names.count, 1)
    XCTAssertEqual(reqTypeIdentifier1.names[0], "T")
    guard let reqType1 = requirement1.type as? ProtocolCompositionType else {
      XCTFail("Failed in getting a protocol composition type")
      return
    }
    XCTAssertEqual(reqType1.protocols.count, 2)
    let requirement2 = genericParameterClause.requirements[2]
    XCTAssertEqual(requirement2.requirementType, RequirementType.SameType)
    let reqTypeIdentifier2 = requirement2.typeIdentifier
    XCTAssertEqual(reqTypeIdentifier2.names.count, 3)
    XCTAssertEqual(reqTypeIdentifier2.names[0], "S1")
    XCTAssertEqual(reqTypeIdentifier2.names[1], "Generator")
    XCTAssertEqual(reqTypeIdentifier2.names[2], "Element")
    guard let reqType2 = requirement2.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier")
      return
    }
    XCTAssertEqual(reqType2.names.count, 3)
    XCTAssertEqual(reqType2.names[0], "S2")
    XCTAssertEqual(reqType2.names[1], "Generator")
    XCTAssertEqual(reqType2.names[2], "Element")
  }
}
