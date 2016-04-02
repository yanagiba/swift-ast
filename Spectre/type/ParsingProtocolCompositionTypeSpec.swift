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

func specProtocolCompositionType() {
  let parser = Parser()

  describe("Parse protocol composition type w/o a name") {
    $0.it("should an empty protocol composition type") {
      parser.setupTestCode("protocol<>")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.isEmpty).to.beTrue()
    }
  }

  describe("Parse protocol composition type w/o a name but white spaces") {
    $0.it("should also be an empty protocol composition type") {
      parser.setupTestCode("protocol<   >")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.isEmpty).to.beTrue()
    }
  }

  describe("Parse protocol composition type with one name") {
    $0.it("should return a protocol composition type with that name") {
      parser.setupTestCode("protocol<foo>")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.count) == 1
      try expect(protocolCompositionType.protocols[0].names.count) == 1
      try expect(protocolCompositionType.protocols[0].names[0]) == "foo"
    }
  }

  describe("Parse protocol composition type with one type identifier that contains multiple names") {
    $0.it("should return one type identifier with many names") {
      parser.setupTestCode("protocol<foo.bar.a.b.c>")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.count) == 1
      try expect(protocolCompositionType.protocols[0].names.count) == 5
      try expect(protocolCompositionType.protocols[0].names[0]) == "foo"
      try expect(protocolCompositionType.protocols[0].names[1]) == "bar"
      try expect(protocolCompositionType.protocols[0].names[2]) == "a"
      try expect(protocolCompositionType.protocols[0].names[3]) == "b"
      try expect(protocolCompositionType.protocols[0].names[4]) == "c"
    }
  }

  describe("Parse protocol composition type with multiple type identifiers with white spaces") {
    $0.it("should return those type identifiers and ignore the white spaces") {
      parser.setupTestCode("protocol<foo    ,     bar,a    ,    b      ,    c>")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.count) == 5
      try expect(protocolCompositionType.protocols[0].names.count) == 1
      try expect(protocolCompositionType.protocols[0].names[0]) == "foo"
      try expect(protocolCompositionType.protocols[1].names.count) == 1
      try expect(protocolCompositionType.protocols[1].names[0]) == "bar"
      try expect(protocolCompositionType.protocols[2].names.count) == 1
      try expect(protocolCompositionType.protocols[2].names[0]) == "a"
      try expect(protocolCompositionType.protocols[3].names.count) == 1
      try expect(protocolCompositionType.protocols[3].names[0]) == "b"
      try expect(protocolCompositionType.protocols[4].names.count) == 1
      try expect(protocolCompositionType.protocols[4].names[0]) == "c"
    }
  }

  describe("Parse protocol composition type with multiple type identifiers with some type identifiers with multiple names") {
    $0.it("should return those type identifiers and type identifiers and names") {
      parser.setupTestCode("protocol<foo    ,     bar.a    ,    b      .    c.d>")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.count) == 3
      try expect(protocolCompositionType.protocols[0].names.count) == 1
      try expect(protocolCompositionType.protocols[0].names[0]) == "foo"
      try expect(protocolCompositionType.protocols[1].names.count) == 2
      try expect(protocolCompositionType.protocols[1].names[0]) == "bar"
      try expect(protocolCompositionType.protocols[1].names[1]) == "a"
      try expect(protocolCompositionType.protocols[2].names.count) == 3
      try expect(protocolCompositionType.protocols[2].names[0]) == "b"
      try expect(protocolCompositionType.protocols[2].names[1]) == "c"
      try expect(protocolCompositionType.protocols[2].names[2]) == "d"
    }
  }

  describe("Parse protocol composition type with a type identifier that has generic") {
    $0.it("should return those type identifiers and the generic") {
      parser.setupTestCode("protocol<X, A<B<C>>>")
      guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
        throw failure("Failed in getting a protocol composition type.")
      }
      try expect(protocolCompositionType.protocols.count) == 2
      try expect(protocolCompositionType.protocols[0].names.count) == 1
      try expect(protocolCompositionType.protocols[0].names[0]) == "X"
      try expect(protocolCompositionType.protocols[1].names.count) == 1
      try expect(protocolCompositionType.protocols[1].names[0]) == "A"
      guard let _ = protocolCompositionType.protocols[1].namedTypes[0].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
    }
  }
}
