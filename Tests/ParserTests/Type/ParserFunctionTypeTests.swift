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

@testable import AST

class ParserFunctionTypeTests: XCTestCase {
  func testFunctionTypes() {
    parseTypeAndTest("(foo) -> bar", "(foo) -> bar")
    parseTypeAndTest("(a, b, c) -> (x, y)", "(a, b, c) -> (x, y)")
    parseTypeAndTest("(foo) -> ()", "(foo) -> ()")
    parseTypeAndTest("() -> Void", "() -> Void")
  }

  func testThrowsException() {
    parseTypeAndTest("(foo) throws -> bar", "(foo) throws -> bar")
  }

  func testRethrowsException() {
    parseTypeAndTest("(foo) rethrows -> bar", "(foo) rethrows -> bar")
  }

  func testReturnsFunctionType() {
    parseTypeAndTest("(a, a) -> (b) -> (c)", "(a, a) -> (b) -> (c)", testClosure: { type in
      guard let functionType = type as? FunctionType else {
        XCTFail("Failed in converting to a function type.")
        return
      }

      XCTAssertEqual(functionType.arguments.count, 2)
      XCTAssertTrue(functionType.returnType is FunctionType)
    })
  }

  func testArgumentAttributes() {
    parseTypeAndTest("(@a @b @c foo) -> bar", "(@a @b @c foo) -> bar")
    parseTypeAndTest("(a, @x a) -> (@y b) -> (c)", "(a, @x a) -> (@y b) -> (c)")
  }

  func testArgumentInout() {
    parseTypeAndTest("(inout foo) -> bar", "(inout foo) -> bar")
    parseTypeAndTest("(a, inout a) -> (inout b) -> (c)", "(a, inout a) -> (inout b) -> (c)")
  }

  func testArgumentAttributesAndInout() {
    parseTypeAndTest("(@a inout foo) -> bar", "(@a inout foo) -> bar")
    parseTypeAndTest("(a, @x inout a) -> (@y inout b) -> (c)", "(a, @x inout a) -> (@y inout b) -> (c)")
  }

  func testArgumentName() {
    parseTypeAndTest("(i: foo) -> bar", "(i: foo) -> bar")
    parseTypeAndTest("(i: @a @b @c foo) -> bar", "(i: @a @b @c foo) -> bar")
    parseTypeAndTest("(i: inout foo) -> bar", "(i: inout foo) -> bar")
    parseTypeAndTest("(i: @a inout foo) -> bar", "(i: @a inout foo) -> bar")
  }

  func testArgumentVariadic() {
    parseTypeAndTest("(foo...) -> bar", "(foo...) -> bar")
    parseTypeAndTest("(@a @b @c foo...) -> bar", "(@a @b @c foo...) -> bar")
    parseTypeAndTest("(inout foo...) -> bar", "(inout foo...) -> bar")
    parseTypeAndTest("(@a inout foo...) -> bar", "(@a inout foo...) -> bar")
  }

  func testAttributedFuncType() {
    parseTypeAndTest("@a @b @c (i: @x inout foo) -> bar", "@a @b @c (i: @x inout foo) -> bar")
  }

  func testOuterName() {
    // Note: even though this is not documented, but as of swift 3.1,
    // this is valid and supported by Apple swift compiler
    parseTypeAndTest("(o i: foo) -> bar", "(o i: foo) -> bar")
    parseTypeAndTest("(_ i: foo) -> bar", "(_ i: foo) -> bar")
    parseTypeAndTest("(_ i: foo, _ j: bar) -> bar", "(_ i: foo, _ j: bar) -> bar")
  }

  func testSourceRange() {
    parseTypeAndTest("(foo) -> bar", "(foo) -> bar", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 13))
    })
    parseTypeAndTest("(a, a) -> (b) -> (c)", "(a, a) -> (b) -> (c)", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 21))
    })
  }

  static var allTests = [
    ("testFunctionTypes", testFunctionTypes),
    ("testThrowsException", testThrowsException),
    ("testRethrowsException", testRethrowsException),
    ("testReturnsFunctionType", testReturnsFunctionType),
    ("testArgumentAttributes", testArgumentAttributes),
    ("testArgumentInout", testArgumentInout),
    ("testArgumentAttributesAndInout", testArgumentAttributesAndInout),
    ("testArgumentName", testArgumentName),
    ("testArgumentVariadic", testArgumentVariadic),
    ("testAttributedFuncType", testAttributedFuncType),
    ("testOuterName", testOuterName),
    ("testSourceRange", testSourceRange),
  ]
}
