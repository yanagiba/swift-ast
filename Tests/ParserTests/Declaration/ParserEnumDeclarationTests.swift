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

class ParserEnumDeclarationTests: XCTestCase {
  func testName() {
    parseDeclarationAndTest("enum Foo {}", "enum Foo {}", testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a @b @c enum Foo {}", "@a @b @c enum Foo {}", testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertEqual(enumDecl.attributes.count, 3)
      XCTAssertEqual(enumDecl.attributes.textDescription, "@a @b @c")
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      parseDeclarationAndTest(
        "\(modifier.textDescription) enum Foo {}",
        "\(modifier.textDescription) enum Foo {}",
        testClosure: { decl in
        guard let enumDecl = decl as? EnumDeclaration else {
          XCTFail("Failed in getting an enum declaration.")
          return
        }

        XCTAssertTrue(enumDecl.attributes.isEmpty)
        XCTAssertEqual(enumDecl.accessLevelModifier, modifier)
        XCTAssertFalse(enumDecl.isIndirect)
        XCTAssertEqual(enumDecl.name.textDescription, "Foo")
        XCTAssertNil(enumDecl.genericParameterClause)
        XCTAssertNil(enumDecl.typeInheritanceClause)
        XCTAssertNil(enumDecl.genericWhereClause)
        XCTAssertTrue(enumDecl.members.isEmpty)
      })
    }
  }

  func testAttributesAndModifier() {
    parseDeclarationAndTest(
      "@a public enum Foo {}",
      "@a public enum Foo {}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertEqual(enumDecl.attributes.count, 1)
      XCTAssertEqual(enumDecl.attributes.textDescription, "@a")
      XCTAssertEqual(enumDecl.accessLevelModifier, .public)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testIndirect() {
    parseDeclarationAndTest(
      "indirect enum Foo {}",
      "indirect enum Foo {}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertTrue(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testAttributesAndModifierAndIndirect() {
    parseDeclarationAndTest(
      "@a public indirect enum Foo {}",
      "@a public indirect enum Foo {}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertEqual(enumDecl.attributes.count, 1)
      XCTAssertEqual(enumDecl.attributes.textDescription, "@a")
      XCTAssertEqual(enumDecl.accessLevelModifier, .public)
      XCTAssertTrue(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testGenericParameterClause() {
    parseDeclarationAndTest(
      "enum Foo<A, B: C, D: E, F, G> {}",
      "enum Foo<A, B: C, D: E, F, G> {}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertEqual(enumDecl.genericParameterClause?.textDescription, "<A, B: C, D: E, F, G>")
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testTypeInheritance() {
    parseDeclarationAndTest("enum Foo: String {}", "enum Foo: String {}", testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": String")
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "enum Foo where Foo == Bar {}",
      "enum Foo where Foo == Bar {}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertEqual(enumDecl.genericWhereClause?.textDescription, "where Foo == Bar")
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testGenericParameterTypeInheritanceAndGenericWhere() {
    parseDeclarationAndTest(
      "enum Foo<T> : Array<T> where T : Int & Double {}",
      "enum Foo<T>: Array<T> where T: protocol<Int, Double> {}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertEqual(enumDecl.genericParameterClause?.textDescription, "<T>")
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": Array<T>")
      XCTAssertEqual(enumDecl.genericWhereClause?.textDescription, "where T: protocol<Int, Double>")
      XCTAssertTrue(enumDecl.members.isEmpty)
    })
  }

  func testDeclarationMember() {
    parseDeclarationAndTest(
      "enum Foo { let a = 1 }",
      "enum Foo {\nlet a = 1\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .declaration(let memberDecl) = enumDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is ConstantDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "let a = 1")
    })
  }

  func testNestedEnumDecl() {
    parseDeclarationAndTest(
      "enum Foo { enum Bar {} }",
      "enum Foo {\nenum Bar {}\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .declaration(let memberDecl) = enumDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertTrue(memberDecl is EnumDeclaration)
      XCTAssertEqual(memberDecl.textDescription, "enum Bar {}")
    })
  }

  func testCaseName() {
    parseDeclarationAndTest("enum Foo { case a }", "enum Foo {\ncase a\n}", testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .union(let unionCaseMember) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style case.")
        return
      }
      XCTAssertTrue(unionCaseMember.attributes.isEmpty)
      XCTAssertFalse(unionCaseMember.isIndirect)
      XCTAssertEqual(unionCaseMember.cases.count, 1)
      let unionCase = unionCaseMember.cases[0]
      XCTAssertEqual(unionCase.name.textDescription, "a")
      XCTAssertNil(unionCase.tuple)
      XCTAssertEqual(unionCaseMember.textDescription, "case a")
    })
  }

  func testCaseTuple() {
    parseDeclarationAndTest(
      "enum Foo { case a(A) }",
      "enum Foo {\ncase a(A)\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .union(let unionCaseMember) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style case.")
        return
      }
      XCTAssertTrue(unionCaseMember.attributes.isEmpty)
      XCTAssertFalse(unionCaseMember.isIndirect)
      XCTAssertEqual(unionCaseMember.cases.count, 1)
      let unionCase = unionCaseMember.cases[0]
      XCTAssertEqual(unionCase.name.textDescription, "a")
      XCTAssertEqual(unionCase.tuple?.textDescription, "(A)")
      XCTAssertEqual(unionCaseMember.textDescription, "case a(A)")
    })
  }

