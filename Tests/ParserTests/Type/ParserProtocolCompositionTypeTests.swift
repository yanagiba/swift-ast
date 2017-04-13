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

class ParserProtocolCompositionTypeTests: XCTestCase {
  func testProtocolCompositionTypes() {
    parseTypeAndTest("foo & bar", "protocol<foo, bar>")
    parseTypeAndTest("foo& bar", "protocol<foo, bar>")
    parseTypeAndTest("foo&bar", "protocol<foo, bar>")
    parseTypeAndTest("foo    &     bar&a    &    b      &    c", "protocol<foo, bar, a, b, c>")
    parseTypeAndTest("foo    &     bar.a    &    b      .    c.d", "protocol<foo, bar.a, b.c.d>")
    parseTypeAndTest("X & A<B<C>>", "protocol<X, A<B<C>>>")
  }

  func testAmpAsPrefix() {
    parseTypeAndTest("foo &bar", "foo") // TODO: this needs to throw error somehow, right now, just make sure it doesn't produce a protocol composition
  }

  func testOldSyntax() {
    parseTypeAndTest("protocol<>", "protocol<>")
    parseTypeAndTest("protocol<   >", "protocol<>")
    parseTypeAndTest("protocol<foo>", "protocol<foo>")
    parseTypeAndTest("protocol<foo.bar.a.b.c>", "protocol<foo.bar.a.b.c>")
    parseTypeAndTest("protocol<foo    ,     bar,a    ,    b      ,    c>", "protocol<foo, bar, a, b, c>")
    parseTypeAndTest("protocol<foo    ,     bar.a    ,    b      .    c.d>", "protocol<foo, bar.a, b.c.d>")
    parseTypeAndTest("protocol<X, A<B<C>>>", "protocol<X, A<B<C>>>")
  }

  func testSourceRange() {
    parseTypeAndTest("X & A<B<C>>", "protocol<X, A<B<C>>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 12))
    })
    parseTypeAndTest("protocol<X, A<B<C>>>", "protocol<X, A<B<C>>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 21))
    })
  }

  static var allTests = [
    ("testProtocolCompositionTypes", testProtocolCompositionTypes),
    ("testOldSyntax", testOldSyntax),
    ("testAmpAsPrefix", testAmpAsPrefix),
    ("testSourceRange", testSourceRange),
  ]
}
