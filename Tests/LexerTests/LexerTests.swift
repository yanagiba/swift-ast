/*
   Copyright 2015-2018, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

  func testBackslash() {
    lexAndTest("\\") {
      XCTAssertEqual($0, .backslash)
    }
    lexAndTest("\\.") {
      XCTAssertEqual($0, .backslash)
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
      XCTAssertEqual($0, .identifier("_a", false))
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
      "\u{1}", // unsegmented
      "\u{1DC7}", // identifier body
      "\u{E01EE}" // operator body
    ].forEach { e in
      lexAndTest(e) { t in
        XCTAssertEqual(t, .invalid(.badChar))
      }
    }
  }

  func testEqutables() { // swift-lint:suppress(high_ncss)
    XCTAssertTrue(Token.Kind.eof.isEqual(toKindOf: .eof))
    XCTAssertTrue(Token.Kind.eof.isEqual(to: .eof))
    XCTAssertTrue(Token.Kind.hash.isEqual(toKindOf: .hash))
    XCTAssertTrue(Token.Kind.hash.isEqual(to: .hash))
    XCTAssertTrue(Token.Kind.backslash.isEqual(toKindOf: .backslash))
    XCTAssertTrue(Token.Kind.backslash.isEqual(to: .backslash))

    XCTAssertTrue(Token.Kind.invalid(.unicodeLiteralExpected).isEqual(toKindOf: .invalid(.unicodeLiteralExpected)))
    XCTAssertTrue(Token.Kind.invalid(.digitCharExpected).isEqual(toKindOf: .invalid(.closingBacktickExpected)))
    XCTAssertTrue(Token.Kind.invalid(.badNumber).isEqual(to: .invalid(.badNumber)))
    XCTAssertFalse(Token.Kind.invalid(.dotOperatorRequiresTwoDots).isEqual(to: .invalid(.identifierHeadExpected)))

    XCTAssertTrue(Token.Kind.prefixOperator("😄").isEqual(toKindOf: .prefixOperator("😄")))
    XCTAssertTrue(Token.Kind.prefixOperator("😄").isEqual(toKindOf: .prefixOperator("😃")))
    XCTAssertTrue(Token.Kind.prefixOperator("😈").isEqual(to: .prefixOperator("😈")))
    XCTAssertFalse(Token.Kind.prefixOperator("🍙").isEqual(to: .prefixOperator("🍘")))

    XCTAssertTrue(Token.Kind.binaryOperator("😄").isEqual(toKindOf: .binaryOperator("😄")))
    XCTAssertTrue(Token.Kind.binaryOperator("😄").isEqual(toKindOf: .binaryOperator("😃")))
    XCTAssertTrue(Token.Kind.binaryOperator("😈").isEqual(to: .binaryOperator("😈")))
    XCTAssertFalse(Token.Kind.binaryOperator("🍙").isEqual(to: .binaryOperator("🍘")))

    XCTAssertTrue(Token.Kind.postfixOperator("😄").isEqual(toKindOf: .postfixOperator("😄")))
    XCTAssertTrue(Token.Kind.postfixOperator("😄").isEqual(toKindOf: .postfixOperator("😃")))
    XCTAssertTrue(Token.Kind.postfixOperator("😈").isEqual(to: .postfixOperator("😈")))
    XCTAssertFalse(Token.Kind.postfixOperator("🍙").isEqual(to: .postfixOperator("🍘")))

    XCTAssertTrue(Token.Kind.identifier("😄", false).isEqual(toKindOf: .identifier("😄", false)))
    XCTAssertTrue(Token.Kind.identifier("😄", true).isEqual(toKindOf: .identifier("😃", true)))
    XCTAssertTrue(Token.Kind.identifier("😈", false).isEqual(to: .identifier("😈", false)))
    XCTAssertFalse(Token.Kind.identifier("🍙", false).isEqual(to: .identifier("🍘", false)))

    XCTAssertTrue(Token.Kind.implicitParameterName(1).isEqual(toKindOf: .implicitParameterName(1)))
    XCTAssertTrue(Token.Kind.implicitParameterName(2).isEqual(toKindOf: .implicitParameterName(3)))
    XCTAssertTrue(Token.Kind.implicitParameterName(4).isEqual(to: .implicitParameterName(4)))
    XCTAssertFalse(Token.Kind.implicitParameterName(5).isEqual(to: .implicitParameterName(6)))

    XCTAssertTrue(
      Token.Kind.integerLiteral(1, rawRepresentation: "2").isEqual(to:
        .integerLiteral(1, rawRepresentation: "2")))
    XCTAssertFalse(
      Token.Kind.integerLiteral(1, rawRepresentation: "2").isEqual(to:
        .integerLiteral(2, rawRepresentation: "2")))
    XCTAssertFalse(
      Token.Kind.integerLiteral(1, rawRepresentation: "1").isEqual(to:
        .integerLiteral(1, rawRepresentation: "2")))

    XCTAssertTrue(
      Token.Kind.floatingPointLiteral(1, rawRepresentation: "2").isEqual(to:
        .floatingPointLiteral(1, rawRepresentation: "2")))
    XCTAssertFalse(
      Token.Kind.floatingPointLiteral(1, rawRepresentation: "2").isEqual(to:
        .floatingPointLiteral(2, rawRepresentation: "2")))
    XCTAssertFalse(
      Token.Kind.floatingPointLiteral(1, rawRepresentation: "1").isEqual(to:
        .floatingPointLiteral(1, rawRepresentation: "2")))

    XCTAssertTrue(
      Token.Kind.staticStringLiteral("1", rawRepresentation: "2", hashCount: 0).isEqual(to:
        .staticStringLiteral("1", rawRepresentation: "2", hashCount: 0)))
    XCTAssertFalse(
      Token.Kind.staticStringLiteral("1", rawRepresentation: "2", hashCount: 0).isEqual(to:
        .staticStringLiteral("2", rawRepresentation: "2", hashCount: 0)))
    XCTAssertFalse(
      Token.Kind.staticStringLiteral("1", rawRepresentation: "1", hashCount: 0).isEqual(to:
        .staticStringLiteral("1", rawRepresentation: "2", hashCount: 0)))
    XCTAssertFalse(
      Token.Kind.staticStringLiteral("1", rawRepresentation: "2", hashCount: 0).isEqual(to:
        .staticStringLiteral("1", rawRepresentation: "2", hashCount: 1)))

    XCTAssertTrue(
      Token.Kind.interpolatedStringLiteralHead("1", rawRepresentation: "2", hashCount: 0).isEqual(to:
        .interpolatedStringLiteralHead("1", rawRepresentation: "2", hashCount: 0)))
    XCTAssertFalse(
      Token.Kind.interpolatedStringLiteralHead("1", rawRepresentation: "2", hashCount: 0).isEqual(to:
        .interpolatedStringLiteralHead("2", rawRepresentation: "2", hashCount: 0)))
    XCTAssertFalse(
      Token.Kind.interpolatedStringLiteralHead("1", rawRepresentation: "1", hashCount: 0).isEqual(to:
        .interpolatedStringLiteralHead("1", rawRepresentation: "2", hashCount: 0)))
    XCTAssertFalse(
      Token.Kind.interpolatedStringLiteralHead("1", rawRepresentation: "2", hashCount: 0).isEqual(to:
        .interpolatedStringLiteralHead("1", rawRepresentation: "2", hashCount: 1)))

    XCTAssertTrue(Token.Kind.booleanLiteral(true).isEqual(toKindOf: .booleanLiteral(true)))
    XCTAssertTrue(Token.Kind.booleanLiteral(true).isEqual(toKindOf: .booleanLiteral(false)))
    XCTAssertTrue(Token.Kind.booleanLiteral(false).isEqual(to: .booleanLiteral(false)))
    XCTAssertFalse(Token.Kind.booleanLiteral(false).isEqual(to: .booleanLiteral(true)))
  }
}
