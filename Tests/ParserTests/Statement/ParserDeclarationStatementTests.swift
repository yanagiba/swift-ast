/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
@testable import Lexer

class ParserDeclarationStatementTests: XCTestCase {
  func testStartWithDeclarationKeyword() {
    parseStatementAndTest("import foo", "import foo", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is ImportDeclaration)
    })
    parseStatementAndTest("let a=1", "let a = 1", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is ConstantDeclaration)
    })
    parseStatementAndTest("var a=1", "var a = 1", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is VariableDeclaration)
    })
    parseStatementAndTest("typealias a=b", "typealias a = b", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is TypealiasDeclaration)
    })
    parseStatementAndTest("func f()", "func f()", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is FunctionDeclaration)
    })
    parseStatementAndTest("enum e{}", "enum e {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is EnumDeclaration)
    })
    parseStatementAndTest("indirect enum ie{}", "indirect enum ie {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is EnumDeclaration)
    })
    parseStatementAndTest("struct s{}", "struct s {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is StructDeclaration)
    })
    parseStatementAndTest("init(){}", "init() {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is InitializerDeclaration)
    })
    parseStatementAndTest("deinit{}", "deinit {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is DeinitializerDeclaration)
    })
    parseStatementAndTest("extension ext:base{}", "extension ext: base {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is ExtensionDeclaration)
    })
    parseStatementAndTest("subscript(i:Int)->Element{}", "subscript(i: Int) -> Element {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is SubscriptDeclaration)
    })
    parseStatementAndTest("subscript(i:Int)->Element{}", "subscript(i: Int) -> Element {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is SubscriptDeclaration)
    })
    parseStatementAndTest("protocol p{}", "protocol p {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is ProtocolDeclaration)
    })
  }

  func testStartWithAttributes() {
    parseStatementAndTest(
      "@discardableResult func f(){}",
      "@discardableResult func f() {}",
      testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is FunctionDeclaration)
    })
    parseStatementAndTest(
      "@available(*, unavailable, renamed: \"foo\") func f(){}",
      "@available(*, unavailable, renamed: \"foo\") func f() {}",
      testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is FunctionDeclaration)
    })
    parseStatementAndTest(
      "@a(h()t) @b(h[]t) @c(h{}t) func f(){}",
      "@a(h()t) @b(h[]t) @c(h{}t) func f() {}",
      testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is FunctionDeclaration)
    })
  }

  func testStartWithModifiers() {
    for modifier in Token.Kind.declarationModifiers {
      parseStatementAndTest("\(modifier) func f(){}", "\(modifier) func f() {}", testClosure: { stmt in
        XCTAssertTrue(stmt is Declaration)
        XCTAssertTrue(stmt is FunctionDeclaration)
      })
    }
    for modifier in Token.Kind.accessLevelModifiers {
      parseStatementAndTest("\(modifier) func f(){}", "\(modifier) func f() {}", testClosure: { stmt in
        XCTAssertTrue(stmt is Declaration)
        XCTAssertTrue(stmt is FunctionDeclaration)
      })
    }
    for modifier in Token.Kind.mutationModifiers {
      parseStatementAndTest("\(modifier) func f(){}", "\(modifier) func f() {}", testClosure: { stmt in
        XCTAssertTrue(stmt is Declaration)
        XCTAssertTrue(stmt is FunctionDeclaration)
      })
    }
  }

  func testClassDeclaration() {
    parseStatementAndTest("class c{}", "class c {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is ClassDeclaration)
    })
  }

  func testOperatorDeclaration() {
    parseStatementAndTest("prefix operator <!>", "prefix operator <!>", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is OperatorDeclaration)
    })
  }

  func testPrecedenceGroupDeclaration() {
    parseStatementAndTest("precedencegroup foo {}", "precedencegroup foo {}", testClosure: { stmt in
      XCTAssertTrue(stmt is Declaration)
      XCTAssertTrue(stmt is PrecedenceGroupDeclaration)
    })
  }

  func testDeclarations() {
    let stmtParser = getParser("let a = 1 ; var b = 2 \n init() {};func foo()")
    do {
      let stmts = try stmtParser.parseStatements()
      XCTAssertEqual(stmts.count, 4)
      XCTAssertEqual(stmts.textDescription, "let a = 1\nvar b = 2\ninit() {}\nfunc foo()")
      XCTAssertTrue(stmts[0] is ConstantDeclaration)
      XCTAssertTrue(stmts[1] is VariableDeclaration)
      XCTAssertTrue(stmts[2] is InitializerDeclaration)
      XCTAssertTrue(stmts[3] is FunctionDeclaration)
    } catch {
      XCTFail("Failed in parsing a list of declarations as statements.")
    }
  }

  static var allTests = [
    ("testStartWithDeclarationKeyword", testStartWithDeclarationKeyword),
    ("testStartWithAttributes", testStartWithAttributes),
    ("testStartWithModifiers", testStartWithModifiers),
    ("testClassDeclaration", testClassDeclaration),
    ("testOperatorDeclaration", testOperatorDeclaration),
    ("testPrecedenceGroupDeclaration", testPrecedenceGroupDeclaration),
    ("testDeclarations", testDeclarations),
  ]
}
