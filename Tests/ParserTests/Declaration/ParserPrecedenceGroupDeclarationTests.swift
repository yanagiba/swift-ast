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

class ParserPrecedenceGroupDeclarationTests: XCTestCase {
  func testName() {
    parseDeclarationAndTest(
      "precedencegroup foo {}",
      "precedencegroup foo {}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertTrue(precedenceGroupDecl.attributes.isEmpty)
    })
  }

  func testHigherThanSingle() {
    parseDeclarationAndTest(
      "precedencegroup foo { higherThan: bar }",
      "precedencegroup foo {\nhigherThan: bar\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .higherThan(let ids) = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-relation.")
        return
      }
      XCTAssertEqual(ids.count, 1)
      ASTTextEqual(ids[0], "bar")
    })
  }

  func testHigherThanMultiple() {
    parseDeclarationAndTest(
      "precedencegroup foo { higherThan: a, b, c }",
      "precedencegroup foo {\nhigherThan: a, b, c\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .higherThan(let ids) = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-relation.")
        return
      }
      XCTAssertEqual(ids.count, 3)
      ASTTextEqual(ids[0], "a")
      ASTTextEqual(ids[1], "b")
      ASTTextEqual(ids[2], "c")
    })
  }

  func testLowerThanSingle() {
    parseDeclarationAndTest(
      "precedencegroup foo { lowerThan: bar }",
      "precedencegroup foo {\nlowerThan: bar\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .lowerThan(let ids) = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-relation.")
        return
      }
      XCTAssertEqual(ids.count, 1)
      ASTTextEqual(ids[0], "bar")
    })
  }

  func testLowerThanMultiple() {
    parseDeclarationAndTest(
      "precedencegroup foo { lowerThan: a, b, c }",
      "precedencegroup foo {\nlowerThan: a, b, c\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .lowerThan(let ids) = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-relation.")
        return
      }
      XCTAssertEqual(ids.count, 3)
      ASTTextEqual(ids[0], "a")
      ASTTextEqual(ids[1], "b")
      ASTTextEqual(ids[2], "c")
    })
  }

  func testAssignmentTrue() {
    parseDeclarationAndTest(
      "precedencegroup foo { assignment: true }",
      "precedencegroup foo {\nassignment: true\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .assignment(let b) = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-assignment.")
        return
      }
      XCTAssertTrue(b)
    })
  }

  func testAssignmentFalse() {
    parseDeclarationAndTest(
      "precedencegroup foo { assignment: false }",
      "precedencegroup foo {\nassignment: false\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .assignment(let b) = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-assignment.")
        return
      }
      XCTAssertFalse(b)
    })
  }

  func testAssociativityLeft() {
    parseDeclarationAndTest(
      "precedencegroup foo { associativity: left }",
      "precedencegroup foo {\nassociativity: left\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .associativityLeft = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-associativity.")
        return
      }
    })
  }

  func testAssociativityRight() {
    parseDeclarationAndTest(
      "precedencegroup foo { associativity: right }",
      "precedencegroup foo {\nassociativity: right\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .associativityRight = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-associativity.")
        return
      }
    })
  }

  func testAssociativityNone() {
    parseDeclarationAndTest(
      "precedencegroup foo { associativity: none }",
      "precedencegroup foo {\nassociativity: none\n}",
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 1)
      guard case .associativityNone = precedenceGroupDecl.attributes[0] else {
        XCTFail("Failed in getting a precedence-group-associativity.")
        return
      }
    })
  }

  func testCombination() {
    parseDeclarationAndTest(
      """
      precedencegroup foo {
        higherThan: bar
        higherThan: a, b, c
        lowerThan: bar
        lowerThan: a, b, c
        assignment: true
        assignment: false
        associativity: left
        associativity: right
        associativity: none
      }
      """,
      """
      precedencegroup foo {
      higherThan: bar
      higherThan: a, b, c
      lowerThan: bar
      lowerThan: a, b, c
      assignment: true
      assignment: false
      associativity: left
      associativity: right
      associativity: none
      }
      """,
      testClosure: { decl in
      guard let precedenceGroupDecl = decl as? PrecedenceGroupDeclaration else {
        XCTFail("Failed in getting a precedence-group declaration.")
        return
      }

      ASTTextEqual(precedenceGroupDecl.name, "foo")
      XCTAssertEqual(precedenceGroupDecl.attributes.count, 9)
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "precedencegroup foo {}",
      "precedencegroup foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 23))
      }
    )
    parseDeclarationAndTest(
      """
      precedencegroup foo {
        higherThan: bar
        higherThan: a, b, c
        lowerThan: bar
        lowerThan: a, b, c
        assignment: true
        assignment: false
        associativity: left
        associativity: right
        associativity: none
      }
      """,
      """
      precedencegroup foo {
      higherThan: bar
      higherThan: a, b, c
      lowerThan: bar
      lowerThan: a, b, c
      assignment: true
      assignment: false
      associativity: left
      associativity: right
      associativity: none
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 11, 2))
      }
    )
  }

  static var allTests = [
    ("testName", testName),
    ("testHigherThanSingle", testHigherThanSingle),
    ("testHigherThanMultiple", testHigherThanMultiple),
    ("testLowerThanSingle", testLowerThanSingle),
    ("testLowerThanMultiple", testLowerThanMultiple),
    ("testAssignmentTrue", testAssignmentTrue),
    ("testAssignmentFalse", testAssignmentFalse),
    ("testAssociativityLeft", testAssociativityLeft),
    ("testAssociativityRight", testAssociativityRight),
    ("testAssociativityNone", testAssociativityNone),
    ("testCombination", testCombination),
    ("testSourceRange", testSourceRange),
  ]
}
