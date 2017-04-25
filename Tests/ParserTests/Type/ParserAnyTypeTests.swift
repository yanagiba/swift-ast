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

class ParserAnyTypeTests: XCTestCase {
  func testAny() {
    parseTypeAndTest("Any", "Any")
  }

  func testMixedWithOtherTypes() {
    parseTypeAndTest("(Any) -> Any", "(Any) -> Any")
    parseTypeAndTest("[String: Any]", "Dictionary<String, Any>")
    parseTypeAndTest("Any?", "Optional<Any>")
    parseTypeAndTest("Any.Type", "Type<Any>")
  }

  func testSourceRange() {
    parseTypeAndTest("Any", "Any", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 4))
    })
  }

  static var allTests = [
    ("testAny", testAny),
    ("testMixedWithOtherTypes", testMixedWithOtherTypes),
    ("testSourceRange", testSourceRange),
  ]
}
