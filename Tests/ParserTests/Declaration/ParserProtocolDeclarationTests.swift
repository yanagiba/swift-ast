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

class ParserProtocolDeclarationTests: XCTestCase {
  func testName() {
    parseDeclarationAndTest("protocol Foo {}", "protocol Foo {}", testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertTrue(protocolDecl.members.isEmpty)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a @b @c protocol Foo {}", "@a @b @c protocol Foo {}", testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertEqual(protocolDecl.attributes.count, 3)
      XCTAssertEqual(protocolDecl.attributes.textDescription, "@a @b @c")
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertTrue(protocolDecl.members.isEmpty)
    })
  }

  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      parseDeclarationAndTest(
        "\(modifier.textDescription) protocol Foo {}",
        "\(modifier.textDescription) protocol Foo {}",
        testClosure: { decl in
        guard let protocolDecl = decl as? ProtocolDeclaration else {
          XCTFail("Failed in getting a protocol declaration.")
          return
        }

        XCTAssertTrue(protocolDecl.attributes.isEmpty)
        XCTAssertEqual(protocolDecl.accessLevelModifier, modifier)
        XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
        XCTAssertNil(protocolDecl.typeInheritanceClause)
        XCTAssertTrue(protocolDecl.members.isEmpty)
      })
    }
  }

  func testAttributesAndModifier() {
    parseDeclarationAndTest(
      "@a public protocol Foo {}",
      "@a public protocol Foo {}",
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertEqual(protocolDecl.attributes.count, 1)
      XCTAssertEqual(protocolDecl.attributes.textDescription, "@a")
      XCTAssertEqual(protocolDecl.accessLevelModifier, .public)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertTrue(protocolDecl.members.isEmpty)
    })
  }

  func testTypeInheritance() {
    parseDeclarationAndTest(
      "protocol Foo: String {}",
      "protocol Foo: String {}",
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertEqual(protocolDecl.typeInheritanceClause?.textDescription, ": String")
      XCTAssertTrue(protocolDecl.members.isEmpty)
    })
  }

  func testPropertyMember() {
    parseDeclarationAndTest(
      "protocol Foo { var bar: Bar { get } }",
      """
      protocol Foo {
      var bar: Bar {
      get
      }
      }
      """,
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 1)
      guard case .property(let member) = protocolDecl.members[0] else {
        XCTFail("Failed in getting a property member.")
        return
      }
      XCTAssertTrue(member.attributes.isEmpty)
      XCTAssertTrue(member.modifiers.isEmpty)
      XCTAssertEqual(member.name.textDescription, "bar")
      XCTAssertEqual(member.typeAnnotation.textDescription, ": Bar")
      XCTAssertEqual(member.getterSetterKeywordBlock.textDescription, "{\nget\n}")
    })
  }

  func testPropertyMemberWithAttributes() {
    parseDeclarationAndTest(
      "protocol Foo { @a @b @c var bar: Bar { get } }",
      """
      protocol Foo {
      @a @b @c var bar: Bar {
      get
      }
      }
      """)
  }

  func testPropertyMemberWithModifier() {
    parseDeclarationAndTest(
      "protocol Foo { public var bar: Bar { get } }",
      """
      protocol Foo {
      public var bar: Bar {
      get
      }
      }
      """)
  }

  func testPropertyMemberWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "protocol Foo { @a @b @c public var bar: Bar { get } }",
      """
      protocol Foo {
      @a @b @c public var bar: Bar {
      get
      }
      }
      """)
  }

  func testMethodMember() {
    parseDeclarationAndTest(
      "protocol Foo { @discardableResult public func foo<String>(a: A, b: B, c: C) where A: String }",
      "protocol Foo {\n@discardableResult public func foo<String>(a: A, b: B, c: C) where A: String\n}",
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 1)
      guard case .method(let member) = protocolDecl.members[0] else {
        XCTFail("Failed in getting a method member.")
        return
      }
      XCTAssertEqual(member.attributes.textDescription, "@discardableResult")
      XCTAssertEqual(member.modifiers.textDescription, "public")
      XCTAssertEqual(member.name.textDescription, "foo")
      XCTAssertEqual(member.genericParameter?.textDescription, "<String>")
      XCTAssertEqual(member.signature.textDescription, "(a: A, b: B, c: C)")
      XCTAssertEqual(member.genericWhere?.textDescription, "where A: String")
    })
  }

  func testInitializerMember() {
    parseDeclarationAndTest(
      "protocol Foo { @x @y public init?<String>(a: A, b: B, c: C) throws where A: String }",
      "protocol Foo {\n@x @y public init?<String>(a: A, b: B, c: C) throws where A: String\n}",
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 1)
      guard case .initializer(let member) = protocolDecl.members[0] else {
        XCTFail("Failed in getting an initializer member.")
        return
      }
      XCTAssertEqual(member.attributes.textDescription, "@x @y")
      XCTAssertEqual(member.modifiers.textDescription, "public")
      XCTAssertEqual(member.kind, .optionalFailable)
      XCTAssertEqual(member.genericParameter?.textDescription, "<String>")
      XCTAssertEqual(member.parameterList.count, 3)
      XCTAssertEqual(member.parameterList[0].textDescription, "a: A")
      XCTAssertEqual(member.parameterList[1].textDescription, "b: B")
      XCTAssertEqual(member.parameterList[2].textDescription, "c: C")
      XCTAssertEqual(member.throwsKind, .throwing)
      XCTAssertEqual(member.genericWhere?.textDescription, "where A: String")
    })
  }

  func testSubscriptMember() {
    parseDeclarationAndTest(
      "protocol Foo { @a fileprivate subscript<T, S>(i: Int, j: Int) -> @b Self where T: S { set get }}",
      """
      protocol Foo {
      @a fileprivate subscript<T, S>(i: Int, j: Int) -> @b Self where T: S {
      get
      set
      }
      }
      """,
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 1)
      guard case .subscript(let member) = protocolDecl.members[0] else {
        XCTFail("Failed in getting a subscript member.")
        return
      }
      XCTAssertEqual(member.attributes.textDescription, "@a")
      XCTAssertEqual(member.modifiers.textDescription, "fileprivate")
      XCTAssertEqual(member.genericParameter?.textDescription, "<T, S>")
      XCTAssertEqual(member.parameterList.count, 2)
      XCTAssertEqual(member.parameterList[0].textDescription, "i: Int")
      XCTAssertEqual(member.parameterList[1].textDescription, "j: Int")
      XCTAssertEqual(member.resultAttributes.textDescription, "@b")
      XCTAssertTrue(member.resultType is SelfType)
      XCTAssertEqual(member.genericWhere?.textDescription, "where T: S")
      XCTAssertEqual(member.getterSetterKeywordBlock.textDescription, "{\nget\nset\n}")
    })
  }

  func testAssociatedTypeMember() {
    parseDeclarationAndTest(
      "protocol Foo { @a fileprivate associatedtype foo: Bar = bar where Foo: Bar }",
      "protocol Foo {\n@a fileprivate associatedtype foo: Bar = bar where Foo: Bar\n}",
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 1)
      guard case .associatedType(let member) = protocolDecl.members[0] else {
        XCTFail("Failed in getting an associated-type member.")
        return
      }
      XCTAssertEqual(member.attributes.textDescription, "@a")
      XCTAssertEqual(member.accessLevelModifier?.textDescription, "fileprivate")
      XCTAssertEqual(member.name.textDescription, "foo")
      XCTAssertEqual(member.typeInheritance?.textDescription, ": Bar")
      XCTAssertEqual(member.assignmentType?.textDescription, "bar")
      XCTAssertEqual(member.genericWhere?.textDescription, "where Foo: Bar")
    })
  }

  func testCompilerControlMember() {
    parseDeclarationAndTest(
      """
      protocol Foo {
      #if bar
      var bar: Bar { get }
      #endif
      }
      """,
      """
      protocol Foo {
      #if bar
      var bar: Bar {
      get
      }
      #endif
      }
      """,
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 3)
      guard case .compilerControl(_) = protocolDecl.members[0] else {
        XCTFail("Failed in getting a compiler-control member.")
        return
      }
      guard case .property(_) = protocolDecl.members[1] else {
        XCTFail("Failed in getting a property member.")
        return
      }
      guard case .compilerControl(_) = protocolDecl.members[2] else {
        XCTFail("Failed in getting a compiler-control member.")
        return
      }
    })
  }

  func testMembers() {
    parseDeclarationAndTest(
      """
      protocol Foo {
        var a:A{get} @a func b(c: C) -> B init!(d: D) subscript(i: Int) -> E {set get} public associatedtype f: F = g
      }
      """,
      """
      protocol Foo {
      var a: A {
      get
      }
      @a func b(c: C) -> B
      init!(d: D)
      subscript(i: Int) -> E {
      get
      set
      }
      public associatedtype f: F = g
      }
      """,
      testClosure: { decl in
      guard let protocolDecl = decl as? ProtocolDeclaration else {
        XCTFail("Failed in getting a protocol declaration.")
        return
      }

      XCTAssertTrue(protocolDecl.attributes.isEmpty)
      XCTAssertNil(protocolDecl.accessLevelModifier)
      XCTAssertEqual(protocolDecl.name.textDescription, "Foo")
      XCTAssertNil(protocolDecl.typeInheritanceClause)
      XCTAssertEqual(protocolDecl.members.count, 5)
      XCTAssertEqual(protocolDecl.members[0].textDescription, "var a: A {\nget\n}")
      XCTAssertEqual(protocolDecl.members[1].textDescription, "@a func b(c: C) -> B")
      XCTAssertEqual(protocolDecl.members[2].textDescription, "init!(d: D)")
      XCTAssertEqual(protocolDecl.members[3].textDescription, "subscript(i: Int) -> E {\nget\nset\n}")
      XCTAssertEqual(protocolDecl.members[4].textDescription, "public associatedtype f: F = g")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      """
      protocol Foo {
        var a:A{get} @a func b(c: C) -> B init!(d: D) subscript(i: Int) -> E {set get} public associatedtype f: F = g
      }
      """,
      """
      protocol Foo {
      var a: A {
      get
      }
      @a func b(c: C) -> B
      init!(d: D)
      subscript(i: Int) -> E {
      get
      set
      }
      public associatedtype f: F = g
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 3, 2))
      }
    )
    parseDeclarationAndTest(
      "@a public protocol Foo {}",
      "@a public protocol Foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 26))
      }
    )
  }

  static var allTests = [
    ("testName", testName),
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributesAndModifier", testAttributesAndModifier),
    ("testTypeInheritance", testTypeInheritance),
    // property member
    ("testPropertyMember", testPropertyMember),
    ("testPropertyMemberWithAttributes", testPropertyMemberWithAttributes),
    ("testPropertyMemberWithModifier", testPropertyMemberWithModifier),
    ("testPropertyMemberWithAttributesAndModifier", testPropertyMemberWithAttributesAndModifier),
    // method member
    ("testMethodMember", testMethodMember),
    // initializer member
    ("testInitializerMember", testInitializerMember),
    // subscript member
    ("testSubscriptMember", testSubscriptMember),
    // associated-type member
    ("testAssociatedTypeMember", testAssociatedTypeMember),
    // compiler-control member
    ("testCompilerControlMember", testCompilerControlMember),
    // combinations
    ("testMembers", testMembers),
    // context
    ("testSourceRange", testSourceRange),
  ]
}
