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

class ParserImplicitlyUnwrappedOptionalTypeTests: XCTestCase {
  func testImplicitlyUnwrappedOptionalType() {
    parseTypeAndTest("foo!", "ImplicitlyUnwrappedOptional<foo>")
  }

  func testTwoImplicitlyUnwrappedOptionalTypes() {
    parseTypeAndTest("foo!!", "ImplicitlyUnwrappedOptional<ImplicitlyUnwrappedOptional<foo>>")
  }

  func testWrappingAnOptionalType() {
    parseTypeAndTest("foo?!", "ImplicitlyUnwrappedOptional<Optional<foo>>")
  }

  func testExclamationMarkDoesNotFollowTheTypeImmeidately() {
    parseTypeAndTest("foo !", "foo")
  }

  func testSourceRange() {
    parseTypeAndTest("foo!", "ImplicitlyUnwrappedOptional<foo>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 5))
    })
    parseTypeAndTest("foo!!", "ImplicitlyUnwrappedOptional<ImplicitlyUnwrappedOptional<foo>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 6))
    })
    parseTypeAndTest("foo?!", "ImplicitlyUnwrappedOptional<Optional<foo>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 6))
    })
  }

  static var allTests = [
    ("testImplicitlyUnwrappedOptionalType", testImplicitlyUnwrappedOptionalType),
    ("testTwoImplicitlyUnwrappedOptionalTypes", testTwoImplicitlyUnwrappedOptionalTypes),
    ("testWrappingAnOptionalType", testWrappingAnOptionalType),
    ("testExclamationMarkDoesNotFollowTheTypeImmeidately", testExclamationMarkDoesNotFollowTheTypeImmeidately),
    ("testSourceRange", testSourceRange),
  ]
}
