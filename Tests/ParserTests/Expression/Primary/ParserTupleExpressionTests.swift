/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserTupleExpressionTests: XCTestCase {
  func testEmptyTuple() {
    parseExpressionAndTest("()", "()", testClosure: { expr in
      guard let tupleExpr = expr as? TupleExpression else {
        XCTFail("Failed in getting a tuple expression")
        return
      }
      XCTAssertTrue(tupleExpr.elementList.isEmpty)
    })
  }

  func testMultipleElements() {
    parseExpressionAndTest("(1, foo, ())", "(1, foo, ())", testClosure: { expr in
      guard let tupleExpr = expr as? TupleExpression else {
        XCTFail("Failed in getting a tuple expression")
        return
      }
      let elements = tupleExpr.elementList
      guard elements.count == 3 else {
        XCTFail("Element count in tuple `(1, foo, ())` should be 3.")
        return
      }
      let element1 = elements[0]
      XCTAssertNil(element1.identifier)
      XCTAssertTrue(element1.expression is LiteralExpression)
      let element2 = elements[1]
      XCTAssertNil(element2.identifier)
      XCTAssertTrue(element2.expression is IdentifierExpression)
      let element3 = elements[2]
      XCTAssertNil(element3.identifier)
      XCTAssertTrue(element3.expression is TupleExpression)
    })
  }

  func testIdentifiers() {
    parseExpressionAndTest("(a: 1, b: foo, ())", "(a: 1, b: foo, ())", testClosure: { expr in
      guard let tupleExpr = expr as? TupleExpression else {
        XCTFail("Failed in getting a tuple expression")
        return
      }
      let elements = tupleExpr.elementList
      guard elements.count == 3 else {
        XCTFail("Element count in tuple `(a: 1, b: foo, ())` should be 3.")
        return
      }
      let element1 = elements[0]
      ASTTextEqual(element1.identifier, "a")
      XCTAssertTrue(element1.expression is LiteralExpression)
      let element2 = elements[1]
      ASTTextEqual(element2.identifier, "b")
      XCTAssertTrue(element2.expression is IdentifierExpression)
      let element3 = elements[2]
      XCTAssertNil(element3.identifier)
      XCTAssertTrue(element3.expression is TupleExpression)
    })
  }

  func testOneElementWithIdentifier() {
    parseExpressionAndTest("(a: 1)", "(a: 1)", testClosure: { expr in
      guard let tupleExpr = expr as? TupleExpression else {
        XCTFail("Failed in getting a tuple expression")
        return
      }
      let elements = tupleExpr.elementList
      guard elements.count == 1 else {
        XCTFail("Element count in tuple `(a: 1)` should be 1.")
        return
      }
      let element1 = elements[0]
      ASTTextEqual(element1.identifier, "a")
      XCTAssertTrue(element1.expression is LiteralExpression)
    })
  }

  func testSpaces() {
    parseExpressionAndTest("(       )", "()", testClosure: { expr in
      XCTAssertFalse(expr is ParenthesizedExpression)
      XCTAssertTrue(expr is TupleExpression)
    })
  }

  func testSpacesForEmptyTuple() {
    parseExpressionAndTest("(   a   : 1   , b   : foo, (   )    )", "(a: 1, b: foo, ())", testClosure: { expr in
      guard let tupleExpr = expr as? TupleExpression else {
        XCTFail("Failed in getting a tuple expression")
        return
      }
      XCTAssertEqual(tupleExpr.elementList.count, 3)
    })
  }

  func testPostfixQuestionAndExlaims() {
    parseExpressionAndTest(
      "(foo, ba?.r, [key: value, _ : 1 + 2]!, f(x), ())",
      "(foo, ba?.r, [key: value, _: 1 + 2]!, f(x), ())")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("()", 3),
      ("(foo, bar)", 11),
      ("(foo: 1, bar: 2)", 17),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testEmptyTuple", testEmptyTuple),
    ("testMultipleElements", testMultipleElements),
    ("testOneElementWithIdentifier", testOneElementWithIdentifier),
    ("testIdentifiers", testIdentifiers),
    ("testSpaces", testSpaces),
    ("testSpacesForEmptyTuple", testSpacesForEmptyTuple),
    ("testPostfixQuestionAndExlaims", testPostfixQuestionAndExlaims),
    ("testSourceRange", testSourceRange),
  ]
}
