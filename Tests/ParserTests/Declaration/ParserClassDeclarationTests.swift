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

class ParserClassDeclarationTests: XCTestCase {
  func testName() {
    parseDeclarationAndTest("class Foo {}", "class Foo {}", testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a @b @c class Foo {}", "@a @b @c class Foo {}", testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertEqual(classDecl.attributes.count, 3)
      XCTAssertEqual(classDecl.attributes.textDescription, "@a @b @c")
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      parseDeclarationAndTest(
        "\(modifier.textDescription) class Foo {}",
        "\(modifier.textDescription) class Foo {}",
        testClosure: { decl in
        guard let classDecl = decl as? ClassDeclaration else {
          XCTFail("Failed in getting a class declaration.")
          return
        }

        XCTAssertTrue(classDecl.attributes.isEmpty)
        XCTAssertEqual(classDecl.accessLevelModifier, modifier)
        ASTTextEqual(classDecl.name, "Foo")
        XCTAssertNil(classDecl.genericParameterClause)
        XCTAssertNil(classDecl.typeInheritanceClause)
        XCTAssertNil(classDecl.genericWhereClause)
        XCTAssertTrue(classDecl.members.isEmpty)
      })
    }
  }

  func testAttributesAndModifier() {
    parseDeclarationAndTest(
      "@a public class Foo {}",
      "@a public class Foo {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertEqual(classDecl.attributes.count, 1)
      XCTAssertEqual(classDecl.attributes.textDescription, "@a")
      XCTAssertEqual(classDecl.accessLevelModifier, .public)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testFinal() {
    parseDeclarationAndTest(
      "final class Foo {}",
      "final class Foo {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      XCTAssertTrue(classDecl.isFinal)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testAttributesAndModifierAndFinal() {
    parseDeclarationAndTest(
      "@a public final class Foo {}",
      "@a public final class Foo {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertEqual(classDecl.attributes.count, 1)
      XCTAssertEqual(classDecl.attributes.textDescription, "@a")
      XCTAssertEqual(classDecl.accessLevelModifier, .public)
      XCTAssertTrue(classDecl.isFinal)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testAttributesAndFinalAndModifier() {
    parseDeclarationAndTest(
      "@a final public class Foo {}",
      "@a public final class Foo {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertEqual(classDecl.attributes.count, 1)
      XCTAssertEqual(classDecl.attributes.textDescription, "@a")
      XCTAssertEqual(classDecl.accessLevelModifier, .public)
      XCTAssertTrue(classDecl.isFinal)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testGenericParameterClause() {
    parseDeclarationAndTest(
      "class Foo<A, B: C, D: E, F, G> {}",
      "class Foo<A, B: C, D: E, F, G> {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertEqual(classDecl.genericParameterClause?.textDescription, "<A, B: C, D: E, F, G>")
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testTypeInheritance() {
    parseDeclarationAndTest("class Foo: String {}", "class Foo: String {}", testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertEqual(classDecl.typeInheritanceClause?.textDescription, ": String")
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "class Foo where Foo == Bar {}",
      "class Foo where Foo == Bar {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertEqual(classDecl.genericWhereClause?.textDescription, "where Foo == Bar")
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testGenericParameterTypeInheritanceAndGenericWhere() {
    parseDeclarationAndTest(
      "class Foo<T> : Array<T> where T : Int & Double {}",
      "class Foo<T>: Array<T> where T: protocol<Int, Double> {}",
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertEqual(classDecl.genericParameterClause?.textDescription, "<T>")
      XCTAssertEqual(classDecl.typeInheritanceClause?.textDescription, ": Array<T>")
      XCTAssertEqual(classDecl.genericWhereClause?.textDescription, "where T: protocol<Int, Double>")
      XCTAssertTrue(classDecl.members.isEmpty)
    })
  }

  func testDeclarationMember() {
    parseDeclarationAndTest(
      "class Foo { let a = 1 }",
      """
      class Foo {
      let a = 1
      }
      """,
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertEqual(classDecl.members.count, 1)
      guard case .declaration(let memberDecl) = classDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is ConstantDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "let a = 1")
    })
  }

  func testMultipleDeclarationMembers() {
    parseDeclarationAndTest(
      "class Foo { let a = 1 var b = 2  }",
      """
      class Foo {
      let a = 1
      var b = 2
      }
      """,
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertEqual(classDecl.members.count, 2)
      XCTAssertEqual(classDecl.members[0].textDescription, "let a = 1")
      XCTAssertEqual(classDecl.members[1].textDescription, "var b = 2")
    })
  }

  func testNestedClassDecl() {
    parseDeclarationAndTest(
      "class Foo { class Bar { let b = 2 } }",
      """
      class Foo {
      class Bar {
      let b = 2
      }
      }
      """,
      testClosure: { decl in
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertEqual(classDecl.members.count, 1)
      guard case .declaration(let memberDecl) = classDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is ClassDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "class Bar {\nlet b = 2\n}")
    })
  }

  func testMembersWithSemicolons() {
    parseDeclarationAndTest("class Foo { let issue = 61; }", "class Foo {\nlet issue = 61\n}")
  }

  func testCompilerControlMember() {
    parseDeclarationAndTest(
      """
      class Foo { #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      """
      class Foo {
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
      guard let classDecl = decl as? ClassDeclaration else {
        XCTFail("Failed in getting a class declaration.")
        return
      }

      XCTAssertTrue(classDecl.attributes.isEmpty)
      XCTAssertNil(classDecl.accessLevelModifier)
      ASTTextEqual(classDecl.name, "Foo")
      XCTAssertNil(classDecl.genericParameterClause)
      XCTAssertNil(classDecl.typeInheritanceClause)
      XCTAssertNil(classDecl.genericWhereClause)
      XCTAssertEqual(classDecl.members.count, 7)
      XCTAssertEqual(classDecl.members[0].textDescription, "#if a")
      XCTAssertEqual(classDecl.members[1].textDescription, "let a = 1")
      XCTAssertEqual(classDecl.members[2].textDescription, "#elseif b")
      XCTAssertEqual(classDecl.members[3].textDescription, "let b = 2")
      XCTAssertEqual(classDecl.members[4].textDescription, "#else")
      XCTAssertEqual(classDecl.members[5].textDescription, "let e = 3")
      XCTAssertEqual(classDecl.members[6].textDescription, "#endif")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "@a public class Foo {}",
      "@a public class Foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 23))
      }
    )
    parseDeclarationAndTest(
      "class Foo { let a = 1 var b = 2  }",
      """
      class Foo {
      let a = 1
      var b = 2
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 35))
      }
    )
    parseDeclarationAndTest(
      """
      class Foo { #if a
      let a = 1
      #elseif b
      let b = 2
      #else
      let e = 3
      #endif
      }
      """,
      """
      class Foo {
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
    ("testFinal", testFinal),
    ("testAttributesAndModifierAndFinal", testAttributesAndModifierAndFinal),
    ("testAttributesAndFinalAndModifier", testAttributesAndFinalAndModifier),
    ("testGenericParameterClause", testGenericParameterClause),
    ("testTypeInheritance", testTypeInheritance),
    ("testGenericWhereClause", testGenericWhereClause),
    ("testGenericParameterTypeInheritanceAndGenericWhere", testGenericParameterTypeInheritanceAndGenericWhere),
    ("testDeclarationMember", testDeclarationMember),
    ("testMultipleDeclarationMembers", testMultipleDeclarationMembers),
    ("testNestedClassDecl", testNestedClassDecl),
    ("testMembersWithSemicolons", testMembersWithSemicolons),
    ("testCompilerControlMember", testCompilerControlMember),
    ("testSourceRange", testSourceRange),
  ]
}