  func testMultipleUnionStyleCases() {
    parseDeclarationAndTest(
      "enum Foo { case a(A), b, c(A, B, C) }",
      "enum Foo {\ncase a(A), b, c(A, B, C)\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .union(let unionCaseMember) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style case.")
        return
      }
      XCTAssertTrue(unionCaseMember.attributes.isEmpty)
      XCTAssertFalse(unionCaseMember.isIndirect)
      XCTAssertEqual(unionCaseMember.cases.count, 3)
      XCTAssertEqual(unionCaseMember.textDescription, "case a(A), b, c(A, B, C)")
    })
  }

  func testCaseRawValue() {
    parseDeclarationAndTest(
      "enum Foo: Int { case a = 1 }",
      "enum Foo: Int {\ncase a = 1\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": Int")
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .rawValue(let rawStyle) = enumDecl.members[0] else {
        XCTFail("Failed in getting a raw-value-style case.")
        return
      }
      XCTAssertTrue(rawStyle.attributes.isEmpty)
      XCTAssertEqual(rawStyle.cases.count, 1)
      let rawValueCase = rawStyle.cases[0]
      XCTAssertEqual(rawValueCase.name.textDescription, "a")
      guard let assignment = rawValueCase.assignment, case .integer(let i) = assignment else {
        XCTFail("Failed in getting an assignment.")
        return
      }
      XCTAssertEqual(i, 1)
      XCTAssertEqual(rawStyle.textDescription, "case a = 1")
    })
  }

  func testMultipleRawValueStyleCases() {
    parseDeclarationAndTest(
      "enum Foo: Int { case a = 1, b, c = 999 }",
      "enum Foo: Int {\ncase a = 1, b, c = 999\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": Int")
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .rawValue(let rawStyle) = enumDecl.members[0] else {
        XCTFail("Failed in getting a raw-value-style case.")
        return
      }
      XCTAssertTrue(rawStyle.attributes.isEmpty)
      XCTAssertEqual(rawStyle.cases.count, 3)
      XCTAssertEqual(rawStyle.textDescription, "case a = 1, b, c = 999")
    })
  }

  func testIndirectCase() {
    parseDeclarationAndTest(
      "indirect enum Foo { indirect case a(Foo) }",
      "indirect enum Foo {\nindirect case a(Foo)\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertTrue(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .union(let unionCaseMember) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style case.")
        return
      }
      XCTAssertTrue(unionCaseMember.attributes.isEmpty)
      XCTAssertTrue(unionCaseMember.isIndirect)
      XCTAssertEqual(unionCaseMember.cases.count, 1)
      let unionCase = unionCaseMember.cases[0]
      XCTAssertEqual(unionCase.name.textDescription, "a")
      XCTAssertEqual(unionCase.tuple?.textDescription, "(Foo)")
      XCTAssertEqual(unionCaseMember.textDescription, "indirect case a(Foo)")
    })
  }

  func testAttributedUnionCase() {
    parseDeclarationAndTest(
      "enum Foo { @a @b @c case a }",
      "enum Foo {\n@a @b @c case a\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .union(let unionCaseMember) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style case.")
        return
      }
      XCTAssertEqual(unionCaseMember.attributes.count, 3)
      XCTAssertEqual(unionCaseMember.attributes.textDescription, "@a @b @c")
      XCTAssertFalse(unionCaseMember.isIndirect)
      XCTAssertEqual(unionCaseMember.cases.count, 1)
      let unionCase = unionCaseMember.cases[0]
      XCTAssertEqual(unionCase.name.textDescription, "a")
      XCTAssertNil(unionCase.tuple)
      XCTAssertEqual(unionCaseMember.textDescription, "@a @b @c case a")
    })
  }

  func testAttributedAndIndirectUnionCase() {
    parseDeclarationAndTest(
      "indirect enum Foo { @a indirect case a(Foo) }",
      "indirect enum Foo {\n@a indirect case a(Foo)\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertTrue(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .union(let unionCaseMember) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style case.")
        return
      }
      XCTAssertEqual(unionCaseMember.attributes.count, 1)
      XCTAssertEqual(unionCaseMember.attributes.textDescription, "@a")
      XCTAssertTrue(unionCaseMember.isIndirect)
      XCTAssertEqual(unionCaseMember.cases.count, 1)
      let unionCase = unionCaseMember.cases[0]
      XCTAssertEqual(unionCase.name.textDescription, "a")
      XCTAssertEqual(unionCase.tuple?.textDescription, "(Foo)")
      XCTAssertEqual(unionCaseMember.textDescription, "@a indirect case a(Foo)")
    })
  }

  func testAttributedRawValueCase() {
    parseDeclarationAndTest(
      "enum Foo: Int { @a @b @c case a = 1 }",
      "enum Foo: Int {\n@a @b @c case a = 1\n}",
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": Int")
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 1)
      guard case .rawValue(let rawStyle) = enumDecl.members[0] else {
        XCTFail("Failed in getting a raw-value-style case.")
        return
      }
      XCTAssertEqual(rawStyle.attributes.count, 3)
      XCTAssertEqual(rawStyle.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(rawStyle.cases.count, 1)
      let rawValueCase = rawStyle.cases[0]
      XCTAssertEqual(rawValueCase.name.textDescription, "a")
      guard let assignment = rawValueCase.assignment, case .integer(let i) = assignment else {
        XCTFail("Failed in getting an assignment.")
        return
      }
      XCTAssertEqual(i, 1)
      XCTAssertEqual(rawStyle.textDescription, "@a @b @c case a = 1")
    })
  }

  func testMultipleUnionStyleMembers() {
    parseDeclarationAndTest(
      "enum Foo { case a(A) case b case c(A, B, C) }",
      """
      enum Foo {
      case a(A)
      case b
      case c(A, B, C)
      }
      """,
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 3)
      guard case .union(_) = enumDecl.members[0] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[0].textDescription, "case a(A)")
      guard case .union(_) = enumDecl.members[1] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[1].textDescription, "case b")
      guard case .union(_) = enumDecl.members[2] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[2].textDescription, "case c(A, B, C)")
    })
  }

  func testMultipleUnionStyleMembersAndDeclarations() {
    parseDeclarationAndTest(
      "enum Foo { let a = 1 case a(A) let b = 2 case b let c = 3 case c(A, B, C) let d = 4 }",
      """
      enum Foo {
      let a = 1
      case a(A)
      let b = 2
      case b
      let c = 3
      case c(A, B, C)
      let d = 4
      }
      """,
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 7)
      guard case .declaration(_) = enumDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[0].textDescription, "let a = 1")
      guard case .union(_) = enumDecl.members[1] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[1].textDescription, "case a(A)")
      guard case .declaration(_) = enumDecl.members[2] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[2].textDescription, "let b = 2")
      guard case .union(_) = enumDecl.members[3] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[3].textDescription, "case b")
      guard case .declaration(_) = enumDecl.members[4] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[4].textDescription, "let c = 3")
      guard case .union(_) = enumDecl.members[5] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[5].textDescription, "case c(A, B, C)")
      guard case .declaration(_) = enumDecl.members[6] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[6].textDescription, "let d = 4")
    })
  }

  func testMultipleRawValueStyleMembers() {
    parseDeclarationAndTest(
      "enum Foo: Int { case a case b = 1 case c = 999 }",
      """
      enum Foo: Int {
      case a
      case b = 1
      case c = 999
      }
      """,
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": Int")
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 3)
      guard case .rawValue(_) = enumDecl.members[0] else {
        XCTFail("Failed in getting a raw-value-style case.")
        return
      }
      XCTAssertEqual(enumDecl.members[0].textDescription, "case a")
      guard case .rawValue(_) = enumDecl.members[1] else {
        XCTFail("Failed in getting a raw-value-style case.")
        return
      }
      XCTAssertEqual(enumDecl.members[1].textDescription, "case b = 1")
      guard case .rawValue(_) = enumDecl.members[2] else {
        XCTFail("Failed in getting a raw-value-style case.")
        return
      }
      XCTAssertEqual(enumDecl.members[2].textDescription, "case c = 999")
    })
  }

  func testMultipleRawValueStyleMembersAndDeclarations() {
    parseDeclarationAndTest(
      "enum Foo: Int { let a = 1 case a let b = 2 case b = 1 let c = 3 case c = 999 let d = 4 }",
      """
      enum Foo: Int {
      let a = 1
      case a
      let b = 2
      case b = 1
      let c = 3
      case c = 999
      let d = 4
      }
      """,
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertEqual(enumDecl.typeInheritanceClause?.textDescription, ": Int")
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 7)
      guard case .declaration(_) = enumDecl.members[0] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[0].textDescription, "let a = 1")
      guard case .rawValue(_) = enumDecl.members[1] else {
        XCTFail("Failed in getting a raw-value-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[1].textDescription, "case a")
      guard case .declaration(_) = enumDecl.members[2] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[2].textDescription, "let b = 2")
      guard case .rawValue(_) = enumDecl.members[3] else {
        XCTFail("Failed in getting a raw-value-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[3].textDescription, "case b = 1")
      guard case .declaration(_) = enumDecl.members[4] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[4].textDescription, "let c = 3")
      guard case .rawValue(_) = enumDecl.members[5] else {
        XCTFail("Failed in getting a raw-value-style member.")
        return
      }
      XCTAssertEqual(enumDecl.members[5].textDescription, "case c = 999")
      guard case .declaration(_) = enumDecl.members[6] else {
        XCTFail("Failed in getting a declaration member.")
        return
      }
      XCTAssertEqual(enumDecl.members[6].textDescription, "let d = 4")
    })
  }

  func testVariousTypesOfRawValueLiterals() {
    parseDeclarationAndTest(
      """
      enum Foo: Int {
        case a, b = 2
        case c = 3, d, e = 5
      }
      """,
      """
      enum Foo: Int {
      case a, b = 2
      case c = 3, d, e = 5
      }
      """)
    parseDeclarationAndTest(
      """
      enum Foo: Double {
      case a, b = 2.34
      case c = 3.0, d, e = 5.1
      }
      """,
      """
      enum Foo: Double {
      case a, b = 2.34
      case c = 3.0, d, e = 5.1
      }
      """)
    parseDeclarationAndTest(
      """
      enum Foo: String {
      case a, b = "b"
      case c = "c", d, e = "E"
      }
      """,
      """
      enum Foo: String {
      case a, b = "b"
      case c = "c", d, e = "E"
      }
      """)
    parseDeclarationAndTest(
      """
      enum Foo: Bool {
      case a, b = true
      case c = false, d, e = true
      }
      """,
      """
      enum Foo: Bool {
      case a, b = true
      case c = false, d, e = true
      }
      """)
  }

  func testErrorCases() {
    // indirect has to be union-style
    parseDeclarationAndTest(
      "indirect enum Foo: Int { case b = 1 }",
      "", errorClosure: { _ in })
    parseDeclarationAndTest(
      "enum Foo: Int { indirect case a case b = 1 }",
      "", errorClosure: { _ in })
    parseDeclarationAndTest(
      "enum Foo: Int { indirect case a, b = 1 }",
      "", errorClosure: { _ in })

    // mix union-style and raw-value-style
    parseDeclarationAndTest(
      "enum Foo: Int { case a(A) case b = 1 }",
      "", errorClosure: { _ in })
    parseDeclarationAndTest(
      "enum Foo: Int { case a(A), b = 1 }",
      "", errorClosure: { _ in })
      parseDeclarationAndTest(
        "enum Foo: Int { case a(A) = 1 }",
        "", errorClosure: { _ in })

    // raw-value-style doesn't have type-inheritance
    parseDeclarationAndTest(
      "enum Foo { case a = 1 }",
      "", errorClosure: { _ in })
  }

  func testMembersWithSemicolons() {
    parseDeclarationAndTest("enum Foo { let issue = 61; }", "enum Foo {\nlet issue = 61\n}")
  }

  func testCompilerControlMember() {
    parseDeclarationAndTest(
      """
      enum Foo { #if a
      case a(A)
      #elseif b
      case b
      #else
      case c(A, B, C)
      #endif
      }
      """,
      """
      enum Foo {
      #if a
      case a(A)
      #elseif b
      case b
      #else
      case c(A, B, C)
      #endif
      }
      """,
      testClosure: { decl in
      guard let enumDecl = decl as? EnumDeclaration else {
        XCTFail("Failed in getting an enum declaration.")
        return
      }

      XCTAssertTrue(enumDecl.attributes.isEmpty)
      XCTAssertNil(enumDecl.accessLevelModifier)
      XCTAssertFalse(enumDecl.isIndirect)
      XCTAssertEqual(enumDecl.name.textDescription, "Foo")
      XCTAssertNil(enumDecl.genericParameterClause)
      XCTAssertNil(enumDecl.typeInheritanceClause)
      XCTAssertNil(enumDecl.genericWhereClause)
      XCTAssertEqual(enumDecl.members.count, 7)
      guard case .compilerControl(_) = enumDecl.members[0] else {
        XCTFail("Failed in getting a compiler control member.")
        return
      }
      guard case .union(_) = enumDecl.members[1] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      guard case .compilerControl(_) = enumDecl.members[2] else {
        XCTFail("Failed in getting a compiler control member.")
        return
      }
      guard case .union(_) = enumDecl.members[3] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      guard case .compilerControl(_) = enumDecl.members[4] else {
        XCTFail("Failed in getting a compiler control member.")
        return
      }
      guard case .union(_) = enumDecl.members[5] else {
        XCTFail("Failed in getting a union-style member.")
        return
      }
      guard case .compilerControl(_) = enumDecl.members[6] else {
        XCTFail("Failed in getting a compiler control member.")
        return
      }
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "@a enum Foo {}",
      "@a enum Foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 15))
      }
    )
    parseDeclarationAndTest(
      "enum Foo: Int { let a = 1 case a let b = 2 case b = 1 let c = 3 case c = 999 let d = 4 }",
      """
      enum Foo: Int {
      let a = 1
      case a
      let b = 2
      case b = 1
      let c = 3
      case c = 999
      let d = 4
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 89))
      }
    )
    parseDeclarationAndTest(
      """
      enum Foo { #if a
      case a(A)
      #elseif b
      case b
      #else
      case c(A, B, C)
      #endif
      }
      """,
      """
      enum Foo {
      #if a
      case a(A)
      #elseif b
      case b
      #else
      case c(A, B, C)
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
    ("testIndirect", testIndirect),
    ("testAttributesAndModifierAndIndirect", testAttributesAndModifierAndIndirect),
    ("testGenericParameterClause", testGenericParameterClause),
    ("testTypeInheritance", testTypeInheritance),
    ("testGenericWhereClause", testGenericWhereClause),
    ("testGenericParameterTypeInheritanceAndGenericWhere", testGenericParameterTypeInheritanceAndGenericWhere),
    ("testDeclarationMember", testDeclarationMember),
    ("testNestedEnumDecl", testNestedEnumDecl),
    ("testCaseName", testCaseName),
    ("testCaseTuple", testCaseTuple),
    ("testMultipleUnionStyleCases", testMultipleUnionStyleCases),
    ("testCaseRawValue", testCaseRawValue),
    ("testMultipleRawValueStyleCases", testMultipleRawValueStyleCases),
    ("testIndirectCase", testIndirectCase),
    ("testAttributedUnionCase", testAttributedUnionCase),
    ("testAttributedAndIndirectUnionCase", testAttributedAndIndirectUnionCase),
    ("testAttributedRawValueCase", testAttributedRawValueCase),
    ("testMultipleUnionStyleMembers", testMultipleUnionStyleMembers),
    ("testMultipleUnionStyleMembersAndDeclarations", testMultipleUnionStyleMembersAndDeclarations),
    ("testMultipleRawValueStyleMembers", testMultipleRawValueStyleMembers),
    ("testMultipleRawValueStyleMembersAndDeclarations", testMultipleRawValueStyleMembersAndDeclarations),
    ("testVariousTypesOfRawValueLiterals", testVariousTypesOfRawValueLiterals),
    ("testErrorCases", testErrorCases),
    ("testMembersWithSemicolons", testMembersWithSemicolons),
    ("testCompilerControlMember", testCompilerControlMember),
    ("testSourceRange", testSourceRange),
  ]
}
