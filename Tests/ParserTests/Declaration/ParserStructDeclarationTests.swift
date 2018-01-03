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

class ParserStructDeclarationTests: XCTestCase {
  func testName() {
    parseDeclarationAndTest("struct Foo {}", "struct Foo {}", testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a @b @c struct Foo {}", "@a @b @c struct Foo {}", testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertEqual(structDecl.attributes.count, 3)
      XCTAssertEqual(structDecl.attributes.textDescription, "@a @b @c")
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      parseDeclarationAndTest(
        "\(modifier.textDescription) struct Foo {}",
        "\(modifier.textDescription) struct Foo {}",
        testClosure: { decl in
        guard let structDecl = decl as? StructDeclaration else {
          XCTFail("Failed in getting a struct declaration.")
          return
        }

        XCTAssertTrue(structDecl.attributes.isEmpty)
        XCTAssertEqual(structDecl.accessLevelModifier, modifier)
        XCTAssertEqual(structDecl.name.textDescription, "Foo")
        XCTAssertNil(structDecl.genericParameterClause)
        XCTAssertNil(structDecl.typeInheritanceClause)
        XCTAssertNil(structDecl.genericWhereClause)
        XCTAssertTrue(structDecl.members.isEmpty)
      })
    }
  }

  func testAttributesAndModifier() {
    parseDeclarationAndTest(
      "@a public struct Foo {}",
      "@a public struct Foo {}",
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertEqual(structDecl.attributes.count, 1)
      XCTAssertEqual(structDecl.attributes.textDescription, "@a")
      XCTAssertEqual(structDecl.accessLevelModifier, .public)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testGenericParameterClause() {
    parseDeclarationAndTest(
      "struct Foo<A, B: C, D: E, F, G> {}",
      "struct Foo<A, B: C, D: E, F, G> {}",
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertEqual(structDecl.genericParameterClause?.textDescription, "<A, B: C, D: E, F, G>")
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testTypeInheritance() {
    parseDeclarationAndTest("struct Foo: String {}", "struct Foo: String {}", testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertEqual(structDecl.typeInheritanceClause?.textDescription, ": String")
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "struct Foo where Foo == Bar {}",
      "struct Foo where Foo == Bar {}",
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertEqual(structDecl.genericWhereClause?.textDescription, "where Foo == Bar")
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testGenericParameterTypeInheritanceAndGenericWhere() {
    parseDeclarationAndTest(
      "struct Foo<T> : Array<T> where T : Int & Double {}",
      "struct Foo<T>: Array<T> where T: protocol<Int, Double> {}",
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertEqual(structDecl.genericParameterClause?.textDescription, "<T>")
      XCTAssertEqual(structDecl.typeInheritanceClause?.textDescription, ": Array<T>")
      XCTAssertEqual(structDecl.genericWhereClause?.textDescription, "where T: protocol<Int, Double>")
      XCTAssertTrue(structDecl.members.isEmpty)
    })
  }

  func testDeclarationMember() {
    parseDeclarationAndTest(
      "struct Foo { let a = 1 }",
      "struct Foo {\nlet a = 1\n}",
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertEqual(structDecl.members.count, 1)
      guard case .declaration(let memberDecl) = structDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is ConstantDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "let a = 1")
    })
  }

  func testMultipleDeclarationMembers() {
    parseDeclarationAndTest(
      "struct Foo { let a = 1 var b = 2  }",
      """
      struct Foo {
      let a = 1
      var b = 2
      }
      """,
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertEqual(structDecl.members.count, 2)
      XCTAssertEqual(structDecl.members[0].textDescription, "let a = 1")
      XCTAssertEqual(structDecl.members[1].textDescription, "var b = 2")
    })
  }

  func testNestedStructDecl() {
    parseDeclarationAndTest(
      "struct Foo { struct Bar { let b = 2 } }",
      """
      struct Foo {
      struct Bar {
      let b = 2
      }
      }
      """,
      testClosure: { decl in
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertEqual(structDecl.members.count, 1)
      guard case .declaration(let memberDecl) = structDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is StructDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "struct Bar {\nlet b = 2\n}")
    })
  }

  func testMembersWithSemicolons() {
    parseDeclarationAndTest("struct Foo { let issue = 61; }", "struct Foo {\nlet issue = 61\n}")
  }

  func testCompilerControlMember() {
    parseDeclarationAndTest(
      """
      struct Foo { #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      """
      struct Foo {
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
      guard let structDecl = decl as? StructDeclaration else {
        XCTFail("Failed in getting a struct declaration.")
        return
      }

      XCTAssertTrue(structDecl.attributes.isEmpty)
      XCTAssertNil(structDecl.accessLevelModifier)
      XCTAssertEqual(structDecl.name.textDescription, "Foo")
      XCTAssertNil(structDecl.genericParameterClause)
      XCTAssertNil(structDecl.typeInheritanceClause)
      XCTAssertNil(structDecl.genericWhereClause)
      XCTAssertEqual(structDecl.members.count, 7)
      XCTAssertEqual(structDecl.members[0].textDescription, "#if a")
      XCTAssertEqual(structDecl.members[1].textDescription, "let a = 1")
      XCTAssertEqual(structDecl.members[2].textDescription, "#elseif b")
      XCTAssertEqual(structDecl.members[3].textDescription, "let b = 2")
      XCTAssertEqual(structDecl.members[4].textDescription, "#else")
      XCTAssertEqual(structDecl.members[5].textDescription, "let e = 3")
      XCTAssertEqual(structDecl.members[6].textDescription, "#endif")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "@a public struct Foo {}",
      "@a public struct Foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 24))
      }
    )
    parseDeclarationAndTest(
      "struct Foo { let a = 1 var b = 2  }",
      """
      struct Foo {
      let a = 1
      var b = 2
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 36))
      }
    )
    parseDeclarationAndTest(
      """
      struct Foo { #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      """
      struct Foo {
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
  }

  static var allTests = [
    ("testName", testName),
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributesAndModifier", testAttributesAndModifier),
    ("testGenericParameterClause", testGenericParameterClause),
    ("testTypeInheritance", testTypeInheritance),
    ("testGenericWhereClause", testGenericWhereClause),
    ("testGenericParameterTypeInheritanceAndGenericWhere", testGenericParameterTypeInheritanceAndGenericWhere),
    ("testDeclarationMember", testDeclarationMember),
    ("testMultipleDeclarationMembers", testMultipleDeclarationMembers),
    ("testNestedStructDecl", testNestedStructDecl),
    ("testMembersWithSemicolons", testMembersWithSemicolons),
    ("testCompilerControlMember", testCompilerControlMember),
    ("testSourceRange", testSourceRange),
  ]
}
