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

class ParserBreakStatementTests: XCTestCase {
  func testBreak() {
    parseStatementAndTest("break", "break", testClosure: { stmt in
      guard let breakStmt = stmt as? BreakStatement else {
        XCTFail("Failed in parsing a break statement.")
        return
      }
      XCTAssertNil(breakStmt.labelName)
    })
  }

  func testBreakWithLabelName() {
    parseStatementAndTest("break foo", "break foo", testClosure: { stmt in
      guard let breakStmt = stmt as? BreakStatement else {
        XCTFail("Failed in parsing a break statement.")
        return
      }
      ASTTextEqual(breakStmt.labelName, "foo")
    })
  }

  func testLabelNameNotImmediateFollow() {
    parseStatementAndTest("break\nfoo", "break", testClosure: { stmt in
      guard let breakStmt = stmt as? BreakStatement else {
        XCTFail("Failed in parsing a break statement.")
        return
      }
      XCTAssertNil(breakStmt.labelName)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("break", "break", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 6))
    })
    parseStatementAndTest("break foo", "break foo", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 10))
    })
  }

  static var allTests = [
    ("testBreak", testBreak),
    ("testBreakWithLabelName", testBreakWithLabelName),
    ("testLabelNameNotImmediateFollow", testLabelNameNotImmediateFollow),
    ("testSourceRange", testSourceRange),
  ]
}
