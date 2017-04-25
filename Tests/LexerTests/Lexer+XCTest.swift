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

func lex(_ content: String, index: Int = 0, skipLineFeed: Bool = true) -> Token {
  let source = SourceFile(path: "LexerTests/LexerTests.swift", content: content)
  let lexer = Lexer(source: source)
  return lexer.look(ahead: index, skipLineFeed: skipLineFeed)
}

func lexAndTest(_ content: String,
  index: Int = 0,
  skipLineFeed: Bool = true,
  expectedLine: Int = 1,
  expectedColumn: Int = 1,
  tokenKindTestClosure: (Token.Kind) -> Void) {
  let token = lex(content, index: index, skipLineFeed: skipLineFeed)
  XCTAssertEqual(token.sourceRange.start.path, "LexerTests/LexerTests.swift")
  XCTAssertEqual(token.sourceRange.start.line, expectedLine)
  XCTAssertEqual(token.sourceRange.start.column, expectedColumn)
  XCTAssertEqual(token.sourceRange.end.path, "LexerTests/LexerTests.swift")
  if token.sourceRange.end.line == expectedLine {
    XCTAssertTrue(token.sourceRange.end.column >= expectedColumn)
  } else {
    XCTAssertTrue(token.sourceRange.end.line > expectedLine)
  }

  tokenKindTestClosure(token.kind)
}
