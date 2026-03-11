/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

class LexerRegexLiteralTests: XCTestCase {

  // MARK: - Bare regex literals

  func testBareRegexBasicPattern() {
    lexAndTest("/abc/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "abc")
      XCTAssertEqual(raw, "/abc/")
    }
  }

  func testBareRegexEscapeSequence() {
    lexAndTest("/\\d+/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "\\d+")
      XCTAssertEqual(raw, "/\\d+/")
    }
  }

  func testBareRegexWithSpaces() {
    lexAndTest("/hello world/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "hello world")
      XCTAssertEqual(raw, "/hello world/")
    }
  }

  func testBareRegexCharacterClass() {
    lexAndTest("/[a-z]+/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "[a-z]+")
      XCTAssertEqual(raw, "/[a-z]+/")
    }
  }

  func testBareRegexBracketAwareness() {
    lexAndTest("/[a/b]/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "[a/b]")
      XCTAssertEqual(raw, "/[a/b]/")
    }
  }

  func testBareRegexNestedParens() {
    lexAndTest("/(foo/bar)/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "(foo/bar)")
      XCTAssertEqual(raw, "/(foo/bar)/")
    }
  }

  func testBareRegexQuantifiers() {
    lexAndTest("/a{2,3}/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "a{2,3}")
      XCTAssertEqual(raw, "/a{2,3}/")
    }
  }

  func testBareRegexEscapedSlash() {
    lexAndTest("/foo\\/bar/") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "foo\\/bar")
      XCTAssertEqual(raw, "/foo\\/bar/")
    }
  }

  func testBareRegexUnterminatedNewline() {
    // When bare regex fails (newline before closing /), the lexer backtracks
    // and lexes `/` as a prefix operator instead.
    lexAndTest("/abc\n") { t in
      guard case .prefixOperator("/") = t else {
        XCTFail("Expected prefix operator '/' after backtrack")
        return
      }
    }
  }

  func testBareRegexUnterminatedEOF() {
    // When bare regex fails (EOF before closing /), the lexer backtracks
    // and lexes `/` as a prefix operator instead.
    lexAndTest("/abc") { t in
      guard case .prefixOperator("/") = t else {
        XCTFail("Expected prefix operator '/' after backtrack")
        return
      }
    }
  }

  // MARK: - Extended regex literals (single hash)

  func testExtendedRegexBasic() {
    lexAndTest("#/abc/#") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "abc")
      XCTAssertEqual(raw, "#/abc/#")
    }
  }

  func testExtendedRegexSlashInside() {
    lexAndTest("#/foo/bar/#") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "foo/bar")
      XCTAssertEqual(raw, "#/foo/bar/#")
    }
  }

  func testExtendedRegexComplexPattern() {
    lexAndTest("#/[a-z]+\\.\\d{2,}/#") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "[a-z]+\\.\\d{2,}")
      XCTAssertEqual(raw, "#/[a-z]+\\.\\d{2,}/#")
    }
  }

  func testExtendedRegexUnterminated() {
    lexAndTest("#/abc") { t in
      guard case .invalid(.unterminatedRegexLiteral) = t else {
        XCTFail("Expected unterminated regex literal error")
        return
      }
    }
  }

  // MARK: - Multi-hash regex literals

  func testMultiHashRegexBasic() {
    lexAndTest("##/abc/##") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "abc")
      XCTAssertEqual(raw, "##/abc/##")
    }
  }

  func testMultiHashRegexSingleHashInside() {
    lexAndTest("##/foo/#bar/##") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "foo/#bar")
      XCTAssertEqual(raw, "##/foo/#bar/##")
    }
  }

  func testTripleHashRegex() {
    lexAndTest("###/a]b/##c/###") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "a]b/##c")
      XCTAssertEqual(raw, "###/a]b/##c/###")
    }
  }

  // MARK: - Multiline regex literals

  func testMultilineRegexBasic() {
    lexAndTest("#/\nabc\n/#") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "abc")
      XCTAssertEqual(raw, "#/\nabc\n/#")
    }
  }

  func testMultilineRegexMultipleLines() {
    lexAndTest("#/\nfoo\nbar\n/#") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "foo\nbar")
      XCTAssertEqual(raw, "#/\nfoo\nbar\n/#")
    }
  }

  func testMultilineRegexIndented() {
    lexAndTest("#/\n  hello\n  /#") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "  hello")
      XCTAssertEqual(raw, "#/\n  hello\n  /#")
    }
  }

  func testMultilineMultiHashRegex() {
    lexAndTest("##/\nfoo/#bar\n/##") { t in
      guard case let .regexLiteral(pattern, rawRepresentation: raw) = t else {
        XCTFail("Expected regex literal")
        return
      }
      XCTAssertEqual(pattern, "foo/#bar")
      XCTAssertEqual(raw, "##/\nfoo/#bar\n/##")
    }
  }

  func testMultilineRegexNewlineTerminatesIfSingleLine() {
    lexAndTest("#/abc\ndef/#") { t in
      guard case .invalid(.unterminatedRegexLiteral) = t else {
        XCTFail("Expected unterminated regex literal error")
        return
      }
    }
  }
}
