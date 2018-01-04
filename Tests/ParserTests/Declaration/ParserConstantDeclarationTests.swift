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

class ParserConstantDeclarationTests: XCTestCase {
  func testDefineConstant() {
    parseDeclarationAndTest("let foo", "let foo", testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertTrue(constDecl.attributes.isEmpty)
      XCTAssertTrue(constDecl.modifiers.isEmpty)
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(constDecl.initializerList[0].initializerExpression)
    })
  }

  func testDefineConstantWithTypeAnnotation() {
    parseDeclarationAndTest("let foo: Foo", "let foo: Foo", testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertTrue(constDecl.attributes.isEmpty)
      XCTAssertTrue(constDecl.modifiers.isEmpty)
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo: Foo")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(constDecl.initializerList[0].initializerExpression)
    })
  }

  func testDefineConstantWithInitializer() {
    parseDeclarationAndTest("let foo: Foo = bar", "let foo: Foo = bar", testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertTrue(constDecl.attributes.isEmpty)
      XCTAssertTrue(constDecl.modifiers.isEmpty)
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo: Foo = bar")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNotNil(constDecl.initializerList[0].initializerExpression)
    })
  }

  func testMultipleDecls() {
    parseDeclarationAndTest("let foo = bar, a, x = y",
      "let foo = bar, a, x = y",
      testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertTrue(constDecl.attributes.isEmpty)
      XCTAssertTrue(constDecl.modifiers.isEmpty)
      XCTAssertEqual(constDecl.initializerList.count, 3)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo = bar")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNotNil(constDecl.initializerList[0].initializerExpression)
      XCTAssertEqual(constDecl.initializerList[1].textDescription, "a")
      XCTAssertTrue(constDecl.initializerList[1].pattern is IdentifierPattern)
      XCTAssertNil(constDecl.initializerList[1].initializerExpression)
      XCTAssertEqual(constDecl.initializerList[2].textDescription, "x = y")
      XCTAssertTrue(constDecl.initializerList[2].pattern is IdentifierPattern)
      XCTAssertNotNil(constDecl.initializerList[2].initializerExpression)
    })
  }

  func testAttributes() {
    parseDeclarationAndTest("@a let foo", "@a let foo", testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertEqual(constDecl.attributes.count, 1)
      ASTTextEqual(constDecl.attributes[0].name, "a")
      XCTAssertTrue(constDecl.modifiers.isEmpty)
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(constDecl.initializerList[0].initializerExpression)
    })
  }

  func testModifiers() {
    parseDeclarationAndTest(
      "private nonmutating static final let foo = bar",
      "private nonmutating static final let foo = bar",
      testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertTrue(constDecl.attributes.isEmpty)
      XCTAssertEqual(constDecl.modifiers.count, 4)
      XCTAssertEqual(constDecl.modifiers[0], .accessLevel(.private))
      XCTAssertEqual(constDecl.modifiers[1], .mutation(.nonmutating))
      XCTAssertEqual(constDecl.modifiers[2], .static)
      XCTAssertEqual(constDecl.modifiers[3], .final)
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo = bar")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNotNil(constDecl.initializerList[0].initializerExpression)
    })
  }

  func testAttributeAndModifiers() {
    parseDeclarationAndTest("@a fileprivate let foo", "@a fileprivate let foo", testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertEqual(constDecl.attributes.count, 1)
      ASTTextEqual(constDecl.attributes[0].name, "a")
      XCTAssertEqual(constDecl.modifiers.count, 1)
      XCTAssertEqual(constDecl.modifiers[0], .accessLevel(.fileprivate))
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertNil(constDecl.initializerList[0].initializerExpression)
    })
  }

  func testFollowedByTrailingClosure() {
    parseDeclarationAndTest(
      "let foo = bar { $0 == 0 }",
      "let foo = bar { $0 == 0 }",
      testClosure: { decl in
      guard let constDecl = decl as? ConstantDeclaration else {
        XCTFail("Failed in getting a constant declaration.")
        return
      }

      XCTAssertTrue(constDecl.attributes.isEmpty)
      XCTAssertTrue(constDecl.modifiers.isEmpty)
      XCTAssertEqual(constDecl.initializerList.count, 1)
      XCTAssertEqual(constDecl.initializerList[0].textDescription, "foo = bar { $0 == 0 }")
      XCTAssertTrue(constDecl.initializerList[0].pattern is IdentifierPattern)
      XCTAssertTrue(constDecl.initializerList[0].initializerExpression is FunctionCallExpression)
    })
    parseDeclarationAndTest(
      "let foo = bar { $0 = 0 }, a = b { _ in true }, x = y { t -> Int in t^2 }",
      "let foo = bar { $0 = 0 }, a = b { _ in\ntrue\n}, x = y { t -> Int in\nt ^ 2\n}")
    parseDeclarationAndTest(
      "let foo = bar { $0 == 0 }.joined()",
      "let foo = bar { $0 == 0 }.joined()")
  }

  func testFollowedBySemicolon() {
    parseDeclarationAndTest("let issue = 61;", "let issue = 61")
  }

  func testSourceRange() {
    parseDeclarationAndTest("let foo", "let foo", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 8))
    })
    parseDeclarationAndTest("@a let foo = bar, a, x = y", "@a let foo = bar, a, x = y", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 27))
    })
    parseDeclarationAndTest("private let foo, bar", "private let foo, bar", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 21))
    })
    parseDeclarationAndTest("let foo = bar { $0 == 0 }", "let foo = bar { $0 == 0 }", testClosure: { decl in
      XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 26))
    })
  }

  static var allTests = [
    ("testDefineConstant", testDefineConstant),
    ("testDefineConstantWithTypeAnnotation", testDefineConstantWithTypeAnnotation),
    ("testDefineConstantWithInitializer", testDefineConstantWithInitializer),
    ("testMultipleDecls", testMultipleDecls),
    ("testAttributes", testAttributes),
    ("testModifiers", testModifiers),
    ("testAttributeAndModifiers", testAttributeAndModifiers),
    ("testFollowedByTrailingClosure", testFollowedByTrailingClosure),
    ("testFollowedBySemicolon", testFollowedBySemicolon),
    ("testSourceRange", testSourceRange),
  ]
}
