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

class ParserReturnStatementTests: XCTestCase {
  func testReturn() {
    parseStatementAndTest("return", "return", testClosure: { stmt in
      guard let returnStmt = stmt as? ReturnStatement else {
        XCTFail("Failed in parsing a return statement.")
        return
      }
      XCTAssertNil(returnStmt.expression)
    })
  }

  func testReturnWithExpression() {
    parseStatementAndTest("return foo", "return foo", testClosure: { stmt in
      guard let returnStmt = stmt as? ReturnStatement, let expr = returnStmt.expression else {
        XCTFail("Failed in parsing a return statement.")
        return
      }
      XCTAssertTrue(expr is IdentifierExpression)
      XCTAssertEqual(expr.textDescription, "foo")
    })
  }

  func testSourceRange() {
    parseStatementAndTest("return", "return", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 7))
    })
    parseStatementAndTest("return foo", "return foo", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 11))
    })
  }

  static var allTests = [
    ("testReturn", testReturn),
    ("testReturnWithExpression", testReturnWithExpression),
    ("testSourceRange", testSourceRange),
  ]
}
