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

class ParserOptionalPatternTests: XCTestCase {
  func testOptional() {
    parsePatternAndTest("foo?", "foo?", testClosure: { pttrn in
      guard let optionalPattern = pttrn as? OptionalPattern else {
        XCTFail("Failed in parsing an optional pattern.")
        return
      }

      XCTAssertEqual(optionalPattern.identifier, "foo")
    })
  }

  func testWildcardOptional() {
    parsePatternAndTest("_?", "_?", forPatternMatching: true, testClosure: { pttrn in
      guard let optionalPattern = pttrn as? OptionalPattern else {
        XCTFail("Failed in parsing an optional pattern.")
        return
      }

      XCTAssertEqual(optionalPattern.identifier, "_")
    })
  }

  static var allTests = [
    ("testOptional", testOptional),
    ("testWildcardOptional", testWildcardOptional),
  ]
}
