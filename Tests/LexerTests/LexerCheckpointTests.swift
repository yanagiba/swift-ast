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

@testable import Lexer
@testable import Source

class LexerCheckpointTests: XCTestCase {
  func testCheckpoints() {
    let content = "#\n@\n_\n->"
    let source = SourceFile(path: "LexerTests/LexerCheckpointTests.swift", content: content)
    let lexer = Lexer(source: source)

    let hashCp = lexer.checkPoint()

    XCTAssertEqual(lexer.look().kind, .hash)

    lexer.advance()

    XCTAssertFalse(lexer.restore(fromCheckpoint: ""))

    XCTAssertEqual(lexer.look().kind, .at)

    let atCp = lexer.checkPoint()

    XCTAssertTrue(lexer.restore(fromCheckpoint: hashCp))

    XCTAssertEqual(lexer.look().kind, .hash)

    lexer.advance()

    XCTAssertEqual(lexer.look().kind, .at)

    lexer.advance()

    let underscoreCp = lexer.checkPoint()

    XCTAssertEqual(lexer.look().kind, .underscore)

    lexer.advance()

    XCTAssertEqual(lexer.look().kind, .arrow)

    XCTAssertTrue(lexer.restore(fromCheckpoint: atCp))

    XCTAssertEqual(lexer.look().kind, .at)

    XCTAssertTrue(lexer.restore(fromCheckpoint: hashCp))

    XCTAssertEqual(lexer.look().kind, .hash)

    lexer.advance()

    XCTAssertEqual(lexer.look().kind, .at)

    lexer.advance()

    XCTAssertEqual(lexer.look().kind, .underscore)

    XCTAssertFalse(lexer.restore(fromCheckpoint: ""))

    XCTAssertEqual(lexer.look().kind, .underscore)

    XCTAssertTrue(lexer.restore(fromCheckpoint: hashCp))

    XCTAssertEqual(lexer.look().kind, .hash)

    XCTAssertTrue(lexer.restore(fromCheckpoint: atCp))

    XCTAssertEqual(lexer.look().kind, .at)

    XCTAssertTrue(lexer.restore(fromCheckpoint: underscoreCp))

    XCTAssertEqual(lexer.look().kind, .underscore)
  }

  static var allTests = [
    ("testCheckpoints", testCheckpoints),
  ]
}
