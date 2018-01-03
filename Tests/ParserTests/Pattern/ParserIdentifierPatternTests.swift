/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserIdentifierPatternTests: XCTestCase {
  func testParseIdentifierPattern() {
    parsePatternAndTest("foo", "foo", testClosure: { pttrn in
      guard let idPattern = pttrn as? IdentifierPattern else {
        XCTFail("Failed in parsing an id pattern.")
        return
      }

      ASTTextEqual(idPattern.identifier, "foo")
      XCTAssertNil(idPattern.typeAnnotation)
    })
  }

  func testKeywordsUsedAsIdentifier() {
    let keywords = [
      "Any",
      "Self",
      "get",
      "set",
      "left",
      "right",
      "open",
      "prefix",
      "postfix",
    ]
    for keyword in keywords {
      parsePatternAndTest(keyword, keyword, testClosure: { pttrn in
        guard let idPattern = pttrn as? IdentifierPattern else {
          XCTFail("Failed in parsing an id pattern.")
          return
        }

        ASTTextEqual(idPattern.identifier, keyword)
        XCTAssertNil(idPattern.typeAnnotation)
      })
    }
  }

  func testTypeAnnotation() {
    parsePatternAndTest("foo   :   Bar", "foo: Bar", testClosure: { pttrn in
      guard let idPattern = pttrn as? IdentifierPattern else {
        XCTFail("Failed in parsing an id pattern.")
        return
      }

      ASTTextEqual(idPattern.identifier, "foo")
      XCTAssertNotNil(idPattern.typeAnnotation)
    })
  }

  func testSourceRange() {
    parsePatternAndTest("foo", "foo", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 4))
    })
    parsePatternAndTest("foo   :   Bar", "foo: Bar", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 14))
    })
  }

  static var allTests = [
    ("testParseIdentifierPattern", testParseIdentifierPattern),
    ("testKeywordsUsedAsIdentifier", testKeywordsUsedAsIdentifier),
    ("testTypeAnnotation", testTypeAnnotation),
    ("testSourceRange", testSourceRange),
  ]
}
