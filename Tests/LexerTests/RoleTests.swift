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

@testable import Lexer

fileprivate func role(of content: String) -> Role {
  let scanner = Scanner(content: content)
  return scanner.scan().role
}

class RoleTests: XCTestCase {
  func testEmptyContent() {
    XCTAssertEqual(role(of: ""), .eof)
  }

  func testLineFeed() {
    XCTAssertEqual(role(of: "\n"), .lineFeed)
  }

  func testCarriageReturn() {
    XCTAssertEqual(role(of: "\r"), .carriageReturn)
  }

  func testLeftParen() {
    XCTAssertEqual(role(of: "("), .leftParen)
  }

  func testRightParen() {
    XCTAssertEqual(role(of: ")"), .rightParen)
  }

  func testLeftBrace() {
    XCTAssertEqual(role(of: "{"), .leftBrace)
  }

  func testRightBrace() {
    XCTAssertEqual(role(of: "}"), .rightBrace)
  }

  func testLeftSquare() {
    XCTAssertEqual(role(of: "["), .leftSquare)
  }

  func testRightSquare() {
    XCTAssertEqual(role(of: "]"), .rightSquare)
  }

  func testPeriod() {
    XCTAssertEqual(role(of: "."), .period)
    XCTAssertEqual(role(of: ".a"), .period)
    XCTAssertEqual(role(of: ".."), .dotOperatorHead)
  }

  func testComma() {
    XCTAssertEqual(role(of: ","), .comma)
  }

  func testColon() {
    XCTAssertEqual(role(of: ":"), .colon)
  }

  func testSemicolon() {
    XCTAssertEqual(role(of: ";"), .semi)
  }

  func testEqual() {
    XCTAssertEqual(role(of: "="), .equal)
    XCTAssertEqual(role(of: "=>"), .operatorHead)
    XCTAssertEqual(role(of: "=&"), .operatorHead)
  }

  func testAt() {
    XCTAssertEqual(role(of: "@"), .at)
  }

  func testHash() {
    XCTAssertEqual(role(of: "#"), .hash)
  }

  func testAmp() {
    XCTAssertEqual(role(of: "&"), .amp)
    XCTAssertEqual(role(of: "&="), .operatorHead)
    XCTAssertEqual(role(of: "&&"), .operatorHead)
  }

  func testMinus() {
    XCTAssertEqual(role(of: "-"), .operatorHead)
    XCTAssertEqual(role(of: "-="), .operatorHead)
    XCTAssertEqual(role(of: "->"), .arrow)
    XCTAssertEqual(role(of: "-<"), .operatorHead)
    XCTAssertEqual(role(of: "-1"), .minus)
    XCTAssertEqual(role(of: "-0"), .minus)
    XCTAssertEqual(role(of: "-9"), .minus)
  }

  func testBacktick() {
    XCTAssertEqual(role(of: "`"), .backtick)
  }

  func testBackslash() {
    XCTAssertEqual(role(of: "\\"), .backslash)
  }

  func testDollar() {
    XCTAssertEqual(role(of: "$"), .dollar)
  }

  func testDoubleQuote() {
    XCTAssertEqual(role(of: "\""), .doubleQuote)
  }

  func testExclaim() {
    XCTAssertEqual(role(of: "!"), .exclaim)
    XCTAssertEqual(role(of: "!="), .operatorHead)
    XCTAssertEqual(role(of: "!~"), .operatorHead)
  }

  func testQuestion() {
    XCTAssertEqual(role(of: "?"), .question)
    XCTAssertEqual(role(of: "?="), .operatorHead)
    XCTAssertEqual(role(of: "?!"), .operatorHead)
  }

  func testLessThan() {
    XCTAssertEqual(role(of: "<"), .lessThan)
    XCTAssertEqual(role(of: "<<"), .operatorHead)
    XCTAssertEqual(role(of: "<>"), .operatorHead)
  }

  func testGreaterThan() {
    XCTAssertEqual(role(of: ">"), .greaterThan)
    XCTAssertEqual(role(of: ">>"), .operatorHead)
    XCTAssertEqual(role(of: "><"), .operatorHead)
  }

