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

@testable import AST

class ParserExpressionPatternTests: XCTestCase {
  func testNotInMatchingPattern() {
    let expct = expectation(description: "Expect an error because expression-pattern is not allowed when is parsed out of matching pattern context.") // TODO: revise this sentense
    parsePatternAndTest("0", "", errorClosure: { _ in
      expct.fulfill()
    })
    waitForExpectations(timeout: 3)
  }

  func testRawValues() {
    parsePatternAndTest("0", "0", forPatternMatching: true)
    parsePatternAndTest("\"foo\"", "\"foo\"", forPatternMatching: true)
    parsePatternAndTest("[foo, bar]", "[foo, bar]", forPatternMatching: true)
    parsePatternAndTest("[foo: bar]", "[foo: bar]", forPatternMatching: true)
  }

  func testRawValuesInTuples() {
    parsePatternAndTest("(true, false)", "(true, false)", forPatternMatching: true)
    parsePatternAndTest("(-1...1, 0...1)", "(-1 ... 1, 0 ... 1)", forPatternMatching: true)
    parsePatternAndTest("(\"0\", \"0\")", "(\"0\", \"0\")", forPatternMatching: true)
  }

  func testInVarDecl() {
    parsePatternAndTest("let (x, y?, nil)", "let (x, y?, nil)", forPatternMatching: true, testClosure: { pttrn in
      guard let valueBindingPattern = pttrn as? ValueBindingPattern,
        case .let(let pattern) = valueBindingPattern.kind else {
        XCTFail("Failed in parsing a value-binding pattern.")
        return
      }

      guard let tuplePattern = pattern as? TuplePattern else {
        XCTFail("Failed in getting a tuple pattern")
        return
      }
      XCTAssertNil(tuplePattern.typeAnnotation)
      let elements = tuplePattern.elementList
      guard elements.count == 3 else {
        XCTFail("Element count in tuple `(x, y?, nil)` should be 3.")
        return
      }
      guard case .pattern(let element1) = elements[0] else {
        XCTFail("Failed in getting a pattern `x`.")
        return
      }
      XCTAssertTrue(element1 is IdentifierPattern)
      guard case .pattern(let element2) = elements[1] else {
        XCTFail("Failed in getting a pattern `y?`.")
        return
      }
      XCTAssertTrue(element2 is OptionalPattern)
      guard case .pattern(let element3) = elements[2] else {
        XCTFail("Failed in getting a pattern `nil`.")
        return
      }
      XCTAssertTrue(element3 is ExpressionPattern)
    })
  }

  func testCastRawValue() {
    parsePatternAndTest("0 as CGFloat", "0 as CGFloat", forPatternMatching: true)
    parsePatternAndTest("\"0\" as Character", "\"0\" as Character", forPatternMatching: true)
  }

  func testSelfExpr() {
    parsePatternAndTest("self.foo()", "self.foo()", forPatternMatching: true)
  }

  func testSourceRange() {
    parsePatternAndTest("0", "0", forPatternMatching: true, testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 2))
    })
    parsePatternAndTest("0 as CGFloat", "0 as CGFloat", forPatternMatching: true, testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 13))
    })
  }

  static var allTests = [
    ("testNotInMatchingPattern", testNotInMatchingPattern),
    ("testRawValues", testRawValues),
    ("testRawValuesInTuples", testRawValuesInTuples),
    ("testInVarDecl", testInVarDecl),
    ("testCastRawValue", testCastRawValue),
    ("testSelfExpr", testSelfExpr),
    ("testSourceRange", testSourceRange),
  ]
}
