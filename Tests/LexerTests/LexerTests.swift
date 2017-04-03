/*
   Copyright 2015-2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

@testable import Lexer
@testable import Source

class LexerTests: XCTestCase {
  func testEmptyContent() {
    lexAndTest("") {
      XCTAssertEqual($0, .eof)
    }
  }

  func testArrow() {
    lexAndTest("->") {
      XCTAssertEqual($0, .arrow)
    }
    lexAndTest("->", index: 1, expectedColumn: 3) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testAssignmentOperator() {
    lexAndTest("=") {
      XCTAssertEqual($0, .assignmentOperator)
    }
    lexAndTest("==") {
      XCTAssertEqual($0, .prefixOperator("=="))
    }
  }

  func testAt() {
    lexAndTest("@") {
      XCTAssertEqual($0, .at)
    }
    lexAndTest("@@") {
      XCTAssertEqual($0, .at)
    }
  }

  func testHash() {
    lexAndTest("#") {
      XCTAssertEqual($0, .hash)
    }
    lexAndTest("##") {
      XCTAssertEqual($0, .hash)
    }
  }

  func testColon() {
    lexAndTest(":") {
      XCTAssertEqual($0, .colon)
    }
    lexAndTest("::") {
      XCTAssertEqual($0, .colon)
    }
  }

  func testComma() {
    lexAndTest(",") {
      XCTAssertEqual($0, .comma)
    }
    lexAndTest(",,") {
      XCTAssertEqual($0, .comma)
    }
  }

  func testDot() {
    lexAndTest(".") {
      XCTAssertEqual($0, .dot)
    }
    lexAndTest("..") {
      XCTAssertEqual($0, .prefixOperator(".."))
    }
  }

  func testSemicolon() {
    lexAndTest(";") {
      XCTAssertEqual($0, .semicolon)
    }
    lexAndTest(";;") {
      XCTAssertEqual($0, .semicolon)
    }
  }

  func testUnderscore() {
    lexAndTest("_") {
      XCTAssertEqual($0, .underscore)
    }
    lexAndTest("_a") {
      XCTAssertEqual($0, .identifier("_a"))
    }
  }

  func testLeftParen() {
    lexAndTest("(") {
      XCTAssertEqual($0, .leftParen)
    }
    lexAndTest("((") {
      XCTAssertEqual($0, .leftParen)
    }
  }

  func testRightParen() {
    lexAndTest(")") {
      XCTAssertEqual($0, .rightParen)
    }
    lexAndTest("))") {
      XCTAssertEqual($0, .rightParen)
    }
  }

  func testLeftBrace() {
    lexAndTest("{") {
      XCTAssertEqual($0, .leftBrace)
    }
    lexAndTest("{{") {
      XCTAssertEqual($0, .leftBrace)
    }
  }

  func testRightBrace() {
    lexAndTest("}") {
      XCTAssertEqual($0, .rightBrace)
    }
    lexAndTest("}}") {
      XCTAssertEqual($0, .rightBrace)
    }
  }

  func testLeftSquare() {
    lexAndTest("[") {
      XCTAssertEqual($0, .leftSquare)
    }
    lexAndTest("[[") {
      XCTAssertEqual($0, .leftSquare)
    }
  }

  func testRightSquare() {
    lexAndTest("]") {
      XCTAssertEqual($0, .rightSquare)
    }
    lexAndTest("]]") {
      XCTAssertEqual($0, .rightSquare)
    }
  }

  // TODO: have to come back to the tests for cr, lf, spaces, and eof

  func testAllSpacesAreSkipped() {
    lexAndTest("         ", expectedColumn: 10) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testLineFeed() {
    lexAndTest("a\n", index: 1, skipLineFeed: false, expectedColumn: 2) {
      XCTAssertEqual($0, .lineFeed)
    }
  }

  // TODO: Error cases

  func testSegmentShowUpAtInvalidLocation() {
    [
      "\\", // backslash
      "\u{1}", // unsegmented
      "\u{1DC7}", // identifier body
      "\u{E01EE}" // operator body
    ].forEach { e in
      lexAndTest(e) { t in
        XCTAssertEqual(t, .invalid(.badChar))
      }
    }
  }

  static var allTests = [
    ("testEmptyContent", testEmptyContent),
    ("testArrow", testArrow),
    ("testAssignmentOperator", testAssignmentOperator),
    ("testAt", testAt),
    ("testHash", testHash),
    ("testColon", testColon),
    ("testComma", testComma),
    ("testDot", testDot),
    ("testSemicolon", testSemicolon),
    ("testUnderscore", testUnderscore),
    ("testLeftParen", testLeftParen),
    ("testRightParen", testRightParen),
    ("testLeftBrace", testLeftBrace),
    ("testRightBrace", testRightBrace),
    ("testLeftSquare", testLeftSquare),
    ("testRightSquare", testRightSquare),
    ("testAllSpacesAreSkipped", testAllSpacesAreSkipped),
    ("testLineFeed", testLineFeed),
    ("testSegmentShowUpAtInvalidLocation", testSegmentShowUpAtInvalidLocation),
  ]
}
