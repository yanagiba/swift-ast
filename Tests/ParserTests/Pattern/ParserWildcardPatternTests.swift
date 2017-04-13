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

@testable import AST

class ParserWildcardPatternTests: XCTestCase {
  func testParseWildcardPattern() {
    parsePatternAndTest("_", "_", testClosure: { pttrn in
      guard let wildcardPattern = pttrn as? WildcardPattern else {
        XCTFail("Failed in parsing a wildcard pattern.")
        return
      }

      XCTAssertNil(wildcardPattern.typeAnnotation)
    })
  }

  func testTypeAnnotation() {
    parsePatternAndTest("_   :   Foo", "_: Foo", testClosure: { pttrn in
      guard let wildcardPattern = pttrn as? WildcardPattern else {
        XCTFail("Failed in parsing a wildcard pattern.")
        return
      }

      XCTAssertNotNil(wildcardPattern.typeAnnotation)
    })
  }

  func testSourceRange() {
    parsePatternAndTest("_", "_", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 2))
    })
    parsePatternAndTest("_   :   Foo", "_: Foo", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 12))
    })
  }

  static var allTests = [
    ("testParseWildcardPattern", testParseWildcardPattern),
    ("testTypeAnnotation", testTypeAnnotation),
    ("testSourceRange", testSourceRange),
  ]
}
