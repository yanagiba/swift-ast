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
@testable import Parser

class ParserAttributeTests: XCTestCase {
  func testAttributeName() {
    parseAttributesAndTest("@foo", "@foo", testClosure: { attrs in
      XCTAssertEqual(attrs.count, 1)
      ASTTextEqual(attrs[0].name, "foo")
      XCTAssertNil(attrs[0].argumentClause)
    })
  }

  func testEmptyArgumentClause() {
    parseAttributesAndTest("@foo()", "@foo()", testClosure: { attrs in
      XCTAssertEqual(attrs.count, 1)
      ASTTextEqual(attrs[0].name, "foo")
      guard let arg = attrs[0].argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertTrue(arg.balancedTokens.isEmpty)
      XCTAssertEqual(arg.textDescription, "()")
    })
  }

  func testArgumentClauseWithSingleToken() {
    parseAttributesAndTest(
      "@available(*, unavailable, renamed: \"MyRenamedProtocol\")",
      "@available(*, unavailable, renamed: \"MyRenamedProtocol\")",
      testClosure: { attrs in
      XCTAssertEqual(attrs.count, 1)
      ASTTextEqual(attrs[0].name, "available")
      guard let arg = attrs[0].argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arg.balancedTokens.count, 1)
      guard case .token(let tokenString) = arg.balancedTokens[0] else {
        XCTFail("Failed in getting a balanced token.")
        return
      }
      XCTAssertEqual(tokenString, "*, unavailable, renamed: \"MyRenamedProtocol\"")
    })
  }

  func testEmbeddedParenthesisToken() {
    parseAttributesAndTest(
      "@foo(()(xyz()))",
      "@foo(()(xyz()))",
      testClosure: { attrs in
      XCTAssertEqual(attrs.count, 1)
      ASTTextEqual(attrs[0].name, "foo")
      guard let arg = attrs[0].argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arg.balancedTokens.count, 2)
      guard case .parenthesis(let tokens1) = arg.balancedTokens[0],
        case .parenthesis(let tokens2) = arg.balancedTokens[1] else {
        XCTFail("Failed in getting balanced tokens.")
        return
      }
      XCTAssertEqual(tokens1.textDescription, "")
      XCTAssertEqual(tokens2.textDescription, "xyz()")
    })
  }

  func testEmbeddedSquareToken() {
    parseAttributesAndTest(
      "@foo([][xyz[]])",
      "@foo([][xyz[]])",
      testClosure: { attrs in
      XCTAssertEqual(attrs.count, 1)
      ASTTextEqual(attrs[0].name, "foo")
      guard let arg = attrs[0].argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arg.balancedTokens.count, 2)
      guard case .square(let tokens1) = arg.balancedTokens[0],
        case .square(let tokens2) = arg.balancedTokens[1] else {
        XCTFail("Failed in getting balanced tokens.")
        return
      }
      XCTAssertEqual(tokens1.textDescription, "")
      XCTAssertEqual(tokens2.textDescription, "xyz[]")
    })
  }

  func testEmbeddedBraceToken() {
    parseAttributesAndTest(
      "@foo({}{xyz{}})",
      "@foo({}{xyz{}})",
      testClosure: { attrs in
      XCTAssertEqual(attrs.count, 1)
      ASTTextEqual(attrs[0].name, "foo")
      guard let arg = attrs[0].argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arg.balancedTokens.count, 2)
      guard case .brace(let tokens1) = arg.balancedTokens[0],
        case .brace(let tokens2) = arg.balancedTokens[1] else {
        XCTFail("Failed in getting balanced tokens.")
        return
      }
      XCTAssertEqual(tokens1.textDescription, "")
      XCTAssertEqual(tokens2.textDescription, "xyz{}")
    })
  }

  func testHeadingAndTrailingStrings() {
    parseAttributesAndTest("@a(h()t)", "@a(h()t)")
    parseAttributesAndTest("@a(h[]t)", "@a(h[]t)")
    parseAttributesAndTest("@a(h{}t)", "@a(h{}t)")
  }

  static var allTests = [
    ("testAttributeName", testAttributeName),
    ("testEmptyArgumentClause", testEmptyArgumentClause),
    ("testArgumentClauseWithSingleToken", testArgumentClauseWithSingleToken),
    ("testEmbeddedParenthesisToken", testEmbeddedParenthesisToken),
    ("testEmbeddedSquareToken", testEmbeddedSquareToken),
    ("testEmbeddedBraceToken", testEmbeddedBraceToken),
    ("testHeadingAndTrailingStrings", testHeadingAndTrailingStrings),
  ]
}
