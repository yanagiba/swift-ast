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

class ParsingMetatypeTypeTest: XCTestCase {
  let parser = Parser()

  func testParseMetatypeTypeStartsWithTypeIdentifier() {
    parser.setupTestCode("foo.Type")
    guard let metatypeType = try? parser.parseMetatypeType() else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType.meta.rawValue, "Type")
    guard let typeIdentifier = metatypeType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testParseProtocolMetatypeTypeThatStartsWithTypeIdentifier() {
    parser.setupTestCode("foo.Protocol")
    guard let metatypeType = try? parser.parseMetatypeType() else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType.meta.rawValue, "Protocol")
    guard let typeIdentifier = metatypeType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testParseEmbeddedMetatypeTypeThatStartsWithTypeIdentifier() {
    parser.setupTestCode("foo.Type.Protocol.Type.Protocol")
    guard let metatypeType = try? parser.parseMetatypeType() else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType.meta.rawValue, "Protocol")
    guard let metatypeType1 = metatypeType.type as? MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType1.meta.rawValue, "Type")
    guard let metatypeType2 = metatypeType1.type as? MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType2.meta.rawValue, "Protocol")
    guard let metatypeType3 = metatypeType2.type as? MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType3.meta.rawValue, "Type")
    guard let typeIdentifier = metatypeType3.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testParseTypeMetatypeTypeThatStartsWithArrayType() {
    parser.setupTestCode("[foo].Type")
    guard let metatypeType = try? parser.parseMetatypeType() else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType.meta.rawValue, "Type")
    guard metatypeType.type is ArrayType else {
      XCTFail("Failed in getting an array type.")
      return
    }
  }

  func testParseProtocolMetatypeTypeThatStartsWithOptionalType() {
    parser.setupTestCode("foo?.Protocol")
    guard let metatypeType = try? parser.parseMetatypeType() else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType.meta.rawValue, "Protocol")
    guard metatypeType.type is OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
  }

  func testParseEmbeddedMetatypeTypeThatStartsWithProtocolCompositionType() {
    parser.setupTestCode("protocol<foo, bar>.Type.Protocol.Type.Protocol")
    guard let metatypeType = try? parser.parseMetatypeType() else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType.meta.rawValue, "Protocol")
    guard let metatypeType1 = metatypeType.type as? MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType1.meta.rawValue, "Type")
    guard let metatypeType2 = metatypeType1.type as? MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType2.meta.rawValue, "Protocol")
    guard let metatypeType3 = metatypeType2.type as? MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
    XCTAssertEqual(metatypeType3.meta.rawValue, "Type")
    guard metatypeType3.type is ProtocolCompositionType else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
  }
}
