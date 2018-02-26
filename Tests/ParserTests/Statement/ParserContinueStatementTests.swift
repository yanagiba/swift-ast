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

class ParserContinueStatementTests: XCTestCase {
  func testContinue() {
    parseStatementAndTest("continue", "continue", testClosure: { stmt in
      guard let continueStmt = stmt as? ContinueStatement else {
        XCTFail("Failed in parsing a continue statement.")
        return
      }
      XCTAssertNil(continueStmt.labelName)
    })
  }

  func testContinueWithLabelName() {
    parseStatementAndTest("continue foo", "continue foo", testClosure: { stmt in
      guard let continueStmt = stmt as? ContinueStatement else {
        XCTFail("Failed in parsing a continue statement.")
        return
      }
      ASTTextEqual(continueStmt.labelName, "foo")
    })
  }

  func testLabelNameNotImmediateFollow() {
    parseStatementAndTest("continue\nfoo", "continue", testClosure: { stmt in
      guard let continueStmt = stmt as? ContinueStatement else {
        XCTFail("Failed in parsing a continue statement.")
        return
      }
      XCTAssertNil(continueStmt.labelName)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("continue", "continue", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 9))
    })
    parseStatementAndTest("continue foo", "continue foo", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 13))
    })
  }

  static var allTests = [
    ("testContinue", testContinue),
    ("testContinueWithLabelName", testContinueWithLabelName),
    ("testLabelNameNotImmediateFollow", testLabelNameNotImmediateFollow),
    ("testSourceRange", testSourceRange),
  ]
}
