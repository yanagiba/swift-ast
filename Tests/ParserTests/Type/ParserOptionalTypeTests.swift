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

class ParserOptionalTypeTests: XCTestCase {
  func testOptionalType() {
    parseTypeAndTest("foo?", "Optional<foo>")
  }

  func testTwoOptionalTypes() {
    parseTypeAndTest("foo??", "Optional<Optional<foo>>")
  }

  func testWrappingAnImplicitlyUnwrappedOptionalType() {
    parseTypeAndTest("foo!?", "Optional<ImplicitlyUnwrappedOptional<foo>>")
  }

  func testQuestionMarkDoesNotFollowTheTypeImmeidately() {
    parseTypeAndTest("foo !", "foo")
  }

  func testSourceRange() {
    parseTypeAndTest("foo?", "Optional<foo>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 5))
    })
    parseTypeAndTest("foo??", "Optional<Optional<foo>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 6))
    })
    parseTypeAndTest("foo!?", "Optional<ImplicitlyUnwrappedOptional<foo>>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 6))
    })
  }

  static var allTests = [
    ("testOptionalType", testOptionalType),
    ("testTwoOptionalTypes", testTwoOptionalTypes),
    ("testWrappingAnImplicitlyUnwrappedOptionalType", testWrappingAnImplicitlyUnwrappedOptionalType),
    ("testQuestionMarkDoesNotFollowTheTypeImmeidately", testQuestionMarkDoesNotFollowTheTypeImmeidately),
    ("testSourceRange", testSourceRange),
  ]
}
