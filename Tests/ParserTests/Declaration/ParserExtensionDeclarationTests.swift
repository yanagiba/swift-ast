/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserExtensionDeclarationTests: XCTestCase {
  func testName() {
    parseDeclarationAndTest("extension Foo {}", "extension Foo {}", testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertTrue(extDecl.members.isEmpty)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a @b @c extension Foo {}", "@a @b @c extension Foo {}", testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertEqual(extDecl.attributes.count, 3)
      XCTAssertEqual(extDecl.attributes.textDescription, "@a @b @c")
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertTrue(extDecl.members.isEmpty)
    })
  }

  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      parseDeclarationAndTest(
        "\(modifier.textDescription) extension Foo {}",
        "\(modifier.textDescription) extension Foo {}",
        testClosure: { decl in
        guard let extDecl = decl as? ExtensionDeclaration else {
          XCTFail("Failed in getting an extension declaration.")
          return
        }

        XCTAssertTrue(extDecl.attributes.isEmpty)
        XCTAssertEqual(extDecl.accessLevelModifier, modifier)
        XCTAssertEqual(extDecl.type.textDescription, "Foo")
        XCTAssertNil(extDecl.typeInheritanceClause)
        XCTAssertNil(extDecl.genericWhereClause)
        XCTAssertTrue(extDecl.members.isEmpty)
      })
    }
  }

  func testAttributesAndModifier() {
    parseDeclarationAndTest(
      "@a public extension Foo {}",
      "@a public extension Foo {}",
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertEqual(extDecl.attributes.count, 1)
      XCTAssertEqual(extDecl.attributes.textDescription, "@a")
      XCTAssertEqual(extDecl.accessLevelModifier, .public)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertTrue(extDecl.members.isEmpty)
    })
  }

  func testTypeIdentifierWithGeneric() {
    parseDeclarationAndTest(
      "extension a.b<x, y>.c.Foo<A, B, C> {}",
      "extension a.b<x, y>.c.Foo<A, B, C> {}",
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "a.b<x, y>.c.Foo<A, B, C>")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertTrue(extDecl.members.isEmpty)
    })
  }

  func testTypeInheritance() {
    parseDeclarationAndTest(
      "extension Foo: String {}",
      "extension Foo: String {}",
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertEqual(extDecl.typeInheritanceClause?.textDescription, ": String")
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertTrue(extDecl.members.isEmpty)
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "extension Foo where Foo == Bar {}",
      "extension Foo where Foo == Bar {}",
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertEqual(extDecl.genericWhereClause?.textDescription, "where Foo == Bar")
      XCTAssertTrue(extDecl.members.isEmpty)
    })
  }

  func testDeclarationMember() {
    parseDeclarationAndTest(
      "extension Foo { let a = 1 }",
      "extension Foo {\nlet a = 1\n}",
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertEqual(extDecl.members.count, 1)
      guard case .declaration(let memberDecl) = extDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is ConstantDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "let a = 1")
    })
  }

  func testMultipleDeclarationMembers() {
    parseDeclarationAndTest(
      "extension Foo { let a = 1 var b = 2  }",
      """
      extension Foo {
      let a = 1
      var b = 2
      }
      """,
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertEqual(extDecl.members.count, 2)
      XCTAssertEqual(extDecl.members[0].textDescription, "let a = 1")
      XCTAssertEqual(extDecl.members[1].textDescription, "var b = 2")
    })
  }

  func testMembersWithSemicolons() {
    parseDeclarationAndTest("extension Foo { let issue = 61; }", "extension Foo {\nlet issue = 61\n}")
  }

  func testCompilerControlMember() {
    parseDeclarationAndTest(
      """
      extension Foo { #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      """
      extension Foo {
      #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      testClosure: { decl in
      guard let extDecl = decl as? ExtensionDeclaration else {
        XCTFail("Failed in getting an extension declaration.")
        return
      }

      XCTAssertTrue(extDecl.attributes.isEmpty)
      XCTAssertNil(extDecl.accessLevelModifier)
      XCTAssertEqual(extDecl.type.textDescription, "Foo")
      XCTAssertNil(extDecl.typeInheritanceClause)
      XCTAssertNil(extDecl.genericWhereClause)
      XCTAssertEqual(extDecl.members.count, 7)
      XCTAssertEqual(extDecl.members[0].textDescription, "#if a")
      XCTAssertEqual(extDecl.members[1].textDescription, "let a = 1")
      XCTAssertEqual(extDecl.members[2].textDescription, "#elseif b")
      XCTAssertEqual(extDecl.members[3].textDescription, "let b = 2")
      XCTAssertEqual(extDecl.members[4].textDescription, "#else")
      XCTAssertEqual(extDecl.members[5].textDescription, "let e = 3")
      XCTAssertEqual(extDecl.members[6].textDescription, "#endif")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "private extension Foo {}",
      "private extension Foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 25))
      }
    )
    parseDeclarationAndTest(
      """
      extension Foo { #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      """
      extension Foo {
      #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 8, 2))
      }
    )
    parseDeclarationAndTest(
      "extension Foo { let a = 1 var b = 2  }",
      """
      extension Foo {
      let a = 1
      var b = 2
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 39))
      }
    )
  }

  static var allTests = [
    ("testName", testName),
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributesAndModifier", testAttributesAndModifier),
    ("testTypeIdentifierWithGeneric", testTypeIdentifierWithGeneric),
    ("testTypeInheritance", testTypeInheritance),
    ("testGenericWhereClause", testGenericWhereClause),
    ("testDeclarationMember", testDeclarationMember),
    ("testMultipleDeclarationMembers", testMultipleDeclarationMembers),
    ("testMembersWithSemicolons", testMembersWithSemicolons),
    ("testCompilerControlMember", testCompilerControlMember),
    ("testSourceRange", testSourceRange),
  ]
}
