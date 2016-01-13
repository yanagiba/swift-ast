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

func specGenericParameterClause() {
  let parser = Parser()

  describe("Parse generic parameter clause with one parameter") {
    $0.it("should return that name") {
      parser.setupTestCode("<S1>")
      guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
        throw failure("Failed in getting a generic parameter clause.")
      }
      try expect(genericParameterClause.parameters.count) == 1
      try expect(genericParameterClause.parameters[0].typeName) == "S1"
      try expect(genericParameterClause.parameters[0].typeIdentifier).to.beNil()
      try expect(genericParameterClause.parameters[0].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.requirements.count) == 0
    }
  }

  describe("Parse generic parameter clause with multiple parameters") {
    $0.it("should return the names of these parameters") {
      parser.setupTestCode("<S1, S2, S3>")
      guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
        throw failure("Failed in getting a generic parameter clause.")
      }
      try expect(genericParameterClause.parameters.count) == 3
      try expect(genericParameterClause.parameters[0].typeName) == "S1"
      try expect(genericParameterClause.parameters[0].typeIdentifier).to.beNil()
      try expect(genericParameterClause.parameters[0].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.parameters[1].typeName) == "S2"
      try expect(genericParameterClause.parameters[1].typeIdentifier).to.beNil()
      try expect(genericParameterClause.parameters[1].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.parameters[2].typeName) == "S3"
      try expect(genericParameterClause.parameters[2].typeIdentifier).to.beNil()
      try expect(genericParameterClause.parameters[2].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.requirements.count) == 0
    }
  }

  describe("Parse generic parameter clause with multiple parameters, and one has type identifier, and one has protocol composition type") {
    $0.it("should return the names of these parameters, and type identifier or protocol composition type if exists") {
      parser.setupTestCode("<S1, S2: SequenceType, S3: protocol<T1, T2>>")
      guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
        throw failure("Failed in getting a generic parameter clause.")
      }
      try expect(genericParameterClause.parameters.count) == 3
      try expect(genericParameterClause.parameters[0].typeName) == "S1"
      try expect(genericParameterClause.parameters[0].typeIdentifier).to.beNil()
      try expect(genericParameterClause.parameters[0].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.parameters[1].typeName) == "S2"
      guard let typeIdentifier = genericParameterClause.parameters[1].typeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(genericParameterClause.parameters[1].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.parameters[2].typeName) == "S3"
      try expect(genericParameterClause.parameters[2].typeIdentifier).to.beNil()
      guard let protocolCompositionType = genericParameterClause.parameters[2].protocolCompositionType else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.count) == 2
      try expect(genericParameterClause.requirements.count) == 0
    }
  }

  describe("Parse generic parameter clause with multiple parameters and requirements") {
    $0.it("should return the names of these parameters") {
      parser.setupTestCode("<T, S1: SequenceType, S2: SequenceType where T: C, T: protocol<P1, P2>, S1.Generator.Element == S2.Generator.Element>")
      guard let genericParameterClause = try? parser.parseGenericParameterClause() else {
        throw failure("Failed in getting a generic parameter clause.")
      }
      try expect(genericParameterClause.parameters.count) == 3
      try expect(genericParameterClause.parameters[0].typeName) == "T"
      try expect(genericParameterClause.parameters[0].typeIdentifier).to.beNil()
      try expect(genericParameterClause.parameters[0].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.parameters[1].typeName) == "S1"
      guard let typeIdentifier1 = genericParameterClause.parameters[1].typeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier1.names.count) == 1
      try expect(typeIdentifier1.names[0]) == "SequenceType"
      try expect(genericParameterClause.parameters[1].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.parameters[2].typeName) == "S2"
      guard let typeIdentifier2 = genericParameterClause.parameters[2].typeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier2.names.count) == 1
      try expect(typeIdentifier2.names[0]) == "SequenceType"
      try expect(genericParameterClause.parameters[2].protocolCompositionType).to.beNil()
      try expect(genericParameterClause.requirements.count) == 3
      let requirement0 = genericParameterClause.requirements[0]
      try expect(requirement0.requirementType) == .Conformance
      let reqTypeIdentifier0 = requirement0.typeIdentifier
      try expect(reqTypeIdentifier0.names.count) == 1
      try expect(reqTypeIdentifier0.names[0]) == "T"
      guard let reqType0 = requirement0.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }
      try expect(reqType0.names.count) == 1
      try expect(reqType0.names[0]) == "C"
      let requirement1 = genericParameterClause.requirements[1]
      try expect(requirement1.requirementType) == .Conformance
      let reqTypeIdentifier1 = requirement1.typeIdentifier
      try expect(reqTypeIdentifier1.names.count) == 1
      try expect(reqTypeIdentifier1.names[0]) == "T"
      guard let reqType1 = requirement1.type as? ProtocolCompositionType else {
        throw failure("Failed in getting a protocol composition type")
      }
      try expect(reqType1.protocols.count) == 2
      let requirement2 = genericParameterClause.requirements[2]
      try expect(requirement2.requirementType) == .SameType
      let reqTypeIdentifier2 = requirement2.typeIdentifier
      try expect(reqTypeIdentifier2.names.count) == 3
      try expect(reqTypeIdentifier2.names[0]) == "S1"
      try expect(reqTypeIdentifier2.names[1]) == "Generator"
      try expect(reqTypeIdentifier2.names[2]) == "Element"
      guard let reqType2 = requirement2.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }
      try expect(reqType2.names.count) == 3
      try expect(reqType2.names[0]) == "S2"
      try expect(reqType2.names[1]) == "Generator"
      try expect(reqType2.names[2]) == "Element"
    }
  }
}
