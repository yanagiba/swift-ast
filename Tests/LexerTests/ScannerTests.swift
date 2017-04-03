/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class ScannerTests: XCTestCase {
  func testEmptyContent() {
    let scanner = Scanner(content: "")
    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), .eof)
    XCTAssertNil(scanner.peek())
    scanner.advance()
    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 1)
  }

  func testCharacters() {
    let scanner = Scanner(content: "rs")
    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("r", .identifierHead))
    XCTAssertEqual(scanner.peek(), "s")
    scanner.advance()
    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("s", .identifierHead))
    XCTAssertNil(scanner.peek())
  }

  func testEmoji() {
    let scanner = Scanner(content: "🔪🍣")
    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("🔪", .identifierHead))
    XCTAssertEqual(scanner.peek(), "🍣")
    scanner.advance()
    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("🍣", .identifierHead))
    XCTAssertNil(scanner.peek())
  }

  func testRyuichiLovesSushiAtCafé() {
    let scanner = Scanner(content: "龍一 \u{1F496}\0 🍣\n@\r\ncaf\u{E9}")

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("龍", .identifierHead))
    XCTAssertEqual(scanner.peek(), "一")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("一", .identifierHead))
    XCTAssertEqual(scanner.peek(), " ")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 3)
    XCTAssertEqual(scanner.scan(), char(" ", .space))
    XCTAssertEqual(scanner.peek(), "💖")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 4)
    XCTAssertEqual(scanner.scan(), char("💖", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\0")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 5)
    XCTAssertEqual(scanner.scan(), char("\0", .space))
    XCTAssertEqual(scanner.peek(), " ")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 5)
    XCTAssertEqual(scanner.scan(), char(" ", .space))
    XCTAssertEqual(scanner.peek(), "🍣")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 6)
    XCTAssertEqual(scanner.scan(), char("🍣", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 7)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "@")

    scanner.advance()

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("@", .at))
    XCTAssertEqual(scanner.peek(), "\r")

    scanner.advance()

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("\r", .carriageReturn))
    XCTAssertEqual(scanner.peek(), "\n")

    scanner.advance()

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "c")

    scanner.advance()

    XCTAssertEqual(scanner.line, 3)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("c", .identifierHead))
    XCTAssertEqual(scanner.peek(), "a")

    scanner.advance()

    XCTAssertEqual(scanner.line, 3)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("a", .identifierHead))
    XCTAssertEqual(scanner.peek(), "f")

    scanner.advance()

    XCTAssertEqual(scanner.line, 3)
    XCTAssertEqual(scanner.column, 3)
    XCTAssertEqual(scanner.scan(), char("f", .identifierHead))
    XCTAssertEqual(scanner.peek(), "é")

    scanner.advance()

    XCTAssertEqual(scanner.line, 3)
    XCTAssertEqual(scanner.column, 4)
    XCTAssertEqual(scanner.scan(), char("é", .identifierHead))
    XCTAssertNil(scanner.peek())
  }

  func testCheckpoints() {
    let scanner = Scanner(content: "ab\nc\nd")

    XCTAssertFalse(scanner.restore(fromCheckpoint: ""))

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("a", .identifierHead))
    XCTAssertEqual(scanner.peek(), "b")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("b", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    let cp12 = scanner.checkPoint()

    XCTAssertTrue(scanner.restore(fromCheckpoint: cp12))

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("b", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 3)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "c")

    XCTAssertTrue(scanner.restore(fromCheckpoint: cp12))

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("b", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    scanner.advance(by: 2)

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("c", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    let cp21 = scanner.checkPoint()

    scanner.advance()

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "d")

    XCTAssertTrue(scanner.restore(fromCheckpoint: cp21))

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("c", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    scanner.advance()

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "d")

    XCTAssertTrue(scanner.restore(fromCheckpoint: cp12))

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 2)
    XCTAssertEqual(scanner.scan(), char("b", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")

    scanner.advance()

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 3)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "c")

    XCTAssertFalse(scanner.restore(fromCheckpoint: ""))

    XCTAssertEqual(scanner.line, 1)
    XCTAssertEqual(scanner.column, 3)
    XCTAssertEqual(scanner.scan(), char("\n", .lineFeed))
    XCTAssertEqual(scanner.peek(), "c")

    XCTAssertTrue(scanner.restore(fromCheckpoint: cp21))

    XCTAssertEqual(scanner.line, 2)
    XCTAssertEqual(scanner.column, 1)
    XCTAssertEqual(scanner.scan(), char("c", .identifierHead))
    XCTAssertEqual(scanner.peek(), "\n")
  }

  static var allTests = [
    ("testEmptyContent", testEmptyContent),
    ("testCharacters", testCharacters),
    ("testEmoji", testEmoji),
    ("testRyuichiLovesSushiAtCafé", testRyuichiLovesSushiAtCafé),
    ("testCheckpoints", testCheckpoints),
  ]

  private func char(_ str: String, _ role: Role) -> Char {
    guard let unicodeScalar = UnicodeScalar(str) else {
      XCTFail("Failed in converting string `\(str)` to UnicodeScalar.")
      return .eof
    }
    return Char(unicodeScalar: unicodeScalar, role: role)
  }
}
