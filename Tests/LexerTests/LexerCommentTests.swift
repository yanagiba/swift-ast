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

fileprivate func lexComments(_ content: String) -> Set<Comment> {
  let source = SourceFile(path: "LexerTests/LexerTests.swift", content: content)
  let lexer = Lexer(source: source)
  var index = 0
  while lexer.look(ahead: index).kind != .eof {
    index += 1
  }
  return lexer.comments
}

fileprivate func comment(_ content: String, line: Int = 1, column: Int = 1) -> Comment {
  let sourceLocation = SourceLocation(path: "LexerTests/LexerTests.swift", line: line, column: column)
  return Comment(content: content, location: sourceLocation)
}

class LexerCommentTests: XCTestCase {
  func testSingleLineComment() {
    let content = "// this is a comment"
    let expectedComments: Set = [comment(" this is a comment")]
    XCTAssertEqual(lexComments(content), expectedComments)

    lexAndTest(content, expectedColumn: 21) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testMultipleSingleLineComments() {
    let content = "//foo\n//bar"
    let expectedComments: Set = [comment("foo"), comment("bar", line: 2)]
    XCTAssertEqual(lexComments(content), expectedComments)

    lexAndTest(content, expectedLine: 2, expectedColumn: 6) {
      XCTAssertEqual($0, .eof)
    }

    lexAndTest(content, skipLineFeed: false, expectedLine: 2, expectedColumn: 6) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testSingleLineMultipleLineComment() { // TODO: this might deserve a better name
    let content = "/*comment*/"
    let expectedComments: Set = [comment("comment")]
    XCTAssertEqual(lexComments(content), expectedComments)

    lexAndTest(content, expectedColumn: 12) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testMultiLineMultipleLineComment() { // TODO: this might deserve a better name
    let content = "/* start comment\ncomment content #1\n// comment content #2\nend comment*/"
    let expectedComments: Set = [comment(" start comment\ncomment content #1\n// comment content #2\nend comment")]
    XCTAssertEqual(lexComments(content), expectedComments)

    lexAndTest(content, expectedLine: 4, expectedColumn: 14) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testNestedMultipleLineComments() {
    let content = "/* start comment 1 /* start comment 2 /* comment */ end comment 2*/ end comment 1*/"
    let expectedComments: Set = [comment(" start comment 1 /* start comment 2 /* comment */ end comment 2*/ end comment 1")]
    XCTAssertEqual(lexComments(content), expectedComments)

    lexAndTest(content, expectedLine: 1, expectedColumn: 84) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testMultipleLineCommentsOneNextToTheOther() {
    let content = "/*comment1*//*comment2*/\n/*comment3*/"
    let expectedComments: Set = [comment("comment1"), comment("comment2", column: 13), comment("comment3", line: 2)]
    XCTAssertEqual(lexComments(content), expectedComments)

    lexAndTest(content, expectedLine: 2, expectedColumn: 13) {
      XCTAssertEqual($0, .eof)
    }

    lexAndTest(content, skipLineFeed: false, expectedLine: 2, expectedColumn: 13) {
      XCTAssertEqual($0, .eof)
    }
  }

  func testUnbalanceMultipleLineComment() {
    lexAndTest(
      "/* start comment 1 /* start comment 2 end comment 1*/",
      expectedColumn: 54) {
      XCTAssertEqual($0, .invalid(.unexpectedEndOfFile))
    }
  }

  func testMultipleLineCommentTail() {
    lexAndTest("*/") {
      XCTAssertEqual($0, .invalid(.reserved))
    }
  }

  static var allTests = [
    ("testSingleLineComment", testSingleLineComment),
    ("testMultipleSingleLineComments", testMultipleSingleLineComments),
    ("testSingleLineMultipleLineComment", testSingleLineMultipleLineComment),
    ("testMultiLineMultipleLineComment", testMultiLineMultipleLineComment),
    ("testNestedMultipleLineComments", testNestedMultipleLineComments),
    ("testMultipleLineCommentsOneNextToTheOther", testMultipleLineCommentsOneNextToTheOther),
    ("testUnbalanceMultipleLineComment", testUnbalanceMultipleLineComment),
    ("testMultipleLineCommentTail", testMultipleLineCommentTail),
  ]
}
