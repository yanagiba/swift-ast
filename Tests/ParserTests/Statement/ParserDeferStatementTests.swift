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

class ParserDeferStatementTests: XCTestCase {
  func testDefer() {
    parseStatementAndTest("defer { close(resource) }", "defer {\nclose(resource)\n}", testClosure: { stmt in
      guard let deferStmt = stmt as? DeferStatement else {
        XCTFail("Failed in parsing a defer statement.")
        return
      }
      let stmts = deferStmt.codeBlock.statements
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is FunctionCallExpression)
      XCTAssertEqual(stmts[0].textDescription, "close(resource)")
    })
  }

  func testDeferNothing() {
    parseStatementAndTest("defer {}", "defer {}", testClosure: { stmt in
      guard let deferStmt = stmt as? DeferStatement else {
        XCTFail("Failed in parsing a defer statement.")
        return
      }
      XCTAssertTrue(deferStmt.codeBlock.statements.isEmpty)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("defer {}", "defer {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 9))
    })
  }

  static var allTests = [
    ("testDefer", testDefer),
    ("testDeferNothing", testDeferNothing),
    ("testSourceRange", testSourceRange),
  ]
}
