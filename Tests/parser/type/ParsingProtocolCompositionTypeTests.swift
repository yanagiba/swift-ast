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

class ParsingProtocolCompositionTypeTests: XCTestCase {
  let parser = Parser()

  func testParseProtocolCompositionTypeWithoutName() {
    parser.setupTestCode("protocol<>")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertTrue(protocolCompositionType.protocols.isEmpty)
  }

  func testParseProtocolCompositionTypeWithoutNameButHasWhiteSpaces() {
    parser.setupTestCode("protocol<   >")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertTrue(protocolCompositionType.protocols.isEmpty)
  }

  func testParseProtocolCompositionTypeWithOneName() {
    parser.setupTestCode("protocol<foo>")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[0].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[0].names[0], "foo")
  }

  func testParseProtocolCompositionTypeWithOneTypeIdentifierThatContainsMultipleNames() {
    parser.setupTestCode("protocol<foo.bar.a.b.c>")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[0].names.count, 5)
    XCTAssertEqual(protocolCompositionType.protocols[0].names[0], "foo")
    XCTAssertEqual(protocolCompositionType.protocols[0].names[1], "bar")
    XCTAssertEqual(protocolCompositionType.protocols[0].names[2], "a")
    XCTAssertEqual(protocolCompositionType.protocols[0].names[3], "b")
    XCTAssertEqual(protocolCompositionType.protocols[0].names[4], "c")
  }

  func testParseProtocolCompositionTypeWithMultipleTypeIdentifiersWithWhiteSpaces() {
    parser.setupTestCode("protocol<foo    ,     bar,a    ,    b      ,    c>")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 5)
    XCTAssertEqual(protocolCompositionType.protocols[0].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[0].names[0], "foo")
    XCTAssertEqual(protocolCompositionType.protocols[1].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[1].names[0], "bar")
    XCTAssertEqual(protocolCompositionType.protocols[2].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[2].names[0], "a")
    XCTAssertEqual(protocolCompositionType.protocols[3].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[3].names[0], "b")
    XCTAssertEqual(protocolCompositionType.protocols[4].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[4].names[0], "c")
  }

  func testParseProtocolCompositionTypeWithMultipleTypeIdentifiersWithSomeHaveMultipleNames() {
    parser.setupTestCode("protocol<foo    ,     bar.a    ,    b      .    c.d>")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 3)
    XCTAssertEqual(protocolCompositionType.protocols[0].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[0].names[0], "foo")
    XCTAssertEqual(protocolCompositionType.protocols[1].names.count, 2)
    XCTAssertEqual(protocolCompositionType.protocols[1].names[0], "bar")
    XCTAssertEqual(protocolCompositionType.protocols[1].names[1], "a")
    XCTAssertEqual(protocolCompositionType.protocols[2].names.count, 3)
    XCTAssertEqual(protocolCompositionType.protocols[2].names[0], "b")
    XCTAssertEqual(protocolCompositionType.protocols[2].names[1], "c")
    XCTAssertEqual(protocolCompositionType.protocols[2].names[2], "d")
  }

  func testParseProtocolCompositionTypeWithTypeIdentifierThatHasGeneric() {
    parser.setupTestCode("protocol<X, A<B<C>>>")
    guard let protocolCompositionType = try? parser.parseProtocolCompositionType() else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
    XCTAssertEqual(protocolCompositionType.protocols.count, 2)
    XCTAssertEqual(protocolCompositionType.protocols[0].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[0].names[0], "X")
    XCTAssertEqual(protocolCompositionType.protocols[1].names.count, 1)
    XCTAssertEqual(protocolCompositionType.protocols[1].names[0], "A")
    guard let _ = protocolCompositionType.protocols[1].namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
  }
}
