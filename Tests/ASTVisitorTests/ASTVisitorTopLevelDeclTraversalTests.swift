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

class ASTVisitorTopLevelDeclTraversalTests : XCTestCase {
  private let topLevelDecl = TopLevelDeclaration(statements: [
    ImportDeclaration(path: []),
    IfStatement(conditionList: [], codeBlock: CodeBlock()),
    LiteralExpression(kind: .nil),
  ])

  class DefaultVisitor : ASTVisitor {
    var carryover: String
    init() {
      carryover = ""
    }

    func visit(_: TopLevelDeclaration) throws -> Bool {
      carryover += "0"
      return true
    }

    func visit(_: ImportDeclaration) throws -> Bool {
      carryover += "1"
      return true
    }

    func visit(_: IfStatement) throws -> Bool {
      carryover += "2"
      return true
    }

    func visit(_: LiteralExpression) throws -> Bool {
      carryover += "3"
      return true
    }

    func visit(_: InitializerDeclaration) throws -> Bool {
      carryover += "4"
      return true
    }
  }

  func testDefaultTraversal() {
    let visitor = DefaultVisitor()
    XCTAssertTrue(try visitor.traverse(topLevelDecl))
    XCTAssertEqual(visitor.carryover, "0123")
  }

  func testStopAtTopLevelDecl() {
    class TopLevelDeclStopper : DefaultVisitor {
      override func visit(_: TopLevelDeclaration) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = TopLevelDeclStopper()
    XCTAssertFalse(try visitor.traverse(topLevelDecl))
    XCTAssertEqual(visitor.carryover, "stop")
  }

  func testStopAtImportDecl() {
    class TopLevelDeclStopper : DefaultVisitor {
      override func visit(_: ImportDeclaration) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = TopLevelDeclStopper()
    XCTAssertFalse(try visitor.traverse(topLevelDecl))
    XCTAssertEqual(visitor.carryover, "0stop")
  }

  func testStopAtIfStmt() {
    class TopLevelDeclStopper : DefaultVisitor {
      override func visit(_: IfStatement) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = TopLevelDeclStopper()
    XCTAssertFalse(try visitor.traverse(topLevelDecl))
    XCTAssertEqual(visitor.carryover, "01stop")
  }


  func testStopAtLiteralExpression() {
    class TopLevelDeclStopper : DefaultVisitor {
      override func visit(_: LiteralExpression) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = TopLevelDeclStopper()
    XCTAssertFalse(try visitor.traverse(topLevelDecl))
    XCTAssertEqual(visitor.carryover, "012stop")
  }

  func testStopFromNestedDecl() {
    class TopLevelDeclStopper : DefaultVisitor {
      override func visit(_: IfStatement) throws -> Bool {
        carryover += "stop"
        return false
      }

      override func visit(_: InitializerDeclaration) throws -> Bool {
        carryover += "init"
        return true
      }
    }

    var mutableStatements = topLevelDecl.statements
    mutableStatements.insert(
      InitializerDeclaration(body: CodeBlock(statements: [
        IfStatement(conditionList: [], codeBlock: CodeBlock()),
      ]
    )), at: 1)
    let localTopLevelDecl = TopLevelDeclaration(statements: mutableStatements)

    let visitor = TopLevelDeclStopper()
    XCTAssertFalse(try visitor.traverse(localTopLevelDecl))
    XCTAssertEqual(visitor.carryover, "01initstop")
  }

  static var allTests = [
    ("testDefaultTraversal", testDefaultTraversal),
    ("testStopAtTopLevelDecl", testStopAtTopLevelDecl),
    ("testStopAtImportDecl", testStopAtImportDecl),
    ("testStopAtIfStmt", testStopAtIfStmt),
    ("testStopAtLiteralExpression", testStopAtLiteralExpression),
    ("testStopFromNestedDecl", testStopFromNestedDecl),
  ]
}
