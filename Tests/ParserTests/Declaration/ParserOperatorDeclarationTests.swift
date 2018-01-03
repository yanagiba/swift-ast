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

class ParserOperatorDeclarationTests: XCTestCase {
  func testPrefixOperator() {
    parseDeclarationAndTest(
      "prefix operator <!>",
      "prefix operator <!>",
      testClosure: { decl in
      guard let opDecl = decl as? OperatorDeclaration,
        case .prefix(let op) = opDecl.kind else {
        XCTFail("Failed in getting an operator declaration.")
        return
      }

      XCTAssertEqual(op, "<!>")
    })
  }

  func testInfixOperator() {
    parseDeclarationAndTest(
      "infix operator <!>",
      "infix operator <!>",
      testClosure: { decl in
      guard let opDecl = decl as? OperatorDeclaration,
        case let .infix(op, id) = opDecl.kind else {
        XCTFail("Failed in getting an operator declaration.")
        return
      }

      XCTAssertEqual(op, "<!>")
      XCTAssertNil(id)
    })
  }

  func testInfixOperatorWithPrecedenceGroupName() {
    parseDeclarationAndTest(
      "infix operator <!>:foo",
      "infix operator <!> : foo",
      testClosure: { decl in
      guard let opDecl = decl as? OperatorDeclaration,
        case let .infix(op, id) = opDecl.kind else {
        XCTFail("Failed in getting an operator declaration.")
        return
      }

      XCTAssertEqual(op, "<!>")
      ASTTextEqual(id, "foo")
    })
  }

  func testPostfixOperator() {
    parseDeclarationAndTest(
      "postfix operator <!>",
      "postfix operator <!>",
      testClosure: { decl in
      guard let opDecl = decl as? OperatorDeclaration,
        case .postfix(let op) = opDecl.kind else {
        XCTFail("Failed in getting an operator declaration.")
        return
      }

      XCTAssertEqual(op, "<!>")
    })
  }

  func testSourceRange() {
    parseDeclarationAndTest(
      "postfix operator <!>",
      "postfix operator <!>",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 21))
      }
    )
    parseDeclarationAndTest(
      "infix operator <!>:foo",
      "infix operator <!> : foo",
      testClosure: { decl in
        XCTAssertEqual(decl.sourceRange, getRange(1, 1, 1, 23))
      }
    )
  }

  static var allTests = [
    ("testPrefixOperator", testPrefixOperator),
    ("testInfixOperator", testInfixOperator),
    ("testInfixOperatorWithPrecedenceGroupName", testInfixOperatorWithPrecedenceGroupName),
    ("testPostfixOperator", testPostfixOperator),
    ("testSourceRange", testSourceRange),
  ]
}
