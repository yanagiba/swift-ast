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

class ParserTypealiasDeclarationTests: XCTestCase {
  func testTypealias() {
    parseDeclarationAndTest("typealias Foo = Bar", "typealias Foo = Bar", testClosure: { decl in
      guard let typealiasDecl = decl as? TypealiasDeclaration else {
        XCTFail("Failed in getting a typealias declaration.")
        return
      }

      XCTAssertTrue(typealiasDecl.attributes.isEmpty)
      XCTAssertNil(typealiasDecl.accessLevelModifier)
      XCTAssertEqual(typealiasDecl.name.textDescription, "Foo")
      XCTAssertNil(typealiasDecl.generic)
      XCTAssertTrue(typealiasDecl.assignment is TypeIdentifier)
      XCTAssertEqual(typealiasDecl.assignment.textDescription, "Bar")
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a @b @c typealias Foo = Bar", "@a @b @c typealias Foo = Bar", testClosure: { decl in
      guard let typealiasDecl = decl as? TypealiasDeclaration else {
        XCTFail("Failed in getting a typealias declaration.")
        return
      }

      XCTAssertEqual(typealiasDecl.attributes.count, 3)
      XCTAssertEqual(typealiasDecl.attributes.textDescription, "@a @b @c")
      XCTAssertNil(typealiasDecl.accessLevelModifier)
      XCTAssertEqual(typealiasDecl.name.textDescription, "Foo")
      XCTAssertNil(typealiasDecl.generic)
      XCTAssertTrue(typealiasDecl.assignment is TypeIdentifier)
      XCTAssertEqual(typealiasDecl.assignment.textDescription, "Bar")
    })
  }

  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      parseDeclarationAndTest(
        "\(modifier.textDescription) typealias Foo = Bar",
        "\(modifier.textDescription) typealias Foo = Bar",
        testClosure: { decl in
        guard let typealiasDecl = decl as? TypealiasDeclaration else {
          XCTFail("Failed in getting a typealias declaration.")
          return
        }

        XCTAssertTrue(typealiasDecl.attributes.isEmpty)
        XCTAssertEqual(typealiasDecl.accessLevelModifier, modifier)
        XCTAssertEqual(typealiasDecl.name.textDescription, "Foo")
        XCTAssertNil(typealiasDecl.generic)
        XCTAssertTrue(typealiasDecl.assignment is TypeIdentifier)
        XCTAssertEqual(typealiasDecl.assignment.textDescription, "Bar")
      })
    }
  }

  func testAttributesAndModifier() {
    parseDeclarationAndTest(
      "@a public typealias Foo = Bar",
      "@a public typealias Foo = Bar",
      testClosure: { decl in
      guard let typealiasDecl = decl as? TypealiasDeclaration else {
        XCTFail("Failed in getting a typealias declaration.")
        return
      }

      XCTAssertEqual(typealiasDecl.attributes.count, 1)
      XCTAssertEqual(typealiasDecl.attributes.textDescription, "@a")
      XCTAssertEqual(typealiasDecl.accessLevelModifier, .public)
      XCTAssertEqual(typealiasDecl.name.textDescription, "Foo")
      XCTAssertNil(typealiasDecl.generic)
      XCTAssertTrue(typealiasDecl.assignment is TypeIdentifier)
      XCTAssertEqual(typealiasDecl.assignment.textDescription, "Bar")
    })
  }

  func testGeneric() {
    parseDeclarationAndTest(
      "typealias Foo<A, B: C, D: E, F, G> = (a, b, c) throws -> Bar<A, B, C>",
      "typealias Foo<A, B: C, D: E, F, G> = (a, b, c) throws -> Bar<A, B, C>",
      testClosure: { decl in
      guard let typealiasDecl = decl as? TypealiasDeclaration else {
        XCTFail("Failed in getting a typealias declaration.")
        return
      }

      XCTAssertTrue(typealiasDecl.attributes.isEmpty)
      XCTAssertNil(typealiasDecl.accessLevelModifier)
      XCTAssertEqual(typealiasDecl.name.textDescription, "Foo")
      XCTAssertEqual(typealiasDecl.generic?.textDescription, "<A, B: C, D: E, F, G>")
      XCTAssertTrue(typealiasDecl.assignment is FunctionType)
      XCTAssertEqual(typealiasDecl.assignment.textDescription, "(a, b, c) throws -> Bar<A, B, C>")
    })
  }

  func testAttributesAndModifierAndGeneric() {
    parseDeclarationAndTest(
      "@a public typealias Foo<A> = Bar",
      "@a public typealias Foo<A> = Bar",
      testClosure: { decl in
      guard let typealiasDecl = decl as? TypealiasDeclaration else {
        XCTFail("Failed in getting a typealias declaration.")
        return
      }

      XCTAssertEqual(typealiasDecl.attributes.count, 1)
      XCTAssertEqual(typealiasDecl.attributes.textDescription, "@a")
      XCTAssertEqual(typealiasDecl.accessLevelModifier, .public)
      XCTAssertEqual(typealiasDecl.name.textDescription, "Foo")
      XCTAssertEqual(typealiasDecl.generic?.textDescription, "<A>")
      XCTAssertTrue(typealiasDecl.assignment is TypeIdentifier)
      XCTAssertEqual(typealiasDecl.assignment.textDescription, "Bar")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "@a public typealias Foo<A> = Bar",
      "@a public typealias Foo<A> = Bar",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 33))
      }
    )
  }

  static var allTests = [
    ("testTypealias", testTypealias),
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributesAndModifier", testAttributesAndModifier),
    ("testGeneric", testGeneric),
    ("testAttributesAndModifierAndGeneric", testAttributesAndModifierAndGeneric),
    ("testSourceRange", testSourceRange),
  ]
}
