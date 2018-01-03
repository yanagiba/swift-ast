/*
   Copyright 2015-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

class LexerStringLiteralTests: XCTestCase {
  func testEmptyStringLiteral() {
    lexAndTest("\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\"")
    }
  }

  func testSingleCharacter() {
    lexAndTest("\"a\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "a")
      XCTAssertEqual(r, "\"a\"")
    }
  }

  func testContainsEmptyCharacters() {
    lexAndTest("\"   \"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "   ")
      XCTAssertEqual(r, "\"   \"")
    }
  }

  func testContainsSpacesInBetween() {
    let content = "\"   \"  \"abc\""
    lexAndTest(content) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "   ")
      XCTAssertEqual(r, "\"   \"")
    }
    lexAndTest(content, index: 1, expectedColumn: 8) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "abc")
      XCTAssertEqual(r, "\"abc\"")
    }
  }

  func testTwoStringLiterals() {
    let content = "\"   \"\"abc\""
    lexAndTest(content) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "   ")
      XCTAssertEqual(r, "\"   \"")
    }
    lexAndTest(content, index: 1, expectedColumn: 6) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "abc")
      XCTAssertEqual(r, "\"abc\"")
    }
  }

  func testTwoStringLiteralsWithAnIdentifierInBetween() {
    let content = "\"   \"xyz\"abc\""
    lexAndTest(content) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "   ")
      XCTAssertEqual(r, "\"   \"")
    }
    lexAndTest(content, index: 1, expectedColumn: 6) {
      XCTAssertEqual($0, .identifier("xyz", false))
    }
    lexAndTest(content, index: 2, expectedColumn: 9) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "abc")
      XCTAssertEqual(r, "\"abc\"")
    }
  }

  func testEscapedCharacters() {
    lexAndTest("\"\\0\\\\\\t\\n\\r\\\"\\\'\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "\0\\\t\n\r\"\'")
      XCTAssertEqual(r, "\"\\0\\\\\\t\\n\\r\\\"\\\'\"")
    }
  }

  func testInterpolatedText() {
    let content = "\"\\(\"3\")\""
    lexAndTest(content) { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\\(")
    }
    lexAndTest(content, index: 1, expectedColumn: 4) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "3")
      XCTAssertEqual(r, "\"3\"")
    }
    lexAndTest(content, index: 2, expectedColumn: 7) {
      XCTAssertEqual($0, .rightParen)
    }
    lexAndTest(content, index: 3, expectedColumn: 8) {
      XCTAssertEqual($0, .invalid(.unexpectedEndOfFile))
    }
  }

  func testInterpolatedTextSamplesFromSwiftPLBook() {
    lexAndTest("\"1 2 3\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "1 2 3")
      XCTAssertEqual(r, "\"1 2 3\"")
    }
    lexAndTest("\"1 2 \\(3)\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "1 2 ")
      XCTAssertEqual(r, "\"1 2 \\(")
    }
    lexAndTest("\"1 2 \\(\"3\")\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "1 2 ")
      XCTAssertEqual(r, "\"1 2 \\(")
    }
    lexAndTest("\"1 2 \\(\"1 + 2\")\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "1 2 ")
      XCTAssertEqual(r, "\"1 2 \\(")
    }
    lexAndTest("\"1 2 \\(x)\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "1 2 ")
      XCTAssertEqual(r, "\"1 2 \\(")
    }
  }

  func testMultipleInterpolated() {
    let content = "\"1 2 \\(\"3\") \\(\"1 + 2\") \\(x) 456\""
    lexAndTest(content) { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "1 2 ")
      XCTAssertEqual(r, "\"1 2 \\(")
    }
    lexAndTest(content, index: 1, expectedColumn: 8) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "3")
      XCTAssertEqual(r, "\"3\"")
    }
    lexAndTest(content, index: 2, expectedColumn: 11) {
      XCTAssertEqual($0, .rightParen)
    }
    lexAndTest(content, index: 3, expectedColumn: 13) {
      XCTAssertEqual($0, .backslash)
    }
  }

  func testNestedInterpolated() {
    let content = "\"\\(\"foo\\(123)()(\\(\"abc\\(\"😂\")xyz)\")\\(789)bar\")\""
    // print(content)
    lexAndTest(content) { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\\(")
    }
    lexAndTest(content, index: 1, expectedColumn: 4) { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "foo")
      XCTAssertEqual(r, "\"foo\\(")
    }
    lexAndTest(content, index: 2, expectedColumn: 10) { //t in
      XCTAssertEqual($0, .integerLiteral(123, rawRepresentation: "123"))
    }
    lexAndTest(content, index: 3, expectedColumn: 13) {
      XCTAssertEqual($0, .rightParen)
    }
    lexAndTest(content, index: 4, expectedColumn: 14) {
      XCTAssertEqual($0, .leftParen)
    }
    lexAndTest(content, index: 5, expectedColumn: 15) {
      XCTAssertEqual($0, .rightParen)
    }
    lexAndTest(content, index: 6, expectedColumn: 16) {
      XCTAssertEqual($0, .leftParen)
    }
    lexAndTest(content, index: 7, expectedColumn: 17) {
      XCTAssertEqual($0, .backslash)
    }
  }

  func testOneDoubleQuote() {
    lexAndTest("\"o\\\"o\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "o\"o")
      XCTAssertEqual(r, "\"o\\\"o\"")
    }
  }

  func testFunWithDoubleQuotes() {
    let content = "\"\\(\"helloworld\")foo\\(\"bar\")\"()\"()\""
    lexAndTest(content) { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\\(")
    }
    lexAndTest(content, index: 1, expectedColumn: 4) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "helloworld")
      XCTAssertEqual(r, "\"helloworld\"")
    }
    lexAndTest(content, index: 2, expectedColumn: 16) {
      XCTAssertEqual($0, .rightParen)
    }
    lexAndTest(content, index: 3, expectedColumn: 17) {
      XCTAssertEqual($0, .identifier("foo", false))
    }
    lexAndTest(content, index: 4, expectedColumn: 20) {
      XCTAssertEqual($0, .backslash)
    }
  }

  func testUnicode() {
    lexAndTest("\"\\u{1E11}\\u{1F600}\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "\u{1E11}😀")
      XCTAssertEqual(r, "\"\\u{1E11}\\u{1F600}\"")
    }
  }

  func testEmptyMultilineStaticStringLiterals() {
    lexAndTest("\"\"\"\n\"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\"\"\n\"\"\"")
    }
    lexAndTest("\"\"\"\n  \"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\"\"\n  \"\"\"")
    }
  }

  func testSingleLineMultilineStringLiterals() {
    lexAndTest("\"\"\"\nfoo\n\"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "foo")
      XCTAssertEqual(r, "\"\"\"\nfoo\n\"\"\"")
    }
    lexAndTest("\"\"\"\n  foo\n  \"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "foo")
      XCTAssertEqual(r, "\"\"\"\n  foo\n  \"\"\"")
    }
    lexAndTest("\"\"\"\n\tfoo\n\t\"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "foo")
      XCTAssertEqual(r, "\"\"\"\n\tfoo\n\t\"\"\"")
    }
    lexAndTest("\"\"\"\n \t foo\n \t \"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "foo")
      XCTAssertEqual(r, "\"\"\"\n \t foo\n \t \"\"\"")
    }
  }

  func testMultiLineMultilineStringLiterals() {
    let multiLineTestString = """
    \"\"\"

     The White Rabbit put on his spectacles.  \"Where shall I begin,
     please your Majesty?\" he asked.

     \"Begin at the beginning,\" the King said gravely, \"and go on
     till you come to the end; then stop.\"

     \"\"\"
    """
    let multiLineExpectedString = """

    The White Rabbit put on his spectacles.  "Where shall I begin,
    please your Majesty?" he asked.

    "Begin at the beginning," the King said gravely, "and go on
    till you come to the end; then stop."

    """
    lexAndTest(multiLineTestString) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, multiLineExpectedString)
      XCTAssertEqual(r, multiLineTestString)
    }
  }

  func testMultilineIdentations() {
    let multiLineTestString = """
    \"\"\"
      one space
       two spaces
        three spaces
     \"\"\"
    """
    let multiLineExpectedString = """
     one space
      two spaces
       three spaces
    """
    lexAndTest(multiLineTestString) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, multiLineExpectedString)
      XCTAssertEqual(r, multiLineTestString)
    }
  }

  func testMultilineIndentationErrors() {
    lexAndTest("\"\"\"\nfoo\n  \"\"\"") { t in
      XCTAssertEqual(t, .invalid(.insufficientIndentationOfLineInMultilineStringLiteral))
    }
  }

  func testMultilineDoubleQuoteFuns() {
    let multiLineTestString = """
    \"\"\"
    Escaping the first quote \\\"\"\"
    Escaping the first two quotes \\\"\\\"\"
    Escaping all three quotes \\\"\\\"\\\"
    \"\"\"
    """
    let multiLineExpectedString = """
    Escaping the first quote \"""
    Escaping the first two quotes \"\""
    Escaping all three quotes \"\"\"
    """
    lexAndTest(multiLineTestString) { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, multiLineExpectedString)
      XCTAssertEqual(r, multiLineTestString)
    }
  }

  func testSinglelineMultilineComparisons() {
    guard case .staticStringLiteral(let singleLine, _) = lex("\"There are the same.\"").kind else {
      XCTFail("Failed in lexing single line string literal")
      return
    }
    guard case .staticStringLiteral(let multiLine, _) = lex("\"\"\"\nThere are the same.\n\"\"\"").kind else {
      XCTFail("Failed in lexing multi line string literal")
      return
    }
    XCTAssertEqual(singleLine, multiLine)
    XCTAssertEqual(singleLine, "There are the same.")
    XCTAssertEqual(multiLine, "There are the same.")
  }

  func testInterpolatedTextInMultilineStringLiterals() {
    lexAndTest("\"\"\"\n\\(\"3\")\n\"\"\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "")
      XCTAssertEqual(r, "\"\"\"\n\\(")
    }
    lexAndTest("\"\"\"\n  \\(\"3\")\n  \"\"\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "  ")
      XCTAssertEqual(r, "\"\"\"\n  \\(")
    }
    lexAndTest("\"\"\"\n  foo\n  \\(\"3\")\n  \"\"\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "  foo\n  ")
      XCTAssertEqual(r, "\"\"\"\n  foo\n  \\(")
    }
  }

  func testInvalidEscapeSequenceInStringLiteral() {
    let invalidEscapeSequences = [
      " ",
      "a", "b", "l", "q", "z",
      "*", "/", "!",
    ]
    for seq in invalidEscapeSequences {
      lexAndTest("\"a\\\(seq)b\"") { t in
        XCTAssertEqual(t, .invalid(.invalidEscapeSequenceInStringLiteral))
      }
      lexAndTest("\"\"\"\na\\\(seq)b\n\"\"\"") { t in
        XCTAssertEqual(t, .invalid(.invalidEscapeSequenceInStringLiteral))
      }
    }
  }

  func testNewlineEscapesInMultilineStringLiterals() {
    lexAndTest("\"\"\"\nline one \\\nline two\n\"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "line one line two")
      XCTAssertEqual(r, "\"\"\"\nline one \\\nline two\n\"\"\"")
    }
    lexAndTest("\"\"\"\nline one \\\nline two \\      \nline th\\ \nree\n\"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "line one line two line three")
      XCTAssertEqual(r, "\"\"\"\nline one \\\nline two \\      \nline th\\ \nree\n\"\"\"")
    }
    lexAndTest("\"\"\"\nline one \\\nline two \\   \t   \nline th\\\t\t\nree\n\"\"\"") { t in
      guard case let .staticStringLiteral(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "line one line two line three")
      XCTAssertEqual(r, "\"\"\"\nline one \\\nline two \\   \t   \nline th\\\t\t\nree\n\"\"\"")
    }
    lexAndTest("\"\"\"\nfoo \\\n \\(123)\n\"\"\"") { t in
      guard case let .interpolatedStringLiteralHead(s, rawRepresentation: r) = t else {
        XCTFail("Cannot lex a string literal.")
        return
      }
      XCTAssertEqual(s, "foo  ")
      XCTAssertEqual(r, "\"\"\"\nfoo \\\n \\(")
    }
  }

  func testNewlineEscapeIsNotAllowedInLastLine() {
    lexAndTest("\"\"\"\n \\  \n\"\"\"") { t in
      XCTAssertEqual(t, .invalid(.newlineEscapesNotAllowedOnLastLine))
    }
    lexAndTest("\"\"\"\nsingle line \\  \n\"\"\"") { t in
      XCTAssertEqual(t, .invalid(.newlineEscapesNotAllowedOnLastLine))
    }
    lexAndTest("\"\"\"\nfirst line \\  \nsecond line \\  \n\"\"\"") { t in
      XCTAssertEqual(t, .invalid(.newlineEscapesNotAllowedOnLastLine))
    }
  }

  func testNewlineEscapesNotSupportedInStringLiterals() {
    lexAndTest("\"a\\\nb\"") { t in
      XCTAssertEqual(t, .invalid(.newlineEscapesNotSupportedInStringLiteral))
    }
    lexAndTest("\"a\\ \nb\"") { t in
      XCTAssertEqual(t, .invalid(.newlineEscapesNotSupportedInStringLiteral))
    }
    lexAndTest("\"a\\\t\nb\"") { t in
      XCTAssertEqual(t, .invalid(.newlineEscapesNotSupportedInStringLiteral))
    }
  }

  static var allTests = [
    ("testEmptyStringLiteral", testEmptyStringLiteral),
    ("testSingleCharacter", testSingleCharacter),
    ("testContainsEmptyCharacters", testContainsEmptyCharacters),
    ("testContainsSpacesInBetween", testContainsSpacesInBetween),
    ("testTwoStringLiterals", testTwoStringLiterals),
    ("testTwoStringLiteralsWithAnIdentifierInBetween", testTwoStringLiteralsWithAnIdentifierInBetween),
    ("testEscapedCharacters", testEscapedCharacters),
    ("testInterpolatedText", testInterpolatedText),
    ("testInterpolatedTextSamplesFromSwiftPLBook", testInterpolatedTextSamplesFromSwiftPLBook),
    ("testMultipleInterpolated", testMultipleInterpolated),
    ("testNestedInterpolated", testNestedInterpolated),
    ("testOneDoubleQuote", testOneDoubleQuote),
    ("testFunWithDoubleQuotes", testFunWithDoubleQuotes),
    ("testUnicode", testUnicode),
    ("testEmptyMultilineStaticStringLiterals", testEmptyMultilineStaticStringLiterals),
    ("testSingleLineMultilineStringLiterals", testSingleLineMultilineStringLiterals),
    ("testMultiLineMultilineStringLiterals", testMultiLineMultilineStringLiterals),
    ("testMultilineIdentations", testMultilineIdentations),
    ("testMultilineIndentationErrors", testMultilineIndentationErrors),
    ("testMultilineDoubleQuoteFuns", testMultilineDoubleQuoteFuns),
    ("testSinglelineMultilineComparisons", testSinglelineMultilineComparisons),
    ("testInterpolatedTextInMultilineStringLiterals", testInterpolatedTextInMultilineStringLiterals),
    ("testInvalidEscapeSequenceInStringLiteral", testInvalidEscapeSequenceInStringLiteral),
    ("testNewlineEscapesInMultilineStringLiterals", testNewlineEscapesInMultilineStringLiterals),
    ("testNewlineEscapeIsNotAllowedInLastLine", testNewlineEscapeIsNotAllowedInLastLine),
    ("testNewlineEscapesNotSupportedInStringLiterals", testNewlineEscapesNotSupportedInStringLiterals),
  ]
}
