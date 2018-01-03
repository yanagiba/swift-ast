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

class ParserVariableDeclarationTests: XCTestCase {
  func testVariableName() {
    parseDeclarationAndTest("var foo", "var foo", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(initializerList[0].initializerExpression)
    })
  }

  func testTypeAnnotation() {
    parseDeclarationAndTest("var foo: Foo", "var foo: Foo", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo: Foo")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(initializerList[0].initializerExpression)
    })
  }

  func testSingleInitializer() {
    parseDeclarationAndTest("var foo: Foo = bar", "var foo: Foo = bar", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo: Foo = bar")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNotNil(initializerList[0].initializerExpression)
    })
  }

  func testMultipleInitializers() {
    parseDeclarationAndTest(
      "var foo = bar, a, x = y",
      "var foo = bar, a, x = y",
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 3)
      XCTAssertEqual(initializerList[0].textDescription, "foo = bar")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNotNil(initializerList[0].initializerExpression)
      XCTAssertEqual(initializerList[1].textDescription, "a")
      XCTAssertTrue(initializerList[1].pattern is IdentifierPattern)
      XCTAssertNil(initializerList[1].initializerExpression)
      XCTAssertEqual(initializerList[2].textDescription, "x = y")
      XCTAssertTrue(initializerList[2].pattern is IdentifierPattern)
      XCTAssertNotNil(initializerList[2].initializerExpression)
    })
  }

  func testEmptyCodeBlock() {
    parseDeclarationAndTest("var foo: Foo {}", "var foo: Foo {}", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .codeBlock(varName, typeAnnotation, codeBlock) = varDecl.body else {
        XCTFail("Failed in getting a code block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testCodeBlock() {
    parseDeclarationAndTest("var foo: Foo { return _foo }", "var foo: Foo {\nreturn _foo\n}", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .codeBlock(varName, typeAnnotation, codeBlock) = varDecl.body else {
        XCTFail("Failed in getting a code block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")
      XCTAssertEqual(codeBlock.statements.count, 1)
      XCTAssertTrue(codeBlock.statements[0] is ReturnStatement)
      XCTAssertEqual(codeBlock.statements[0].textDescription, "return _foo")
    })
  }

  func testGetter() {
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertTrue(getterSetterBlock.getter.attributes.isEmpty)
      XCTAssertNil(getterSetterBlock.getter.mutationModifier)
      XCTAssertEqual(getterSetterBlock.getter.codeBlock.statements.count, 1)
      XCTAssertTrue(getterSetterBlock.getter.codeBlock.statements[0] is ReturnStatement)
      XCTAssertEqual(getterSetterBlock.getter.codeBlock.statements[0].textDescription, "return _foo")

      XCTAssertNil(getterSetterBlock.setter)
    })
  }

  func testGetterWithAttributes() {
    parseDeclarationAndTest(
      "var foo: Foo { @a @b @c get { return _foo } }",
      """
      var foo: Foo {
      @a @b @c get {
      return _foo
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.attributes.count, 3)
      XCTAssertEqual(getterSetterBlock.getter.attributes.textDescription, "@a @b @c")
      XCTAssertNil(getterSetterBlock.getter.mutationModifier)
      XCTAssertEqual(getterSetterBlock.getter.codeBlock.textDescription, "{\nreturn _foo\n}")

      XCTAssertNil(getterSetterBlock.setter)
    })
  }

  func testGetterWithModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { nonmutating get { return _foo } }",
      """
      var foo: Foo {
      nonmutating get {
      return _foo
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertTrue(getterSetterBlock.getter.attributes.isEmpty)
      XCTAssertEqual(getterSetterBlock.getter.mutationModifier, .nonmutating)
      XCTAssertEqual(getterSetterBlock.getter.codeBlock.textDescription, "{\nreturn _foo\n}")

      XCTAssertNil(getterSetterBlock.setter)
    })
  }

  func testGetterWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { @a @b @c mutating get { return _foo } }",
      """
      var foo: Foo {
      @a @b @c mutating get {
      return _foo
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.attributes.count, 3)
      XCTAssertEqual(getterSetterBlock.getter.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(getterSetterBlock.getter.mutationModifier, .mutating)
      XCTAssertEqual(getterSetterBlock.getter.codeBlock.textDescription, "{\nreturn _foo\n}")

      XCTAssertNil(getterSetterBlock.setter)
    })
    parseDeclarationAndTest(
      "var foo: Foo { @a @b @c nonmutating get { return _foo } }",
      """
      var foo: Foo {
      @a @b @c nonmutating get {
      return _foo
      }
      }
      """)
  }

  func testGetterThenSetter() {
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } set { _foo = newValue } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      set {
      _foo = newValue
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.textDescription, "get {\nreturn _foo\n}")

      guard let setter = getterSetterBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertTrue(setter.attributes.isEmpty)
      XCTAssertNil(setter.mutationModifier)
      XCTAssertNil(setter.name)
      XCTAssertEqual(setter.codeBlock.textDescription, "{\n_foo = newValue\n}")
    })
  }

  func testGetterThenSetterWithAttributes() {
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } @a @b @c set { _foo = newValue } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      @a @b @c set {
      _foo = newValue
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.textDescription, "get {\nreturn _foo\n}")

      guard let setter = getterSetterBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertEqual(setter.attributes.count, 3)
      XCTAssertEqual(setter.attributes.textDescription, "@a @b @c")
      XCTAssertNil(setter.mutationModifier)
      XCTAssertNil(setter.name)
      XCTAssertEqual(setter.codeBlock.textDescription, "{\n_foo = newValue\n}")
    })
  }

  func testGetterThenSetterWithModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } nonmutating set { _foo = newValue } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      nonmutating set {
      _foo = newValue
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.textDescription, "get {\nreturn _foo\n}")

      guard let setter = getterSetterBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertTrue(setter.attributes.isEmpty)
      XCTAssertEqual(setter.mutationModifier, .nonmutating)
      XCTAssertNil(setter.name)
      XCTAssertEqual(setter.codeBlock.textDescription, "{\n_foo = newValue\n}")
    })
  }

  func testGetterThenSetterWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } @a @b @c mutating set { _foo = newValue } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      @a @b @c mutating set {
      _foo = newValue
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.textDescription, "get {\nreturn _foo\n}")

      guard let setter = getterSetterBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertEqual(setter.attributes.count, 3)
      XCTAssertEqual(setter.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(setter.mutationModifier, .mutating)
      XCTAssertNil(setter.name)
      XCTAssertEqual(setter.codeBlock.textDescription, "{\n_foo = newValue\n}")
    })
  }

  func testGetterWithAttributesThenSetterWithAttributes() {
    parseDeclarationAndTest(
      "var foo: Foo { @x @y @z get { return _foo } @a @b @c set { _foo = newValue } }",
      """
      var foo: Foo {
      @x @y @z get {
      return _foo
      }
      @a @b @c set {
      _foo = newValue
      }
      }
      """)
  }

  func testGetterWithModifierThenSetterWithModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { mutating get { return _foo } nonmutating set { _foo = newValue } }",
      """
      var foo: Foo {
      mutating get {
      return _foo
      }
      nonmutating set {
      _foo = newValue
      }
      }
      """)
  }

  func testGetterWithAttributesAndModifierThenSetterWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { @x @y @z mutating get { return _foo } @a @b @c nonmutating set { _foo = newValue } }",
      """
      var foo: Foo {
      @x @y @z mutating get {
      return _foo
      }
      @a @b @c nonmutating set {
      _foo = newValue
      }
      }
      """)
  }

  func testGetterThenSetterWithName() {
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } set(aValue) { _foo = aValue } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      set(aValue) {
      _foo = aValue
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterBlock(varName, typeAnnotation, getterSetterBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterBlock.getter.textDescription, "get {\nreturn _foo\n}")

      guard let setter = getterSetterBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertTrue(setter.attributes.isEmpty)
      XCTAssertNil(setter.mutationModifier)
      XCTAssertEqual(setter.name?.textDescription, "aValue")
      XCTAssertEqual(setter.codeBlock.textDescription, "{\n_foo = aValue\n}")
    })
  }

  func testSetterThenGetter() {
    parseDeclarationAndTest(
      "var foo: Foo { set { _foo = newValue } get { return _foo } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      set {
      _foo = newValue
      }
      }
      """)
  }

  func testSetterWithAttributesModifierAndNameThenGetterWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { @a mutating set(newValue) { _foo = newValue } @x nonmutating get { return _foo } }",
      """
      var foo: Foo {
      @x nonmutating get {
      return _foo
      }
      @a mutating set(newValue) {
      _foo = newValue
      }
      }
      """)
  }

  func testGetterKeyword() {
    parseDeclarationAndTest("var foo: Foo { get }", "var foo: Foo {\nget\n}")
  }

  func testGetterKeywordWithAttributes() {
    parseDeclarationAndTest("var foo: Foo { @a @b @c get }", "var foo: Foo {\n@a @b @c get\n}")
  }

  func testGetterKeywordWithModifier() {
    parseDeclarationAndTest("var foo: Foo { mutating get }", "var foo: Foo {\nmutating get\n}")
  }

  func testGetterKeywordWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { @a @b @c mutating get }",
      "var foo: Foo {\n@a @b @c mutating get\n}",
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterKeywordBlock(varName, typeAnnotation, getterSetterKeywordBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter-keyword block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterKeywordBlock.getter.attributes.count, 3)
      XCTAssertEqual(getterSetterKeywordBlock.getter.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(getterSetterKeywordBlock.getter.mutationModifier, .mutating)

      XCTAssertNil(getterSetterKeywordBlock.setter)
    })
  }

  func testGetterKeywordThenSetterKeyword() {
    parseDeclarationAndTest("var foo: Foo { get set }", "var foo: Foo {\nget\nset\n}")
  }

  func testGetterKeywordThenSetterKeywordWithAttributes() {
    parseDeclarationAndTest("var foo: Foo { get @x @y @z set }", "var foo: Foo {\nget\n@x @y @z set\n}")
  }

  func testGetterKeywordThenSetterKeywordWithModifier() {
    parseDeclarationAndTest("var foo: Foo { get nonmutating set }", "var foo: Foo {\nget\nnonmutating set\n}")
  }

  func testGetterKeywordThenSetterKeywordWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { get @x @y @z nonmutating set }",
      "var foo: Foo {\nget\n@x @y @z nonmutating set\n}")
  }

  func testGetterKeywordWithAttributesThenSetterKeywordWithAttributes() {
    parseDeclarationAndTest(
      "var foo: Foo { @a @b @c get @x @y @z set }",
      "var foo: Foo {\n@a @b @c get\n@x @y @z set\n}")
  }

  func testGetterKeywordWithModifierThenSetterKeywordWithModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { mutating get nonmutating set }",
      "var foo: Foo {\nmutating get\nnonmutating set\n}")
  }

  func testGetterKeywordWithAttributesAndModifierThenSetterKeywordWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { @a @b @c mutating get @x @y @z nonmutating set }",
      "var foo: Foo {\n@a @b @c mutating get\n@x @y @z nonmutating set\n}",
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterKeywordBlock(varName, typeAnnotation, getterSetterKeywordBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter-keyword block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterKeywordBlock.getter.attributes.count, 3)
      XCTAssertEqual(getterSetterKeywordBlock.getter.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(getterSetterKeywordBlock.getter.mutationModifier, .mutating)

      guard let setter = getterSetterKeywordBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertEqual(setter.attributes.count, 3)
      XCTAssertEqual(setter.attributes.textDescription, "@x @y @z")
      XCTAssertEqual(setter.mutationModifier, .nonmutating)
    })
  }

  func testSetterKeywordThenGetterKeyword() {
    parseDeclarationAndTest("var foo: Foo { set get }", "var foo: Foo {\nget\nset\n}")
  }

  func testSetterKeywordWithAttributesAndModifierThenGetterKeywordWithAttributesAndModifier() {
    parseDeclarationAndTest(
      "var foo: Foo { @x @y @z nonmutating set @a @b @c mutating get }",
      "var foo: Foo {\n@a @b @c mutating get\n@x @y @z nonmutating set\n}",
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .getterSetterKeywordBlock(varName, typeAnnotation, getterSetterKeywordBlock) = varDecl.body else {
        XCTFail("Failed in getting a getter-setter-keyword block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation.textDescription, ": Foo")

      XCTAssertEqual(getterSetterKeywordBlock.getter.attributes.count, 3)
      XCTAssertEqual(getterSetterKeywordBlock.getter.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(getterSetterKeywordBlock.getter.mutationModifier, .mutating)

      guard let setter = getterSetterKeywordBlock.setter else {
        XCTFail("Failed in getting a setter.")
        return
      }

      XCTAssertEqual(setter.attributes.count, 3)
      XCTAssertEqual(setter.attributes.textDescription, "@x @y @z")
      XCTAssertEqual(setter.mutationModifier, .nonmutating)
    })
  }

  func testWillSet() {
    parseDeclarationAndTest(
      "var foo = _foo { willSet { print(newValue) } }",
      """
      var foo = _foo {
      willSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause else {
        XCTFail("Failed in getting a will-set clause.")
        return
      }

      XCTAssertTrue(willSetClause.attributes.isEmpty)
      XCTAssertNil(willSetClause.name)
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertNil(willSetDidSetBlock.didSetClause)
    })
  }

  func testWillSetWithAttributes() {
    parseDeclarationAndTest(
      "var foo = _foo { @a @b @c willSet { print(newValue) } }",
      """
      var foo = _foo {
      @a @b @c willSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause else {
        XCTFail("Failed in getting a will-set clause.")
        return
      }

      XCTAssertEqual(willSetClause.attributes.count, 3)
      XCTAssertEqual(willSetClause.attributes.textDescription, "@a @b @c")
      XCTAssertNil(willSetClause.name)
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertNil(willSetDidSetBlock.didSetClause)
    })
  }

  func testWillSetWithName() {
    parseDeclarationAndTest(
      "var foo = _foo { willSet(newValue) { print(newValue) } }",
      """
      var foo = _foo {
      willSet(newValue) {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause else {
        XCTFail("Failed in getting a will-set clause.")
        return
      }

      XCTAssertTrue(willSetClause.attributes.isEmpty)
      XCTAssertEqual(willSetClause.name?.textDescription, "newValue")
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertNil(willSetDidSetBlock.didSetClause)
    })
  }

  func testWillSetWithAttributesAndName() {
    parseDeclarationAndTest(
      "var foo = _foo { @a @b @c willSet(newValue) { print(newValue) } }",
      """
      var foo = _foo {
      @a @b @c willSet(newValue) {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause else {
        XCTFail("Failed in getting a will-set clause.")
        return
      }

      XCTAssertEqual(willSetClause.attributes.count, 3)
      XCTAssertEqual(willSetClause.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(willSetClause.name?.textDescription, "newValue")
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertNil(willSetDidSetBlock.didSetClause)
    })
  }

  func testDidSet() {
    parseDeclarationAndTest(
      "var foo = _foo { didSet { print(newValue) } }",
      """
      var foo = _foo {
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      XCTAssertNil(willSetDidSetBlock.willSetClause)

      guard let didSetClause = willSetDidSetBlock.didSetClause else {
        XCTFail("Failed in getting a did-set clause.")
        return
      }

      XCTAssertTrue(didSetClause.attributes.isEmpty)
      XCTAssertNil(didSetClause.name)
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testDidSetWithAttributes() {
    parseDeclarationAndTest(
      "var foo = _foo { @x @y @z didSet { print(newValue) } }",
      """
      var foo = _foo {
      @x @y @z didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      XCTAssertNil(willSetDidSetBlock.willSetClause)

      guard let didSetClause = willSetDidSetBlock.didSetClause else {
        XCTFail("Failed in getting a did-set clause.")
        return
      }

      XCTAssertEqual(didSetClause.attributes.count, 3)
      XCTAssertEqual(didSetClause.attributes.textDescription, "@x @y @z")
      XCTAssertNil(didSetClause.name)
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testDidSetWithName() {
    parseDeclarationAndTest(
      "var foo = _foo { didSet(newValue) { print(newValue) } }",
      """
      var foo = _foo {
      didSet(newValue) {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      XCTAssertNil(willSetDidSetBlock.willSetClause)

      guard let didSetClause = willSetDidSetBlock.didSetClause else {
        XCTFail("Failed in getting a did-set clause.")
        return
      }

      XCTAssertTrue(didSetClause.attributes.isEmpty)
      XCTAssertEqual(didSetClause.name?.textDescription, "newValue")
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testDidSetWithAttributesAndName() {
    parseDeclarationAndTest(
      "var foo = _foo { @x @y @z didSet(newValue) { print(newValue) } }",
      """
      var foo = _foo {
      @x @y @z didSet(newValue) {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      XCTAssertNil(willSetDidSetBlock.willSetClause)

      guard let didSetClause = willSetDidSetBlock.didSetClause else {
        XCTFail("Failed in getting a did-set clause.")
        return
      }

      XCTAssertEqual(didSetClause.attributes.count, 3)
      XCTAssertEqual(didSetClause.attributes.textDescription, "@x @y @z")
      XCTAssertEqual(didSetClause.name?.textDescription, "newValue")
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testWillSetThenDidSet() {
    parseDeclarationAndTest(
      "var foo = _foo { willSet { print(newValue) } didSet { print(newValue) } }",
      """
      var foo = _foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause,
        let didSetClause = willSetDidSetBlock.didSetClause
      else {
        XCTFail("Failed in getting will-set & did-set clauses.")
        return
      }

      XCTAssertTrue(willSetClause.attributes.isEmpty)
      XCTAssertNil(willSetClause.name)
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertTrue(didSetClause.attributes.isEmpty)
      XCTAssertNil(didSetClause.name)
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testWillSetWithAttributesAndNameThenDidSetWithAttributesAndName() {
    parseDeclarationAndTest(
      "var foo = _foo { @a willSet(newValue) { print(newValue) } @x didSet(aValue) { print(aValue) } }",
      """
      var foo = _foo {
      @a willSet(newValue) {
      print(newValue)
      }
      @x didSet(aValue) {
      print(aValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause,
        let didSetClause = willSetDidSetBlock.didSetClause
      else {
        XCTFail("Failed in getting will-set & did-set clauses.")
        return
      }

      XCTAssertEqual(willSetClause.attributes.count, 1)
      XCTAssertEqual(willSetClause.attributes.textDescription, "@a")
      XCTAssertEqual(willSetClause.name?.textDescription, "newValue")
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertEqual(didSetClause.attributes.count, 1)
      XCTAssertEqual(didSetClause.attributes.textDescription, "@x")
      XCTAssertEqual(didSetClause.name?.textDescription, "aValue")
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(aValue)")
    })
  }

  func testDidSetThenWillSet() {
    parseDeclarationAndTest(
      "var foo = _foo { didSet { print(newValue) } willSet { print(newValue) } }",
      """
      var foo = _foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause,
        let didSetClause = willSetDidSetBlock.didSetClause
      else {
        XCTFail("Failed in getting will-set & did-set clauses.")
        return
      }

      XCTAssertTrue(willSetClause.attributes.isEmpty)
      XCTAssertNil(willSetClause.name)
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertTrue(didSetClause.attributes.isEmpty)
      XCTAssertNil(didSetClause.name)
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testDidSetWithAttributesAndNameThenWillSetWithAttributesAndName() {
    parseDeclarationAndTest(
      "var foo = _foo { @x didSet(aValue) { print(aValue) } @a willSet(newValue) { print(newValue) } }",
      """
      var foo = _foo {
      @a willSet(newValue) {
      print(newValue)
      }
      @x didSet(aValue) {
      print(aValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertNil(typeAnnotation)
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause,
        let didSetClause = willSetDidSetBlock.didSetClause
      else {
        XCTFail("Failed in getting will-set & did-set clauses.")
        return
      }

      XCTAssertEqual(willSetClause.attributes.count, 1)
      XCTAssertEqual(willSetClause.attributes.textDescription, "@a")
      XCTAssertEqual(willSetClause.name?.textDescription, "newValue")
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertEqual(didSetClause.attributes.count, 1)
      XCTAssertEqual(didSetClause.attributes.textDescription, "@x")
      XCTAssertEqual(didSetClause.name?.textDescription, "aValue")
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(aValue)")
    })
  }

  func testTypeAnnotationWillSetDidSet() {
    parseDeclarationAndTest(
      "var foo: Foo { didSet { print(newValue) } willSet { print(newValue) } }",
      """
      var foo: Foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation?.textDescription, ": Foo")
      XCTAssertNil(initExpr)

      guard let willSetClause = willSetDidSetBlock.willSetClause,
        let didSetClause = willSetDidSetBlock.didSetClause
      else {
        XCTFail("Failed in getting will-set & did-set clauses.")
        return
      }

      XCTAssertTrue(willSetClause.attributes.isEmpty)
      XCTAssertNil(willSetClause.name)
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertTrue(didSetClause.attributes.isEmpty)
      XCTAssertNil(didSetClause.name)
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testTypeAnnotationInitializerWillSetDidSet() {
    parseDeclarationAndTest(
      "var foo: Foo = _foo { didSet { print(newValue) } willSet { print(newValue) } }",
      """
      var foo: Foo = _foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case let .willSetDidSetBlock(varName, typeAnnotation, initExpr, willSetDidSetBlock) = varDecl.body else {
        XCTFail("Failed in getting a will-set-did-set block for variable declaration.")
        return
      }
      XCTAssertEqual(varName.textDescription, "foo")
      XCTAssertEqual(typeAnnotation?.textDescription, ": Foo")
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr?.textDescription, "_foo")

      guard let willSetClause = willSetDidSetBlock.willSetClause,
        let didSetClause = willSetDidSetBlock.didSetClause
      else {
        XCTFail("Failed in getting will-set & did-set clauses.")
        return
      }

      XCTAssertTrue(willSetClause.attributes.isEmpty)
      XCTAssertNil(willSetClause.name)
      XCTAssertEqual(willSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(willSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(willSetClause.codeBlock.statements[0].textDescription, "print(newValue)")

      XCTAssertTrue(didSetClause.attributes.isEmpty)
      XCTAssertNil(didSetClause.name)
      XCTAssertEqual(didSetClause.codeBlock.statements.count, 1)
      XCTAssertTrue(didSetClause.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(didSetClause.codeBlock.statements[0].textDescription, "print(newValue)")
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a var foo", "@a var foo", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertEqual(varDecl.attributes.count, 1)
      XCTAssertEqual(varDecl.attributes[0].name.textDescription, "a")
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(initializerList[0].initializerExpression)
    })
  }

  func testModifiers() {
    parseDeclarationAndTest(
      "private nonmutating static final var foo = bar",
      "private nonmutating static final var foo = bar",
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertEqual(varDecl.modifiers.count, 4)
      XCTAssertEqual(varDecl.modifiers[0], .accessLevel(.private))
      XCTAssertEqual(varDecl.modifiers[1], .mutation(.nonmutating))
      XCTAssertEqual(varDecl.modifiers[2], .static)
      XCTAssertEqual(varDecl.modifiers[3], .final)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo = bar")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNotNil(initializerList[0].initializerExpression)
    })
  }

  func testAttributeAndModifiers() {
    parseDeclarationAndTest("@a fileprivate var foo", "@a fileprivate var foo", testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertEqual(varDecl.attributes.count, 1)
      XCTAssertEqual(varDecl.attributes[0].name.textDescription, "a")
      XCTAssertEqual(varDecl.modifiers.count, 1)
      XCTAssertEqual(varDecl.modifiers[0], .accessLevel(.fileprivate))
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(initializerList[0].initializerExpression)
    })
  }

  func testFollowedByTrailingClosure() {
    parseDeclarationAndTest(
      "var foo = bar { $0 == 0 }",
      "var foo = bar { $0 == 0 }",
      testClosure: { decl in
      guard let varDecl = decl as? VariableDeclaration else {
        XCTFail("Failed in getting a variable declaration.")
        return
      }

      XCTAssertTrue(varDecl.attributes.isEmpty)
      XCTAssertTrue(varDecl.modifiers.isEmpty)
      guard case .initializerList(let initializerList) = varDecl.body else {
        XCTFail("Failed in getting an initializer list for variable declaration.")
        return
      }
      XCTAssertEqual(initializerList.count, 1)
      XCTAssertEqual(initializerList[0].textDescription, "foo = bar { $0 == 0 }")
      XCTAssertTrue(initializerList[0].pattern is IdentifierPattern)
      XCTAssertTrue(initializerList[0].initializerExpression is FunctionCallExpression)
    })
    parseDeclarationAndTest(
      "var foo = bar { $0 = 0 }, a = b { _ in true }, x = y { t -> Int in t^2 }",
      """
      var foo = bar { $0 = 0 }, a = b { _ in
      true
      }, x = y { t -> Int in
      t ^ 2
      }
      """)
    parseDeclarationAndTest(
      "var foo = _foo { $0 = 0 } { willSet(newValue) { print(newValue) } }",
      """
      var foo = _foo { $0 = 0 } {
      willSet(newValue) {
      print(newValue)
      }
      }
      """)
    parseDeclarationAndTest(
      "var foo = bar { $0 == 0 }.joined()",
      "var foo = bar { $0 == 0 }.joined()")
  }

  func testSourceRange() {
    parseDeclarationAndTest("var foo", "var foo", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 8))
    })
    parseDeclarationAndTest("@a var foo = bar, a, x = y", "@a var foo = bar, a, x = y", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 27))
    })
    parseDeclarationAndTest("private var foo, bar", "private var foo, bar", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 21))
    })
    parseDeclarationAndTest("var foo = bar { $0 == 0 }", "var foo = bar { $0 == 0 }", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 26))
    })
    parseDeclarationAndTest("var foo: Foo { return _foo }", "var foo: Foo {\nreturn _foo\n}", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 29))
    })
    parseDeclarationAndTest("var foo: Foo { get set }", "var foo: Foo {\nget\nset\n}", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 25))
    })
    parseDeclarationAndTest(
      "var foo: Foo { get { return _foo } }",
      """
      var foo: Foo {
      get {
      return _foo
      }
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 37))
      }
    )
    parseDeclarationAndTest(
      "var foo: Foo { didSet { print(newValue) } willSet { print(newValue) } }",
      """
      var foo: Foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 72))
      }
    )
    parseDeclarationAndTest(
      "var foo = _foo { didSet { print(newValue) } willSet { print(newValue) } }",
      """
      var foo = _foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 74))
      }
    )
    parseDeclarationAndTest(
      "var foo: Foo = _foo { didSet { print(newValue) } willSet { print(newValue) } }",
      """
      var foo: Foo = _foo {
      willSet {
      print(newValue)
      }
      didSet {
      print(newValue)
      }
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 79))
      }
    )
  }

  static var allTests = [
    ("testVariableName", testVariableName),
    ("testTypeAnnotation", testTypeAnnotation),
    ("testSingleInitializer", testSingleInitializer),
    ("testMultipleInitializers", testMultipleInitializers),
    // code block
    ("testEmptyCodeBlock", testEmptyCodeBlock),
    ("testCodeBlock", testCodeBlock),
    // getter-setter block
    ("testGetter", testGetter),
    ("testGetterWithAttributes", testGetterWithAttributes),
    ("testGetterWithModifier", testGetterWithModifier),
    ("testGetterWithAttributesAndModifier", testGetterWithAttributesAndModifier),
    ("testGetterThenSetter", testGetterThenSetter),
    ("testGetterThenSetterWithAttributes", testGetterThenSetterWithAttributes),
    ("testGetterThenSetterWithModifier", testGetterThenSetterWithModifier),
    ("testGetterThenSetterWithAttributesAndModifier", testGetterThenSetterWithAttributesAndModifier),
    ("testGetterWithAttributesThenSetterWithAttributes", testGetterWithAttributesThenSetterWithAttributes),
    ("testGetterWithModifierThenSetterWithModifier", testGetterWithModifierThenSetterWithModifier),
    ("testGetterWithAttributesAndModifierThenSetterWithAttributesAndModifier",
      testGetterWithAttributesAndModifierThenSetterWithAttributesAndModifier),
    ("testGetterThenSetterWithName", testGetterThenSetterWithName),
    ("testSetterThenGetter", testSetterThenGetter),
    ("testSetterWithAttributesModifierAndNameThenGetterWithAttributesAndModifier",
      testSetterWithAttributesModifierAndNameThenGetterWithAttributesAndModifier),
    // getter-setter-keyword block
    ("testGetterKeyword", testGetterKeyword),
    ("testGetterKeywordWithAttributes", testGetterKeywordWithAttributes),
    ("testGetterKeywordWithModifier", testGetterKeywordWithModifier),
    ("testGetterKeywordWithAttributesAndModifier", testGetterKeywordWithAttributesAndModifier),
    ("testGetterKeywordThenSetterKeyword", testGetterKeywordThenSetterKeyword),
    ("testGetterKeywordThenSetterKeywordWithAttributes", testGetterKeywordThenSetterKeywordWithAttributes),
    ("testGetterKeywordThenSetterKeywordWithModifier", testGetterKeywordThenSetterKeywordWithModifier),
    ("testGetterKeywordThenSetterKeywordWithAttributesAndModifier",
      testGetterKeywordThenSetterKeywordWithAttributesAndModifier),
    ("testGetterKeywordWithAttributesThenSetterKeywordWithAttributes",
      testGetterKeywordWithAttributesThenSetterKeywordWithAttributes),
    ("testGetterKeywordWithModifierThenSetterKeywordWithModifier",
      testGetterKeywordWithModifierThenSetterKeywordWithModifier),
    ("testGetterKeywordWithAttributesAndModifierThenSetterKeywordWithAttributesAndModifier",
      testGetterKeywordWithAttributesAndModifierThenSetterKeywordWithAttributesAndModifier),
    ("testSetterKeywordThenGetterKeyword", testSetterKeywordThenGetterKeyword),
    ("testSetterKeywordWithAttributesAndModifierThenGetterKeywordWithAttributesAndModifier",
      testSetterKeywordWithAttributesAndModifierThenGetterKeywordWithAttributesAndModifier),
    // will-set-did-set block
    ("testWillSet", testWillSet),
    ("testWillSetWithAttributes", testWillSetWithAttributes),
    ("testWillSetWithName", testWillSetWithName),
    ("testWillSetWithAttributesAndName", testWillSetWithAttributesAndName),
    ("testDidSet", testDidSet),
    ("testDidSetWithAttributes", testDidSetWithAttributes),
    ("testDidSetWithName", testDidSetWithName),
    ("testDidSetWithAttributesAndName", testDidSetWithAttributesAndName),
    ("testWillSetThenDidSet", testWillSetThenDidSet),
    ("testWillSetWithAttributesAndNameThenDidSetWithAttributesAndName",
      testWillSetWithAttributesAndNameThenDidSetWithAttributesAndName),
    ("testDidSetThenWillSet", testDidSetThenWillSet),
    ("testDidSetWithAttributesAndNameThenWillSetWithAttributesAndName",
      testDidSetWithAttributesAndNameThenWillSetWithAttributesAndName),
    ("testTypeAnnotationWillSetDidSet", testTypeAnnotationWillSetDidSet),
    ("testTypeAnnotationInitializerWillSetDidSet", testTypeAnnotationInitializerWillSetDidSet),
    // trailing closure
    ("testFollowedByTrailingClosure", testFollowedByTrailingClosure),
    // attributes/modifiers
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributeAndModifiers", testAttributeAndModifiers),
    // context
    ("testSourceRange", testSourceRange),
  ]
}
