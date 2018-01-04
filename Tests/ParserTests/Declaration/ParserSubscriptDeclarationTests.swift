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

class ParserSubscriptDeclarationTests: XCTestCase {
  func testSubscriptDecl() {
    parseDeclarationAndTest("subscript() -> Self {}", "subscript() -> Self {}", testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertNil(subscriptDecl.genericParameterClause)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      XCTAssertNil(subscriptDecl.genericWhereClause)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a subscript() -> Self {}", "@a subscript() -> Self {}", testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertEqual(subscriptDecl.attributes.count, 1)
      XCTAssertEqual(subscriptDecl.attributes[0].name.textDescription, "a")
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testModifiers() {
    parseDeclarationAndTest(
      "private nonmutating static final subscript() -> Self {}",
      "private nonmutating static final subscript() -> Self {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertEqual(subscriptDecl.modifiers.count, 4)
      XCTAssertEqual(subscriptDecl.modifiers[0], .accessLevel(.private))
      XCTAssertEqual(subscriptDecl.modifiers[1], .mutation(.nonmutating))
      XCTAssertEqual(subscriptDecl.modifiers[2], .static)
      XCTAssertEqual(subscriptDecl.modifiers[3], .final)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testAttributeAndModifiers() {
    parseDeclarationAndTest(
      "@a fileprivate subscript() -> Self {}",
      "@a fileprivate subscript() -> Self {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertEqual(subscriptDecl.attributes.count, 1)
      XCTAssertEqual(subscriptDecl.attributes[0].name.textDescription, "a")
      XCTAssertEqual(subscriptDecl.modifiers.count, 1)
      XCTAssertEqual(subscriptDecl.modifiers[0], .accessLevel(.fileprivate))
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testSingleParameter() {
    parseDeclarationAndTest(
      "subscript(i: Int) -> Self {}",
      "subscript(i: Int) -> Self {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertEqual(subscriptDecl.parameterList.count, 1)
      XCTAssertEqual(subscriptDecl.parameterList[0].textDescription, "i: Int")
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testMultipleParameters() {
    parseDeclarationAndTest(
      "subscript(section: Int, row: Int) -> Self {}",
      "subscript(section: Int, row: Int) -> Self {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertEqual(subscriptDecl.parameterList.count, 2)
      XCTAssertEqual(subscriptDecl.parameterList[0].textDescription, "section: Int")
      XCTAssertEqual(subscriptDecl.parameterList[1].textDescription, "row: Int")
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testResultAttributes() {
    parseDeclarationAndTest(
      "subscript() -> @a @b @c Self {}",
      "subscript() -> @a @b @c Self {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertEqual(subscriptDecl.resultAttributes.count, 3)
      XCTAssertEqual(subscriptDecl.resultAttributes.textDescription, "@a @b @c")
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testGenericParameterClause() {
    parseDeclarationAndTest(
      "subscript<A, B, C>() -> Self {}",
      "subscript<A, B, C>() -> Self {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertEqual(subscriptDecl.genericParameterClause?.textDescription, "<A, B, C>")
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      XCTAssertNil(subscriptDecl.genericWhereClause)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "subscript<T, S>() -> Self where T == S {}",
      "subscript<T, S>() -> Self where T == S {}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertEqual(subscriptDecl.genericParameterClause?.textDescription, "<T, S>")
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      XCTAssertEqual(subscriptDecl.genericWhereClause?.textDescription, "where T == S")
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertTrue(codeBlock.statements.isEmpty)
    })
  }

  func testCodeBlock() {
    parseDeclarationAndTest(
      "subscript() -> Self { return _weakSelf }",
      "subscript() -> Self {\nreturn _weakSelf\n}",
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)
      guard case let .codeBlock(codeBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a code block for subscript declaration.")
        return
      }
      XCTAssertEqual(codeBlock.statements.count, 1)
      XCTAssertEqual(codeBlock.statements[0].textDescription, "return _weakSelf")
    })
  }

  func testGetterSetterBlock() {
    parseDeclarationAndTest(
      "subscript() -> Self { get { return _foo } set { _foo = newValue } }",
      """
      subscript() -> Self {
      get {
      return _foo
      }
      set {
      _foo = newValue
      }
      }
      """,
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)

      guard case let .getterSetterBlock(getterSetterBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a getter-setter block for subscript declaration.")
        return
      }

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

  func testGetterSetterKeywordBlock() {
    parseDeclarationAndTest(
      "subscript() -> Self { @a @b @c mutating get @x @y @z nonmutating set }",
      """
      subscript() -> Self {
      @a @b @c mutating get
      @x @y @z nonmutating set
      }
      """,
      testClosure: { decl in
      guard let subscriptDecl = decl as? SubscriptDeclaration else {
        XCTFail("Failed in getting a subscript declaration.")
        return
      }

      XCTAssertTrue(subscriptDecl.attributes.isEmpty)
      XCTAssertTrue(subscriptDecl.modifiers.isEmpty)
      XCTAssertTrue(subscriptDecl.parameterList.isEmpty)
      XCTAssertTrue(subscriptDecl.resultAttributes.isEmpty)
      XCTAssertTrue(subscriptDecl.resultType is SelfType)

      guard case let .getterSetterKeywordBlock(getterSetterKeywordBlock) = subscriptDecl.body else {
        XCTFail("Failed in getting a getter-setter-keyword block for subscript declaration.")
        return
      }

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

  func testSourceRange() {
    parseDeclarationAndTest(
      "subscript() -> Self {}",
      "subscript() -> Self {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 23))
      }
    )
    parseDeclarationAndTest(
      "@x @y @z subscript() -> Self { @a @b @c mutating get @x @y @z nonmutating set }",
      """
      @x @y @z subscript() -> Self {
      @a @b @c mutating get
      @x @y @z nonmutating set
      }
      """,
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 80))
      }
    )
  }

  static var allTests = [
    ("testSubscriptDecl", testSubscriptDecl),
    // attributes/modifiers
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributeAndModifiers", testAttributeAndModifiers),
    // parameter clause and result
    ("testSingleParameter", testSingleParameter),
    ("testMultipleParameters", testMultipleParameters),
    ("testResultAttributes", testResultAttributes),
    // generic parameter and where clauses
    ("testGenericParameterClause", testGenericParameterClause),
    ("testGenericWhereClause", testGenericWhereClause),
    // code block
    ("testCodeBlock", testCodeBlock),
    // getter-setter block
    ("testGetterSetterBlock", testGetterSetterBlock),
    // getter-setter-keyword block
    ("testGetterSetterKeywordBlock", testGetterSetterKeywordBlock),
    // context
    ("testSourceRange", testSourceRange),
  ]
}