  func testUnderscore() {
    XCTAssertEqual(role(of: "_"), .underscore)
    XCTAssertEqual(role(of: "_id"), .identifierHead)
    XCTAssertEqual(role(of: "_6"), .identifierHead)
  }

  func testSlash() {
    XCTAssertEqual(role(of: "/"), .operatorHead)
    XCTAssertEqual(role(of: "/>"), .operatorHead)
    XCTAssertEqual(role(of: "/\\"), .operatorHead)
    XCTAssertEqual(role(of: "//"), .singleLineCommentHead)
    XCTAssertEqual(role(of: "////"), .singleLineCommentHead)
    XCTAssertEqual(role(of: "/*"), .multipleLineCommentHead)
    XCTAssertEqual(role(of: "/**"), .multipleLineCommentHead)
    XCTAssertEqual(role(of: "/*//"), .multipleLineCommentHead)
  }

  func testAsterisk() {
    XCTAssertEqual(role(of: "*"), .operatorHead)
    XCTAssertEqual(role(of: "*="), .operatorHead)
    XCTAssertEqual(role(of: "*/"), .multipleLineCommentTail)
  }

  func testDigits() {
    for d in 0...9 {
      XCTAssertEqual(role(of: String(d)), .digit)
    }
  }

  func testSpaces() {
    for s in [" ", "\t", "\0", "\u{000b}", "\u{000c}"] {
      XCTAssertEqual(role(of: s), .space)
    }
  }

  func testOperatorHeads() {
    // Note: the folowings have been tested elsewhere:
    //       "/", "=", "-", "!", "?", "*", "<", ">", "&"
    for oh in ["+", "%", "|", "^", "~", "\u{3009}"] {
      XCTAssertEqual(role(of: oh), .operatorHead)
    }
  }

  func testOperatorBody() {
    for ob in ["\u{E01DA}", "\u{E01EE}"] {
      XCTAssertEqual(role(of: ob), .operatorBody)
    }
  }

  func testIdentifierHeads() {
    // Note: the folowings have been tested elsewhere:
    //       "_"
    for ih in ["A", "Z", "a", "z", "\u{3006}", "\u{EFFFC}"] {
      XCTAssertEqual(role(of: ih), .identifierHead)
    }
  }

  func testIdentifierBody() {
    // Note: the folowings have been tested elsewhere:
    //       "0", "9"
    for ib in ["\u{FE20}", "\u{1DC7}"] {
      XCTAssertEqual(role(of: ib), .identifierBody)
    }
  }

  func testStartOfHeading() {
    XCTAssertEqual(role(of: "\u{1}"), .unknown)
  }

  static var allTests = [
    ("testEmptyContent", testEmptyContent),
    ("testLineFeed", testLineFeed),
    ("testCarriageReturn", testCarriageReturn),
    ("testLeftParen", testLeftParen),
    ("testRightParen", testRightParen),
    ("testLeftBrace", testLeftBrace),
    ("testRightBrace", testRightBrace),
    ("testLeftSquare", testLeftSquare),
    ("testRightSquare", testRightSquare),
    ("testPeriod", testPeriod),
    ("testComma", testComma),
    ("testColon", testColon),
    ("testSemicolon", testSemicolon),
    ("testEqual", testEqual),
    ("testAt", testAt),
    ("testHash", testHash),
    ("testAmp", testAmp),
    ("testMinus", testMinus),
    ("testBacktick", testBacktick),
    ("testBackslash", testBackslash),
    ("testDollar", testDollar),
    ("testDoubleQuote", testDoubleQuote),
    ("testExclaim", testExclaim),
    ("testQuestion", testQuestion),
    ("testLessThan", testLessThan),
    ("testGreaterThan", testGreaterThan),
    ("testUnderscore", testUnderscore),
    ("testSlash", testSlash),
    ("testAsterisk", testAsterisk),
    ("testDigits", testDigits),
    ("testSpaces", testSpaces),
    ("testOperatorHeads", testOperatorHeads),
    ("testOperatorBody", testOperatorBody),
    ("testIdentifierHeads", testIdentifierHeads),
    ("testIdentifierBody", testIdentifierBody),
    ("testStartOfHeading", testStartOfHeading),
  ]

}
