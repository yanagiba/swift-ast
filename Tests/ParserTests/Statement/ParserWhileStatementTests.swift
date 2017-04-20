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

class ParserWhileStatementTests: XCTestCase {
  func testInfiniteLoop() {
    parseStatementAndTest("while true {}", "while true {}", testClosure: { stmt in
      guard let whileStmt = stmt as? WhileStatement else {
        XCTFail("Failed in parsing a while statement.")
        return
      }
      XCTAssertEqual(whileStmt.conditionList.count, 1)
      XCTAssertEqual(whileStmt.conditionList[0].textDescription, "true")
      XCTAssertTrue(whileStmt.codeBlock.statements.isEmpty)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("while true {}", "while true {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 14))
    })
  }

  static var allTests = [
    ("testInfiniteLoop", testInfiniteLoop),
    ("testSourceRange", testSourceRange),
  ]
}
