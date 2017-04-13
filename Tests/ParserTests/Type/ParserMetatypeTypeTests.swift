/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class ParserMetatypeTypeTests: XCTestCase {
  func testWithTypeIdentifier() {
    parseTypeAndTest("foo.Type", "Type<foo>")
    parseTypeAndTest("foo.Protocol", "Protocol<foo>")
  }

  func testWithContainerTypes() {
    parseTypeAndTest("[foo].Type", "Type<Array<foo>>")
    parseTypeAndTest("[foo: bar].Protocol", "Protocol<Dictionary<foo, bar>>")
  }

  func testWithOptionalTypes() {
    parseTypeAndTest("foo?.Type", "Type<Optional<foo>>")
    parseTypeAndTest("foo!.Protocol", "Protocol<ImplicitlyUnwrappedOptional<foo>>")
    parseTypeAndTest("foo?!.Type", "Type<ImplicitlyUnwrappedOptional<Optional<foo>>>")
    parseTypeAndTest("foo!?.Protocol", "Protocol<Optional<ImplicitlyUnwrappedOptional<foo>>>")
  }

  func testEmbedded() {
    parseTypeAndTest("foo.Type.Protocol.Type.Protocol", "Protocol<Type<Protocol<Type<foo>>>>")
    parseTypeAndTest("protocol<foo, bar>.Type.Protocol.Type.Protocol", "Protocol<Type<Protocol<Type<protocol<foo, bar>>>>>")
  }

  func testSourceRange() {
    parseTypeAndTest("foo.Type", "Type<foo>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 9))
    })
    parseTypeAndTest("[foo: bar].Protocol", "Protocol<Dictionary<foo, bar>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 20))
    })
    parseTypeAndTest("foo?!.Type", "Type<ImplicitlyUnwrappedOptional<Optional<foo>>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 11))
    })
    parseTypeAndTest("foo.Type.Protocol.Type.Protocol", "Protocol<Type<Protocol<Type<foo>>>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 32))
    })
  }

  static var allTests = [
    ("testWithTypeIdentifier", testWithTypeIdentifier),
    ("testWithContainerTypes", testWithContainerTypes),
    ("testWithOptionalTypes", testWithOptionalTypes),
    ("testEmbedded", testEmbedded),
    ("testSourceRange", testSourceRange),
  ]
}
