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

class ParserLabeledStatementTests: XCTestCase {
  func testLabeledFor() {
    parseStatementAndTest("foo: for _ in 0..<10 {}", "foo: for _ in 0 ..< 10 {}", testClosure: { stmt in
      guard let labeledStmt = stmt as? LabeledStatement else {
        XCTFail("Failed in parsing a labeled statement.")
        return
      }
      XCTAssertEqual(labeledStmt.labelName.textDescription, "foo")
      XCTAssertTrue(labeledStmt.statement is ForInStatement)
    })
  }

  func testLabeledWhile() {
    parseStatementAndTest("foo: while true {}", "foo: while true {}", testClosure: { stmt in
      guard let labeledStmt = stmt as? LabeledStatement else {
        XCTFail("Failed in parsing a labeled statement.")
        return
      }
      XCTAssertEqual(labeledStmt.labelName.textDescription, "foo")
      XCTAssertTrue(labeledStmt.statement is WhileStatement)
    })
  }

  func testLabeledRepeat() {
    parseStatementAndTest("foo: repeat {} while true", "foo: repeat {} while true", testClosure: { stmt in
      guard let labeledStmt = stmt as? LabeledStatement else {
        XCTFail("Failed in parsing a labeled statement.")
        return
      }
      XCTAssertEqual(labeledStmt.labelName.textDescription, "foo")
      XCTAssertTrue(labeledStmt.statement is RepeatWhileStatement)
    })
  }

  func testLabeledIf() {
    parseStatementAndTest("foo: if x {}", "foo: if x {}", testClosure: { stmt in
      guard let labeledStmt = stmt as? LabeledStatement else {
        XCTFail("Failed in parsing a labeled statement.")
        return
      }
      XCTAssertEqual(labeledStmt.labelName.textDescription, "foo")
      XCTAssertTrue(labeledStmt.statement is IfStatement)
    })
  }

  func testLabeledSwitch() {
    parseStatementAndTest("foo: switch bar {}", "foo: switch bar {}", testClosure: { stmt in
      guard let labeledStmt = stmt as? LabeledStatement else {
        XCTFail("Failed in parsing a labeled statement.")
        return
      }
      XCTAssertEqual(labeledStmt.labelName.textDescription, "foo")
      XCTAssertTrue(labeledStmt.statement is SwitchStatement)
    })
  }

  func testLabeledDo() {
    parseStatementAndTest("foo: do { try bar() }", "foo: do {\ntry bar()\n}", testClosure: { stmt in
      guard let labeledStmt = stmt as? LabeledStatement else {
        XCTFail("Failed in parsing a labeled statement.")
        return
      }
      XCTAssertEqual(labeledStmt.labelName.textDescription, "foo")
      XCTAssertTrue(labeledStmt.statement is DoStatement)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("foo: for _ in 0..<10 {}", "foo: for _ in 0 ..< 10 {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 24))
    })
    parseStatementAndTest("foo: while true {}", "foo: while true {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 19))
    })
    parseStatementAndTest("foo: repeat {} while true", "foo: repeat {} while true", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 26))
    })
    parseStatementAndTest("foo: if x {}", "foo: if x {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 13))
    })
    parseStatementAndTest("foo: switch bar {}", "foo: switch bar {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 19))
    })
    parseStatementAndTest("foo: do { try bar() }", "foo: do {\ntry bar()\n}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 22))
    })
  }

  static var allTests = [
    ("testLabeledFor", testLabeledFor),
    ("testLabeledWhile", testLabeledWhile),
    ("testLabeledRepeat", testLabeledRepeat),
    ("testLabeledIf", testLabeledIf),
    ("testLabeledSwitch", testLabeledSwitch),
    ("testLabeledDo", testLabeledDo),
    ("testSourceRange", testSourceRange),
  ]
}
