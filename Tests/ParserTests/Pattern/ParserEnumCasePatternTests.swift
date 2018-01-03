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

class ParserEnumCasePatternTests: XCTestCase {
  func testEnumCaseName() {
    parsePatternAndTest(".foo", ".foo", testClosure: { pttrn in
      guard let casePattern = pttrn as? EnumCasePattern else {
        XCTFail("Failed in parsing a case pattern.")
        return
      }

      ASTTextEqual(casePattern.name, "foo")
      XCTAssertNil(casePattern.typeIdentifier)
      XCTAssertNil(casePattern.tuplePattern)
    })
  }

  func testEmptyTuple() {
    parsePatternAndTest(".foo()", ".foo()", testClosure: { pttrn in
      guard let casePattern = pttrn as? EnumCasePattern, let tuple = casePattern.tuplePattern else {
        XCTFail("Failed in parsing a case pattern.")
        return
      }

      ASTTextEqual(casePattern.name, "foo")
      XCTAssertNil(casePattern.typeIdentifier)
      XCTAssertTrue(tuple.elementList.isEmpty)
    })
  }

  func testTuple() {
    parsePatternAndTest(".foo(a, b, c)", ".foo(a, b, c)", testClosure: { pttrn in
      guard let casePattern = pttrn as? EnumCasePattern, let tuple = casePattern.tuplePattern else {
        XCTFail("Failed in parsing a case pattern.")
        return
      }

      ASTTextEqual(casePattern.name, "foo")
      XCTAssertNil(casePattern.typeIdentifier)
      XCTAssertEqual(tuple.elementList.count, 3)
    })
  }

  func testTuplesWithValueBinding() {
    parsePatternAndTest("let .foo(a, b)", "let .foo(a, b)")
    parsePatternAndTest(".foo(let a, let b)", ".foo(let a, let b)")
    parsePatternAndTest("let .foo(_, b)", "let .foo(_, b)")
    parsePatternAndTest("let .foo(_?, b?)", "let .foo(_?, b?)", forPatternMatching: true)
    parsePatternAndTest(".foo(let _?, let b?)", ".foo(let _?, let b?)", forPatternMatching: true)
    parsePatternAndTest(".foo(nil, _?)", ".foo(nil, _?)", forPatternMatching: true)
    let expct = expectation(description:
      "Expect an error because var decl is not allowed in a tuple pattern that is already in a var decl.")
    parsePatternAndTest(".foo(let a)", "", fromForInOrVarDecl: true, errorClosure: { _ in
      expct.fulfill()
    })
    waitForExpectations(timeout: 3)
  }

  func testBasicTypeIdentifier() {
    parsePatternAndTest("Foo.bar", "Foo.bar", testClosure: { pttrn in
      guard let casePattern = pttrn as? EnumCasePattern, let typeId = casePattern.typeIdentifier else {
        XCTFail("Failed in parsing a case pattern.")
        return
      }

      ASTTextEqual(casePattern.name, "bar")
      XCTAssertEqual(typeId.textDescription, "Foo")
      XCTAssertNil(casePattern.tuplePattern)
    })
  }

  func testTypeIdentifierWithGeneric() {
    parsePatternAndTest("Foo<String>.bar", "Foo<String>.bar", testClosure: { pttrn in
      guard let casePattern = pttrn as? EnumCasePattern, let typeId = casePattern.typeIdentifier else {
        XCTFail("Failed in parsing a case pattern.")
        return
      }

      ASTTextEqual(casePattern.name, "bar")
      XCTAssertEqual(typeId.textDescription, "Foo<String>")
      XCTAssertNil(casePattern.tuplePattern)
    })
  }

  func testBothTypeIdentifierAndTuple() {
    parsePatternAndTest("YNGA.Foo<String>.bar(i)", "YNGA.Foo<String>.bar(i)", testClosure: { pttrn in
      guard let casePattern = pttrn as? EnumCasePattern,
        let typeId = casePattern.typeIdentifier,
        let tuple = casePattern.tuplePattern else {
        XCTFail("Failed in parsing a case pattern.")
        return
      }

      ASTTextEqual(casePattern.name, "bar")
      XCTAssertEqual(typeId.textDescription, "YNGA.Foo<String>")
      XCTAssertEqual(tuple.textDescription, "(i)")
    })
  }

  func testSourceRange() {
    parsePatternAndTest(".foo", ".foo", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 5))
    })
    parsePatternAndTest(".foo()", ".foo()", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 7))
    })
    parsePatternAndTest("a.b", "a.b", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 4))
    })
    parsePatternAndTest("YNGA.Foo<String>.bar(i)", "YNGA.Foo<String>.bar(i)", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 24))
    })
  }

  static var allTests = [
    ("testEnumCaseName", testEnumCaseName),
    ("testEmptyTuple", testEmptyTuple),
    ("testTuple", testTuple),
    ("testTuplesWithValueBinding", testTuplesWithValueBinding),
    ("testBasicTypeIdentifier", testBasicTypeIdentifier),
    ("testTypeIdentifierWithGeneric", testTypeIdentifierWithGeneric),
    ("testBothTypeIdentifierAndTuple", testBothTypeIdentifierAndTuple),
    ("testSourceRange", testSourceRange),
  ]
}
