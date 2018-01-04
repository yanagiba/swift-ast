/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either pttrness or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import XCTest

@testable import AST

class ParserTuplePatternTests: XCTestCase {
  func testEmptyTuple() {
    parsePatternAndTest("()", "()", testClosure: { pttrn in
      guard let tuplePattern = pttrn as? TuplePattern else {
        XCTFail("Failed in getting a tuple pattern")
        return
      }
      XCTAssertTrue(tuplePattern.elementList.isEmpty)
      XCTAssertNil(tuplePattern.typeAnnotation)
    })
  }

  func testMultipleElements() {
    parsePatternAndTest("(foo, _, bar)", "(foo, _, bar)", testClosure: { pttrn in
      guard let tuplePattern = pttrn as? TuplePattern else {
        XCTFail("Failed in getting a tuple pattern")
        return
      }
      XCTAssertNil(tuplePattern.typeAnnotation)
      let elements = tuplePattern.elementList
      guard elements.count == 3 else {
        XCTFail("Element count in tuple `(foo, _, bar)` should be 3.")
        return
      }
      guard case .pattern(let element1) = elements[0] else {
        XCTFail("Failed in getting a pattern `foo`.")
        return
      }
      XCTAssertTrue(element1 is IdentifierPattern)
      guard case .pattern(let element2) = elements[1] else {
        XCTFail("Failed in getting a pattern `_`.")
        return
      }
      XCTAssertTrue(element2 is WildcardPattern)
      guard case .pattern(let element3) = elements[2] else {
        XCTFail("Failed in getting a pattern `bar`.")
        return
      }
      XCTAssertTrue(element3 is IdentifierPattern)
    })
  }

  func testIdentifiers() {
    parsePatternAndTest("(a: foo, b: _, c: bar)", "(a: foo, b: _, c: bar)", testClosure: { pttrn in
      guard let tuplePattern = pttrn as? TuplePattern else {
        XCTFail("Failed in getting a tuple pattern")
        return
      }
      XCTAssertNil(tuplePattern.typeAnnotation)
      let elements = tuplePattern.elementList
      guard elements.count == 3 else {
        XCTFail("Element count in tuple `(a: foo, b: _, c: bar)` should be 3.")
        return
      }
      guard case let .namedPattern(name1, element1) = elements[0] else {
        XCTFail("Failed in getting a pattern `foo`.")
        return
      }
      ASTTextEqual(name1, "a")
      XCTAssertTrue(element1 is IdentifierPattern)
      guard case let .namedPattern(name2, element2) = elements[1] else {
        XCTFail("Failed in getting a pattern `_`.")
        return
      }
      ASTTextEqual(name2, "b")
      XCTAssertTrue(element2 is WildcardPattern)
      guard case let .namedPattern(name3, element3) = elements[2] else {
        XCTFail("Failed in getting a pattern `bar`.")
        return
      }
      ASTTextEqual(name3, "c")
      XCTAssertTrue(element3 is IdentifierPattern)
    })
  }

  func testSpaces() {
    parsePatternAndTest("(       )", "()")
    parsePatternAndTest("(   a   : _   , b   : foo, bar    )", "(a: _, b: foo, bar)")
  }

  func testOptional() {
    parsePatternAndTest("(x?, y?)", "(x?, y?)")
  }

  func testFromForInOrVarDecl() {
    parsePatternAndTest("(let a, let b)", "(let a, let b)")
    let expct = expectation(description:
      "Expect an error because var decl is not allowed in a tuple pattern that is already in a var decl.")
    parsePatternAndTest("(let a, let b)", "", fromForInOrVarDecl: true, errorClosure: { _ in
      expct.fulfill()
    })
    waitForExpectations(timeout: 3)

    parsePatternAndTest("(): Void", "(): Void")
    parsePatternAndTest("(): Void", "(): Void", fromForInOrVarDecl: true)
    parsePatternAndTest("(): Void", "()", fromForInOrVarDecl: true, fromTuplePattern: true)
  }

  func testTypeAnnotation() {
    parsePatternAndTest("(): Void", "(): Void", testClosure: { pttrn in
      guard let tuplePattern = pttrn as? TuplePattern else {
        XCTFail("Failed in getting a tuple pattern")
        return
      }
      XCTAssertNotNil(tuplePattern.typeAnnotation)
      XCTAssertTrue(tuplePattern.elementList.isEmpty)
    })
    parsePatternAndTest("(_, x): (Any, Int)", "(_, x): (Any, Int)")
    parsePatternAndTest("(foo, bar): (Foo, Bar)", "(foo, bar): (Foo, Bar)")
  }

  func testSourceRange() {
    parsePatternAndTest("()", "()", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 3))
    })
    parsePatternAndTest("(a: foo, b: _, bar)", "(a: foo, b: _, bar)", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 20))
    })
    parsePatternAndTest("(): Void", "(): Void", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 9))
    })
  }

  static var allTests = [
    ("testEmptyTuple", testEmptyTuple),
    ("testMultipleElements", testMultipleElements),
    ("testIdentifiers", testIdentifiers),
    ("testSpaces", testSpaces),
    ("testOptional", testOptional),
    ("testFromForInOrVarDecl", testFromForInOrVarDecl),
    ("testTypeAnnotation", testTypeAnnotation),
    ("testSourceRange", testSourceRange),
  ]
}
