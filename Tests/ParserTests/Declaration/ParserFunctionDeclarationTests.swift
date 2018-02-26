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

class ParserFunctionDeclarationTests: XCTestCase {
  func testNameIdentifier() {
    parseDeclarationAndTest("func foo()", "func foo()", testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testNameOperator() {
    parseDeclarationAndTest("func <!>()", "func <!>()", testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "<!>")
      XCTAssertNil(funcDecl.genericParameterClause)
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testReservedOperators() {
    parseDeclarationAndTest("prefix func <()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("infix func <()", "infix func <()")
    parseDeclarationAndTest("postfix func <()", "postfix func <()")
    parseDeclarationAndTest("prefix func >()", "prefix func >()")
    parseDeclarationAndTest("infix func >()", "infix func >()")
    parseDeclarationAndTest("postfix func >()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("prefix func &()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("infix func &()", "infix func &()")
    parseDeclarationAndTest("postfix func &()", "postfix func &()")
    parseDeclarationAndTest("prefix func ?()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("infix func ?()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("postfix func ?()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("func ?()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("prefix func !()", "prefix func !()")
    parseDeclarationAndTest("infix func !()", "infix func !()")
    parseDeclarationAndTest("postfix func !()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("func =()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("func @()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("func #()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("func ->()", "", errorClosure: { error in
      // :)
    })
    parseDeclarationAndTest("func `()", "", errorClosure: { error in
      // :)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest(
      "@a @b @c func foo()",
      "@a @b @c func foo()",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertEqual(funcDecl.attributes.count, 3)
      XCTAssertEqual(funcDecl.attributes.textDescription, "@a @b @c")
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testModifiers() {
    parseDeclarationAndTest(
      "fileprivate static final override func foo()",
      "fileprivate static final override func foo()",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertEqual(funcDecl.modifiers.count, 4)
      XCTAssertEqual(funcDecl.modifiers.textDescription, "fileprivate static final override")
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testAttributesAndModifiers() {
    parseDeclarationAndTest(
      "@a @b @c private prefix func √()",
      "@a @b @c private prefix func √()",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertEqual(funcDecl.attributes.count, 3)
      XCTAssertEqual(funcDecl.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(funcDecl.modifiers.count, 2)
      XCTAssertEqual(funcDecl.modifiers.textDescription, "private prefix")
      XCTAssertEqual(funcDecl.name.textDescription, "√")
      XCTAssertNil(funcDecl.genericParameterClause)
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testGenericParameterClause() {
    parseDeclarationAndTest(
      "func foo<A, B: C, D: E & F & G>()",
      "func foo<A, B: C, D: protocol<E, F, G>>()",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertEqual(funcDecl.genericParameterClause?.textDescription, "<A, B: C, D: protocol<E, F, G>>")
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testParameter() {
    parseDeclarationAndTest("func foo(bar: Bar)", "func foo(bar: Bar)", testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertNil(param.externalName)
      XCTAssertEqual(param.localName.textDescription, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testInoutParameter() {
    parseDeclarationAndTest(
      "func foo(bar: inout Bar)",
      "func foo(bar: inout Bar)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertNil(param.externalName)
      XCTAssertEqual(param.localName.textDescription, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": inout Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: inout Bar)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testSpecifyingArgumentLabels() {
    parseDeclarationAndTest(
      "func foo(_b bar: Bar)",
      "func foo(_b bar: Bar)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertEqual(param.externalName?.textDescription, "_b")
      XCTAssertEqual(param.localName.textDescription, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(_b bar: Bar)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testOmittingArgumentLabels() {
    parseDeclarationAndTest(
      "func foo(_ bar: Bar)",
      "func foo(_ bar: Bar)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertEqual(param.externalName?.textDescription, "_")
      XCTAssertEqual(param.localName.textDescription, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(_ bar: Bar)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testParameterWithDefaultArgument() {
    parseDeclarationAndTest(
      "func foo(parameterWithDefault: Int = 12)",
      "func foo(parameterWithDefault: Int = 12)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertNil(param.externalName)
      XCTAssertEqual(param.localName.textDescription, "parameterWithDefault")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Int")
      XCTAssertEqual(param.defaultArgumentClause?.textDescription, "12")
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(parameterWithDefault: Int = 12)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testVariadicParameter() {
    parseDeclarationAndTest("func foo(bar: Bar...)", "func foo(bar: Bar...)", testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertNil(param.externalName)
      XCTAssertEqual(param.localName.textDescription, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertTrue(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar...)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testProtocolCompositionParameter() {
    parseDeclarationAndTest("func beginConcert(in loc: Location & Named)",
      "func beginConcert(in loc: protocol<Location, Named>)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "beginConcert")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      let param = funcDecl.signature.parameterList[0]
      XCTAssertEqual(param.externalName?.textDescription, "in")
      XCTAssertEqual(param.localName.textDescription, "loc")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": protocol<Location, Named>")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(in loc: protocol<Location, Named>)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testMultipleParameters() {
    parseDeclarationAndTest(
      "func foo(a: A, _ b: B, c: inout C, d: @a D, e: E...)",
      "func foo(a: A, _ b: B, c: inout C, d: @a D, e: E...)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 5)
      XCTAssertEqual(funcDecl.signature.parameterList[0].textDescription, "a: A")
      XCTAssertEqual(funcDecl.signature.parameterList[1].textDescription, "_ b: B")
      XCTAssertEqual(funcDecl.signature.parameterList[2].textDescription, "c: inout C")
      XCTAssertEqual(funcDecl.signature.parameterList[3].textDescription, "d: @a D")
      XCTAssertEqual(funcDecl.signature.parameterList[4].textDescription, "e: E...")
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(a: A, _ b: B, c: inout C, d: @a D, e: E...)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testFunctionThatThrows() {
    parseDeclarationAndTest(
      "func foo(bar: Bar) throws",
      "func foo(bar: Bar) throws",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      XCTAssertEqual(funcDecl.signature.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(funcDecl.signature.throwsKind, .throwing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar) throws")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testFunctionThatRethrows() {
    parseDeclarationAndTest(
      "func foo(bar: Bar) rethrows",
      "func foo(bar: Bar) rethrows",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      XCTAssertEqual(funcDecl.signature.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(funcDecl.signature.throwsKind, .rethrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar) rethrows")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testFunctionResult() {
    parseDeclarationAndTest(
      "func foo(bar: Bar) -> @a @b @c Foo",
      "func foo(bar: Bar) -> @a @b @c Foo",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      XCTAssertEqual(funcDecl.signature.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertEqual(funcDecl.signature.result?.textDescription, "-> @a @b @c Foo")
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar) -> @a @b @c Foo")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testThrowsWithResult() {
    parseDeclarationAndTest(
      "func foo(bar: Bar) throws -> Foo",
      "func foo(bar: Bar) throws -> Foo",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      XCTAssertEqual(funcDecl.signature.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(funcDecl.signature.throwsKind, .throwing)
      XCTAssertEqual(funcDecl.signature.result?.textDescription, "-> Foo")
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar) throws -> Foo")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testRethrowsWithResult() {
    parseDeclarationAndTest(
      "func foo(bar: Bar) rethrows -> Foo",
      "func foo(bar: Bar) rethrows -> Foo",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 1)
      XCTAssertEqual(funcDecl.signature.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(funcDecl.signature.throwsKind, .rethrowing)
      XCTAssertEqual(funcDecl.signature.result?.textDescription, "-> Foo")
      XCTAssertEqual(funcDecl.signature.textDescription, "(bar: Bar) rethrows -> Foo")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "func foo<A>() where A == Foo",
      "func foo<A>() where A == Foo",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertEqual(funcDecl.genericParameterClause?.textDescription, "<A>")
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertEqual(funcDecl.genericWhereClause?.textDescription, "where A == Foo")
      XCTAssertNil(funcDecl.body)
    })
  }

  func testFunctionBody() {
    parseDeclarationAndTest("func foo() {}", "func foo() {}", testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertEqual(funcDecl.body?.textDescription, "{}")
    })
  }

  func testWhereClauseAndBody() {
    parseDeclarationAndTest(
      "func foo<A>() where A == Foo {}",
      "func foo<A>() where A == Foo {}",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertEqual(funcDecl.genericParameterClause?.textDescription, "<A>")
      XCTAssertEqual(funcDecl.signature.textDescription, "()")
      XCTAssertEqual(funcDecl.genericWhereClause?.textDescription, "where A == Foo")
      XCTAssertEqual(funcDecl.body?.textDescription, "{}")
    })
  }

  func testArgumentCanHaveNoInternalName() {
    parseDeclarationAndTest(
      "func foo(_: Bar, and _: Bar)",
      "func foo(_: Bar, and _: Bar)",
      testClosure: { decl in
      guard let funcDecl = decl as? FunctionDeclaration else {
        XCTFail("Failed in getting a function declaration.")
        return
      }

      XCTAssertTrue(funcDecl.attributes.isEmpty)
      XCTAssertTrue(funcDecl.modifiers.isEmpty)
      XCTAssertEqual(funcDecl.name.textDescription, "foo")
      XCTAssertNil(funcDecl.genericParameterClause)

      XCTAssertEqual(funcDecl.signature.parameterList.count, 2)
      let param1 = funcDecl.signature.parameterList[0]
      XCTAssertEqual(param1.externalName?.textDescription, "_")
      XCTAssertEqual(param1.localName.textDescription, "")
      XCTAssertEqual(param1.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param1.defaultArgumentClause)
      XCTAssertFalse(param1.isVarargs)
      let param2 = funcDecl.signature.parameterList[1]
      XCTAssertEqual(param2.externalName?.textDescription, "and")
      XCTAssertEqual(param2.localName.textDescription, "_")
      XCTAssertEqual(param2.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param2.defaultArgumentClause)
      XCTAssertFalse(param2.isVarargs)
      XCTAssertEqual(funcDecl.signature.throwsKind, .nothrowing)
      XCTAssertNil(funcDecl.signature.result)
      XCTAssertEqual(funcDecl.signature.textDescription, "(_: Bar, and _: Bar)")

      XCTAssertNil(funcDecl.genericWhereClause)
      XCTAssertNil(funcDecl.body)
    })
  }

  func testArgumentAsFunctionType() {
    parseDeclarationAndTest(
      "func foo(b: () -> String)", "func foo(b: () -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure () -> String)",
      "func foo(b: @autoclosure () -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure() -> String)",
      "func foo(b: @autoclosure () -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure(Int) -> String)",
      "func foo(b: @autoclosure (Int) -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure() throws -> String)",
      "func foo(b: @autoclosure () throws -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure(Int) throws -> String)",
      "func foo(b: @autoclosure (Int) throws -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure() rethrows -> String)",
      "func foo(b: @autoclosure () rethrows -> String)")
    parseDeclarationAndTest(
      "func foo(b:@autoclosure(Int) rethrows -> String)",
      "func foo(b: @autoclosure (Int) rethrows -> String)")
  }

  func testOthers() {
    parseDeclarationAndTest(
      "func greet(person: String) -> String { return \"Hello, \" + person + \"!\"}",
      "func greet(person: String) -> String {\nreturn \"Hello, \" + person + \"!\"\n}")
    parseDeclarationAndTest(
      "func printAndCount(string: String) -> Int {print(string)\nreturn string.characters.count\n}",
      "func printAndCount(string: String) -> Int {\nprint(string)\nreturn string.characters.count\n}")
    parseDeclarationAndTest(
      "func minMax(array: [Int]) -> (min: Int, max: Int)",
      "func minMax(array: Array<Int>) -> (min: Int, max: Int)")
    parseDeclarationAndTest(
      "func minMax(array: [Int]) -> (min: Int, max: Int)?",
      "func minMax(array: Array<Int>) -> Optional<(min: Int, max: Int)>")
    parseDeclarationAndTest(
      "func greet(person: String, from hometown: String) -> String",
      "func greet(person: String, from hometown: String) -> String")
    parseDeclarationAndTest(
      "func someFunction(parameterWithoutDefault: Int, parameterWithDefault: Int = 12)",
      "func someFunction(parameterWithoutDefault: Int, parameterWithDefault: Int = 12)")
    parseDeclarationAndTest(
      "func arithmeticMean(_ numbers: Double...) -> Double",
      "func arithmeticMean(_ numbers: Double...) -> Double")
    parseDeclarationAndTest(
      "func swapTwoInts(_ a: inout Int, _ b: inout Int)",
      "func swapTwoInts(_ a: inout Int, _ b: inout Int)")
    parseDeclarationAndTest(
      "func chooseStepFunction(backward: Bool) -> (Int) -> Int {}",
      "func chooseStepFunction(backward: Bool) -> (Int) -> Int {}")
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "func greet(person: String) -> String { return \"Hello, \" + person + \"!\"}",
      "func greet(person: String) -> String {\nreturn \"Hello, \" + person + \"!\"\n}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 72))
      }
    )
    parseDeclarationAndTest(
      "func printAndCount(string: String) -> Int {print(string)\nreturn string.characters.count\n}",
      "func printAndCount(string: String) -> Int {\nprint(string)\nreturn string.characters.count\n}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 3, 2))
      }
    )
    parseDeclarationAndTest(
      "func chooseStepFunction(backward: Bool) -> (Int) -> Int",
      "func chooseStepFunction(backward: Bool) -> (Int) -> Int",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 56))
      }
    )
    parseDeclarationAndTest(
      "func foo<A>() where A == Foo",
      "func foo<A>() where A == Foo",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 29))
      }
    )
    parseDeclarationAndTest(
      "func foo() throws",
      "func foo() throws",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 18))
      }
    )
    parseDeclarationAndTest(
      "func foo()",
      "func foo()",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 11))
      }
    )
    parseDeclarationAndTest(
      "func foo() {}",
      "func foo() {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 14))
      }
    )
    parseDeclarationAndTest(
      "@a @b @c private prefix func √()",
      "@a @b @c private prefix func √()",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 33))
      }
    )
  }

  static var allTests = [
    ("testNameIdentifier", testNameIdentifier),
    ("testNameOperator", testNameOperator),
    ("testReservedOperators", testReservedOperators),
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributesAndModifiers", testAttributesAndModifiers),
    ("testGenericParameterClause", testGenericParameterClause),
    ("testParameter", testParameter),
    ("testInoutParameter", testInoutParameter),
    ("testSpecifyingArgumentLabels", testSpecifyingArgumentLabels),
    ("testOmittingArgumentLabels", testOmittingArgumentLabels),
    ("testParameterWithDefaultArgument", testParameterWithDefaultArgument),
    ("testVariadicParameter", testVariadicParameter),
    ("testProtocolCompositionParameter", testProtocolCompositionParameter),
    ("testMultipleParameters", testMultipleParameters),
    ("testFunctionThatThrows", testFunctionThatThrows),
    ("testFunctionThatRethrows", testFunctionThatRethrows),
    ("testFunctionResult", testFunctionResult),
    ("testThrowsWithResult", testThrowsWithResult),
    ("testRethrowsWithResult", testRethrowsWithResult),
    ("testGenericWhereClause", testGenericWhereClause),
    ("testFunctionBody", testFunctionBody),
    ("testWhereClauseAndBody", testWhereClauseAndBody),
    ("testArgumentCanHaveNoInternalName", testArgumentCanHaveNoInternalName),
    ("testArgumentAsFunctionType", testArgumentAsFunctionType),
    ("testOthers", testOthers),
    ("testSourceRange", testSourceRange),
  ]
}
