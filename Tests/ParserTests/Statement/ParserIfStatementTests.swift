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

class ParserIfStatementTests: XCTestCase {
  func testIf() {
    parseStatementAndTest("if true {}", "if true {}", testClosure: { stmt in
      guard let ifStmt = stmt as? IfStatement else {
        XCTFail("Failed in parsing a if statement.")
        return
      }
      XCTAssertEqual(ifStmt.conditionList.count, 1)
      XCTAssertEqual(ifStmt.conditionList[0].textDescription, "true")
      XCTAssertTrue(ifStmt.codeBlock.statements.isEmpty)
      XCTAssertNil(ifStmt.elseClause)
    })
  }

  func testElse() {
    parseStatementAndTest("if foo {} else {}", "if foo {} else {}", testClosure: { stmt in
      guard let ifStmt = stmt as? IfStatement else {
        XCTFail("Failed in parsing a if statement.")
        return
      }
      XCTAssertEqual(ifStmt.conditionList.count, 1)
      XCTAssertEqual(ifStmt.conditionList[0].textDescription, "foo")
      XCTAssertTrue(ifStmt.codeBlock.statements.isEmpty)
      guard let elseClause = ifStmt.elseClause, case .else(let elseBlock) = elseClause else {
        XCTFail("Failed in getting a else clause.")
        return
      }
      XCTAssertTrue(elseBlock.statements.isEmpty)
    })
  }

  func testElseIf() {
    parseStatementAndTest("if foo {} else if bar {}", "if foo {} else if bar {}", testClosure: { stmt in
      guard let ifStmt = stmt as? IfStatement else {
        XCTFail("Failed in parsing a if statement.")
        return
      }
      XCTAssertEqual(ifStmt.conditionList.count, 1)
      XCTAssertEqual(ifStmt.conditionList[0].textDescription, "foo")
      XCTAssertTrue(ifStmt.codeBlock.statements.isEmpty)
      guard let elseClause = ifStmt.elseClause, case .elseif(let elseIfStmt) = elseClause else {
        XCTFail("Failed in getting a else clause.")
        return
      }
      XCTAssertEqual(elseIfStmt.conditionList.count, 1)
      XCTAssertEqual(elseIfStmt.conditionList[0].textDescription, "bar")
      XCTAssertTrue(elseIfStmt.codeBlock.statements.isEmpty)
      XCTAssertNil(elseIfStmt.elseClause)
    })
  }

  func testIfElseIfElse() {
    parseStatementAndTest("if foo {} else if bar {} else {}", "if foo {} else if bar {} else {}", testClosure: { stmt in
      guard let ifStmt = stmt as? IfStatement else {
        XCTFail("Failed in parsing a if statement.")
        return
      }
      XCTAssertEqual(ifStmt.conditionList.count, 1)
      XCTAssertEqual(ifStmt.conditionList[0].textDescription, "foo")
      XCTAssertTrue(ifStmt.codeBlock.statements.isEmpty)
      guard let elseIfClause = ifStmt.elseClause, case .elseif(let elseIfStmt) = elseIfClause else {
        XCTFail("Failed in getting a else clause.")
        return
      }
      XCTAssertEqual(elseIfStmt.conditionList.count, 1)
      XCTAssertEqual(elseIfStmt.conditionList[0].textDescription, "bar")
      XCTAssertTrue(elseIfStmt.codeBlock.statements.isEmpty)
      guard let elseClause = elseIfStmt.elseClause, case .else(let elseBlock) = elseClause else {
        XCTFail("Failed in getting a else clause.")
        return
      }
      XCTAssertTrue(elseBlock.statements.isEmpty)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("if true {}", "if true {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 11))
    })
    parseStatementAndTest("if foo {} else {}", "if foo {} else {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 18))
    })
    parseStatementAndTest("if foo {} else if bar {}", "if foo {} else if bar {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 25))
    })
    parseStatementAndTest("if foo {} else if bar {} else {}", "if foo {} else if bar {} else {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 33))
    })
  }

  static var allTests = [
    ("testIf", testIf),
    ("testElse", testElse),
    ("testElseIf", testElseIf),
    ("testIfElseIfElse", testIfElseIfElse),
    ("testSourceRange", testSourceRange),
  ]
}
