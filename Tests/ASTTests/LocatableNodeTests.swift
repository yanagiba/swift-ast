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

@testable import AST
@testable import Source

class LocatableNodeTests : XCTestCase {
  func testNodeWithoutSettingRange() {
    let newNode = LocatableNode()
    XCTAssertEqual(newNode.sourceRange, .INVALID)
    XCTAssertEqual(newNode.textDescription, "<<invalid>>")
  }

  func testSettingRange() {
    let startLoc = SourceLocation(path: "locatable-node-test-start-loc", line: 1, column: 2)
    let endLoc = SourceLocation.DUMMY
    let range = SourceRange(start: startLoc, end: endLoc)
    let node = LocatableNode()
    node.setSourceRange(range)
    XCTAssertEqual(node.sourceRange, range)
    XCTAssertEqual(node.sourceRange.start, startLoc)
    XCTAssertEqual(node.sourceRange.end, endLoc)
    XCTAssertEqual(node.textDescription, "")
  }

  func testSettingLocations() {
    let startLoc = SourceLocation.INVALID
    let endLoc = SourceLocation.DUMMY
    let node = LocatableNode()
    node.setSourceRange(startLoc, endLoc)
    XCTAssertEqual(node.sourceRange, SourceRange(start: startLoc, end: endLoc))
    XCTAssertEqual(node.sourceRange.start, startLoc)
    XCTAssertEqual(node.sourceRange.end, endLoc)
    XCTAssertEqual(node.textDescription, "<<invalid>>")
  }

  static var allTests = [
    ("testNodeWithoutSettingRange", testNodeWithoutSettingRange),
    ("testSettingRange", testSettingRange),
    ("testSettingLocations", testSettingLocations),
  ]
}
