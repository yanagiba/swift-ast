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

class ParserInitializerDeclarationTests: XCTestCase {
  func testNonfailable() {
    parseDeclarationAndTest("init() {}", "init() {}", testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testOptionalFailable() {
    parseDeclarationAndTest(
      "init?() { return nil }",
      "init?() {\nreturn nil\n}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .optionalFailable)
      XCTAssertNil(initDecl.genericParameterClause)
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{\nreturn nil\n}")
    })
  }

  func testImplicitlyUnwrappedFailable() {
    parseDeclarationAndTest(
      "init!() { self.foo = nil }",
      "init!() {\nself.foo = nil\n}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .implicitlyUnwrappedFailable)
      XCTAssertNil(initDecl.genericParameterClause)
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{\nself.foo = nil\n}")
    })
  }

  func testAttributes() {
    parseDeclarationAndTest(
      "@a @b @c init() {}",
      "@a @b @c init() {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertEqual(initDecl.attributes.count, 3)
      XCTAssertEqual(initDecl.attributes.textDescription, "@a @b @c")
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testModifiers() {
    parseDeclarationAndTest(
      "fileprivate convenience required init() {}",
      "fileprivate convenience required init() {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertEqual(initDecl.modifiers.count, 3)
      XCTAssertEqual(initDecl.modifiers.textDescription, "fileprivate convenience required")
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testAttributesAndModifiers() {
    parseDeclarationAndTest(
      "@a @b @c private override init() {}",
      "@a @b @c private override init() {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertEqual(initDecl.attributes.count, 3)
      XCTAssertEqual(initDecl.attributes.textDescription, "@a @b @c")
      XCTAssertEqual(initDecl.modifiers.count, 2)
      XCTAssertEqual(initDecl.modifiers.textDescription, "private override")
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testGenericParameterClause() {
    parseDeclarationAndTest(
      "init<A, B: C, D: E & F & G>() {}",
      "init<A, B: C, D: protocol<E, F, G>>() {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertEqual(initDecl.genericParameterClause?.textDescription, "<A, B: C, D: protocol<E, F, G>>")
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testParameter() {
    parseDeclarationAndTest(
      "init(bar: Bar) {}",
      "init(bar: Bar) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      let param = initDecl.parameterList[0]
      XCTAssertNil(param.externalName)
      ASTTextEqual(param.localName, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testInoutParameter() {
    parseDeclarationAndTest(
      "init(bar: inout Bar) {}",
      "init(bar: inout Bar) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      let param = initDecl.parameterList[0]
      XCTAssertNil(param.externalName)
      ASTTextEqual(param.localName, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": inout Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testSpecifyingArgumentLabels() {
    parseDeclarationAndTest(
      "init(_b bar: Bar) {}",
      "init(_b bar: Bar) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      let param = initDecl.parameterList[0]
      ASTTextEqual(param.externalName, "_b")
      ASTTextEqual(param.localName, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testOmittingArgumentLabels() {
    parseDeclarationAndTest(
      "init(_ bar: Bar) {}",
      "init(_ bar: Bar) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      let param = initDecl.parameterList[0]
      ASTTextEqual(param.externalName, "_")
      ASTTextEqual(param.localName, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testParameterWithDefaultArgument() {
    parseDeclarationAndTest(
      "init(parameterWithDefault: Int = 12) {}",
      "init(parameterWithDefault: Int = 12) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      let param = initDecl.parameterList[0]
      XCTAssertNil(param.externalName)
      ASTTextEqual(param.localName, "parameterWithDefault")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Int")
      XCTAssertEqual(param.defaultArgumentClause?.textDescription, "12")
      XCTAssertFalse(param.isVarargs)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testVariadicParameter() {
    parseDeclarationAndTest(
      "init(bar: Bar...) {}",
      "init(bar: Bar...) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      let param = initDecl.parameterList[0]
      XCTAssertNil(param.externalName)
      ASTTextEqual(param.localName, "bar")
      XCTAssertEqual(param.typeAnnotation.textDescription, ": Bar")
      XCTAssertNil(param.defaultArgumentClause)
      XCTAssertTrue(param.isVarargs)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testMultipleParameters() {
    parseDeclarationAndTest(
      "init(a: A, _ b: B, c: inout C, d: @a D, e: E...) {}",
      "init(a: A, _ b: B, c: inout C, d: @a D, e: E...) {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 5)
      XCTAssertEqual(initDecl.parameterList[0].textDescription, "a: A")
      XCTAssertEqual(initDecl.parameterList[1].textDescription, "_ b: B")
      XCTAssertEqual(initDecl.parameterList[2].textDescription, "c: inout C")
      XCTAssertEqual(initDecl.parameterList[3].textDescription, "d: @a D")
      XCTAssertEqual(initDecl.parameterList[4].textDescription, "e: E...")
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testInitializerThatThrows() {
    parseDeclarationAndTest(
      "init(bar: Bar) throws {}",
      "init(bar: Bar) throws {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      XCTAssertEqual(initDecl.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(initDecl.throwsKind, .throwing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testInitializerThatRethrows() {
    parseDeclarationAndTest(
      "init(bar: Bar) rethrows {}",
      "init(bar: Bar) rethrows {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertNil(initDecl.genericParameterClause)

      XCTAssertEqual(initDecl.parameterList.count, 1)
      XCTAssertEqual(initDecl.parameterList[0].textDescription, "bar: Bar")
      XCTAssertEqual(initDecl.throwsKind, .rethrowing)

      XCTAssertNil(initDecl.genericWhereClause)
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testGenericWhereClause() {
    parseDeclarationAndTest(
      "init<A>() where A == Foo {}",
      "init<A>() where A == Foo {}",
      testClosure: { decl in
      guard let initDecl = decl as? InitializerDeclaration else {
        XCTFail("Failed in getting an initializer declaration.")
        return
      }

      XCTAssertTrue(initDecl.attributes.isEmpty)
      XCTAssertTrue(initDecl.modifiers.isEmpty)
      XCTAssertEqual(initDecl.kind, .nonfailable)
      XCTAssertEqual(initDecl.genericParameterClause?.textDescription, "<A>")
      XCTAssertTrue(initDecl.parameterList.isEmpty)
      XCTAssertEqual(initDecl.throwsKind, .nothrowing)
      XCTAssertEqual(initDecl.genericWhereClause?.textDescription, "where A == Foo")
      XCTAssertEqual(initDecl.body.textDescription, "{}")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "init() throws { self.foo = nil }",
      "init() throws {\nself.foo = nil\n}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 33))
      }
    )
    parseDeclarationAndTest(
      "init?<A>() where A == Foo {}",
      "init?<A>() where A == Foo {}",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 29))
      }
    )
  }

  static var allTests = [
    ("testNonfailable", testNonfailable),
    ("testOptionalFailable", testOptionalFailable),
    ("testImplicitlyUnwrappedFailable", testImplicitlyUnwrappedFailable),
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
    ("testMultipleParameters", testMultipleParameters),
    ("testInitializerThatThrows", testInitializerThatThrows),
    ("testInitializerThatRethrows", testInitializerThatRethrows),
    ("testGenericWhereClause", testGenericWhereClause),
    ("testSourceRange", testSourceRange),
  ]
}
