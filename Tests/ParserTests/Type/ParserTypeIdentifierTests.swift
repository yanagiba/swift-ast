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

class ParserTypeIdentifierTests: XCTestCase {
  func testOneName() {
    parseTypeAndTest("foo", "foo")
  }

  func testMultipleNames() {
    parseTypeAndTest("foo.bar.a.b.c", "foo.bar.a.b.c")
    parseTypeAndTest("foo    .     bar.a    .    b      .    c", "foo.bar.a.b.c")
  }

  func testGenericArgumentClause() {
    parseTypeAndTest("A<B>", "A<B>")
    parseTypeAndTest("A<B>.C<D>.E<F>", "A<B>.C<D>.E<F>")
    parseTypeAndTest("A<B>.C<D<X<Y<Z>>>>.E<F>", "A<B>.C<D<X<Y<Z>>>>.E<F>")
  }

  func testSourceRange() {
    parseTypeAndTest("foo", "foo", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 4))
    })
    parseTypeAndTest("foo    .     bar.a    .    b      .    c", "foo.bar.a.b.c", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 41))
    })
    parseTypeAndTest("A<B>", "A<B>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 5))
    })
    parseTypeAndTest("A<B>.C<D<X<Y<Z>>>>.E<F>", "A<B>.C<D<X<Y<Z>>>>.E<F>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 24))
    })
  }

  static var allTests = [
    ("testOneName", testOneName),
    ("testMultipleNames", testMultipleNames),
    ("testGenericArgumentClause", testGenericArgumentClause),
    ("testSourceRange", testSourceRange),
  ]
}
