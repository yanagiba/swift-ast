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

class ASTVisitorCodeBlockTraversalTests : XCTestCase {
  private let codeBlock = CodeBlock(statements: [
    OperatorDeclaration(kind: .prefix("😋")),
    DeferStatement(codeBlock: CodeBlock()),
    IdentifierExpression(kind: .identifier(.name("🍱"), nil)),
  ])

  class DefaultVisitor : ASTVisitor {
    var carryover: String
    init() {
      carryover = ""
    }

    func visit(_: CodeBlock) throws -> Bool {
      carryover += "0"
      return true
    }

    func visit(_: OperatorDeclaration) throws -> Bool {
      carryover += "1"
      return true
    }

    func visit(_: DeferStatement) throws -> Bool {
      carryover += "2"
      return true
    }

    func visit(_: IdentifierExpression) throws -> Bool {
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
    XCTAssertTrue(try visitor.traverse(codeBlock))
    XCTAssertEqual(visitor.carryover, "01203")
  }

  func testStopAtCodeBlock() {
    class CodeBlockStopper : DefaultVisitor {
      override func visit(_: CodeBlock) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = CodeBlockStopper()
    XCTAssertFalse(try visitor.traverse(codeBlock))
    XCTAssertEqual(visitor.carryover, "stop")
  }

  func testStopAtOperatorDecl() {
    class CodeBlockStopper : DefaultVisitor {
      override func visit(_: OperatorDeclaration) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = CodeBlockStopper()
    XCTAssertFalse(try visitor.traverse(codeBlock))
    XCTAssertEqual(visitor.carryover, "0stop")
  }

  func testStopAtIfStmt() {
    class CodeBlockStopper : DefaultVisitor {
      override func visit(_: DeferStatement) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = CodeBlockStopper()
    XCTAssertFalse(try visitor.traverse(codeBlock))
    XCTAssertEqual(visitor.carryover, "01stop")
  }


  func testStopAtIdentifierExpression() {
    class CodeBlockStopper : DefaultVisitor {
      override func visit(_: IdentifierExpression) throws -> Bool {
        carryover += "stop"
        return false
      }
    }

    let visitor = CodeBlockStopper()
    XCTAssertFalse(try visitor.traverse(codeBlock))
    XCTAssertEqual(visitor.carryover, "0120stop")
  }

  func testStopFromNestedDecl() {
    class CodeBlockStopper : DefaultVisitor {
      override func visit(_: DeferStatement) throws -> Bool {
        carryover += "stop"
        return false
      }

      override func visit(_: InitializerDeclaration) throws -> Bool {
        carryover += "init"
        return true
      }
    }

    var mutableStatements = codeBlock.statements
    mutableStatements.insert(
      InitializerDeclaration(body: CodeBlock(statements: [
        DeferStatement(codeBlock: CodeBlock()),
      ]
    )), at: 1)
    let localTopLevelDecl = CodeBlock(statements: mutableStatements)

    let visitor = CodeBlockStopper()
    XCTAssertFalse(try visitor.traverse(localTopLevelDecl))
    XCTAssertEqual(visitor.carryover, "01init0stop")
  }

  static var allTests = [
    ("testDefaultTraversal", testDefaultTraversal),
    ("testStopAtCodeBlock", testStopAtCodeBlock),
    ("testStopAtOperatorDecl", testStopAtOperatorDecl),
    ("testStopAtIfStmt", testStopAtIfStmt),
    ("testStopAtIdentifierExpression", testStopAtIdentifierExpression),
    ("testStopFromNestedDecl", testStopFromNestedDecl),
  ]
}
