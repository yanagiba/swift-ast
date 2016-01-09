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

func specMetatypeType() {
  let parser = Parser()

  describe("Parse a Type Metatype type that starts with type identifier") {
    $0.it("should be a type metatype type") {
      parser.setupTestCode("foo.Type")
      guard let metatypeType = try? parser.parseMetatypeType() else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType.meta) == .Type
      guard let typeIdentifier = metatypeType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse a Protocol Metatype type that starts with type identifier") {
    $0.it("should be a protocol metatype type") {
      parser.setupTestCode("foo.Protocol")
      guard let metatypeType = try? parser.parseMetatypeType() else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType.meta) == .Protocol
      guard let typeIdentifier = metatypeType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse embedded Metatype types that starts with type identifier") {
    $0.it("should be several metatype types") {
      parser.setupTestCode("foo.Type.Protocol.Type.Protocol")
      guard let metatypeType = try? parser.parseMetatypeType() else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType.meta) == .Protocol
      guard let metatypeType1 = metatypeType.type as? MetatypeType else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType1.meta) == .Type
      guard let metatypeType2 = metatypeType1.type as? MetatypeType else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType2.meta) == .Protocol
      guard let metatypeType3 = metatypeType2.type as? MetatypeType else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType3.meta) == .Type
      guard let typeIdentifier = metatypeType3.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse a Type Metatype type that starts with array type") {
    $0.it("should be a type metatype type") {
      parser.setupTestCode("[foo].Type")
      guard let metatypeType = try? parser.parseMetatypeType() else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType.meta) == .Type
      guard metatypeType.type is ArrayType else {
        throw failure("Failed in getting an array type.")
      }
    }
  }

  describe("Parse a Protocol Metatype type that starts with optional type") {
    $0.it("should be a protocol metatype type") {
      parser.setupTestCode("foo?.Protocol")
      guard let metatypeType = try? parser.parseMetatypeType() else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType.meta) == .Protocol
      guard metatypeType.type is OptionalType else {
        throw failure("Failed in getting an optional type.")
      }
    }
  }

  describe("Parse embedded Metatype types that starts with protocol composition type") {
    $0.it("should be several metatype types") {
      parser.setupTestCode("protocol<foo, bar>.Type.Protocol.Type.Protocol")
      guard let metatypeType = try? parser.parseMetatypeType() else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType.meta) == .Protocol
      guard let metatypeType1 = metatypeType.type as? MetatypeType else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType1.meta) == .Type
      guard let metatypeType2 = metatypeType1.type as? MetatypeType else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType2.meta) == .Protocol
      guard let metatypeType3 = metatypeType2.type as? MetatypeType else {
        throw failure("Failed in getting a metatype type.")
      }
      try expect(metatypeType3.meta) == .Type
      guard metatypeType3.type is ProtocolCompositionType else {
        throw failure("Failed in getting a protocol composition type.")
      }
    }
  }


}
