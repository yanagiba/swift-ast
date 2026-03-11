/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

@testable import AST
@testable import Parser

class ParserBoxedProtocolTypeTests: XCTestCase {
  func testBoxedProtocolType() {
    parseTypeAndTest("any Thing", "any Thing", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolTypeWithDotSeparatedName() {
    parseTypeAndTest("any Foo.Bar", "any Foo.Bar", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolTypeWithGenerics() {
    parseTypeAndTest("any Collection<Int>", "any Collection<Int>", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolComposition() {
    parseTypeAndTest("any Foo & Bar", "any protocol<Foo, Bar>", testClosure: { type in
      guard let boxedType = type as? BoxedProtocolType else {
        XCTFail("Expected BoxedProtocolType")
        return
      }
      XCTAssertTrue(boxedType.wrappedType is ProtocolCompositionType)
    })
  }

  func testBoxedProtocolTripleComposition() {
    parseTypeAndTest("any A & B & C", "any protocol<A, B, C>", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolWithGenericComposition() {
    parseTypeAndTest("any Sequence<Int> & Sendable", "any protocol<Sequence<Int>, Sendable>", testClosure: { type in
      XCTAssertTrue(type is BoxedProtocolType)
    })
  }

  func testBoxedProtocolInFunctionParam() {
    parseDeclarationAndTest("func foo(x: any Protocol)", "func foo(x: any Protocol)")
  }

  func testBoxedProtocolInReturnType() {
    parseDeclarationAndTest("func bar() -> any Collection<String>", "func bar() -> any Collection<String>")
  }

  func testBoxedProtocolInVariable() {
    parseDeclarationAndTest("var x: any Hashable", "var x: any Hashable")
  }
}
