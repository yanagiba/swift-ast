/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
@testable import LexerTests
@testable import ParserTests

class ZTests: XCTestCase {
  // Note: tests in this file should always run last,
  // so that we can debug individual tests easily

  func testCanary() {
    XCTAssertTrue(true)
  }

  func testOne() {
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
      "var foo = bar { $0 = 0 }, a = b { _ in\ntrue\n}, x = y { t -> Int in\nt ^ 2\n}")
    parseDeclarationAndTest(
      "var foo = _foo { $0 = 0 } { willSet(newValue) { print(newValue) } }",
      "var foo = _foo { $0 = 0 } {\nwillSet(newValue) {\nprint(newValue)\n}\n}")
  }

  static var allTests = [
    ("testCanary", testCanary),
    ("testOne", testOne),
  ]
}
