/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

@testable import Source

class SourceRangeTests : XCTestCase {
  func testDummyRange() {
    let range = SourceRange.EMPTY
    XCTAssertEqual(range, SourceRange(start: .DUMMY, end: .DUMMY))
    XCTAssertEqual(range.start.path, "dummy")
    XCTAssertEqual(range.start.line, 0)
    XCTAssertEqual(range.start.column, 0)
    XCTAssertEqual(range.end.path, "dummy")
    XCTAssertEqual(range.end.line, 0)
    XCTAssertEqual(range.end.column, 0)
    XCTAssertEqual(range.description, "dummy:0:0-0:0")
  }

  static var allTests = [
    ("testDummyRange", testDummyRange),
  ]
}
