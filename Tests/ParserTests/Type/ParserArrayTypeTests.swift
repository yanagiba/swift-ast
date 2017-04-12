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

class ParserArrayTypeTests: XCTestCase {
  func testOneDimension() {
    parseTypeAndTest("[foo.bar]", "Array<foo.bar>")
  }

  func testTwoDimensions() {
    parseTypeAndTest("[[foo]]", "Array<Array<foo>>")
  }

  func testThreeDimensions() {
    parseTypeAndTest("[[[Int]]]", "Array<Array<Array<Int>>>")
  }

  func testElementAsDictionaryType() {
    parseTypeAndTest("[[a: b]]", "Array<Dictionary<a, b>>")
  }

  func testSourceRange() {
    parseTypeAndTest("[foo.bar]", "Array<foo.bar>", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 10))
    })
  }

  static var allTests = [
    ("testOneDimension", testOneDimension),
    ("testTwoDimensions", testTwoDimensions),
    ("testThreeDimensions", testThreeDimensions),
    ("testElementAsDictionaryType", testElementAsDictionaryType),
    ("testSourceRange", testSourceRange),
  ]
}
