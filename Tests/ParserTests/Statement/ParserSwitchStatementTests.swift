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

class ParserSwitchStatementTests: XCTestCase {
  func testEmptySwitch() {
    parseStatementAndTest("switch foo {}", "switch foo {}", testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertTrue(switchStmt.expression is IdentifierExpression)
      XCTAssertEqual(switchStmt.expression.textDescription, "foo")
      XCTAssertTrue(switchStmt.cases.isEmpty)
    })
  }

  func testDefault() {
    parseStatementAndTest("switch foo { default: () }", "switch foo {\ndefault:\n()\n}", testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertTrue(switchStmt.expression is IdentifierExpression)
      XCTAssertEqual(switchStmt.expression.textDescription, "foo")
      XCTAssertEqual(switchStmt.cases.count, 1)
      guard case .default(let stmts) = switchStmt.cases[0] else {
        XCTFail("Failed in getting a default label.")
        return
      }
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is TupleExpression)
      XCTAssertEqual(stmts[0].textDescription, "()")
    })
  }

  func testSimpleCase() {
    parseStatementAndTest("switch foo { case 1: print(1); foo = 2; }",
      "switch foo {\ncase 1:\nprint(1)\nfoo = 2\n}",
      testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertTrue(switchStmt.expression is IdentifierExpression)
      XCTAssertEqual(switchStmt.expression.textDescription, "foo")
      XCTAssertEqual(switchStmt.cases.count, 1)
      guard case let .case(itemList, stmts) = switchStmt.cases[0] else {
        XCTFail("Failed in getting a case label.")
        return
      }
      XCTAssertEqual(itemList.count, 1)
      XCTAssertTrue(itemList[0].pattern is ExpressionPattern)
      XCTAssertEqual(itemList[0].pattern.textDescription, "1")
      XCTAssertNil(itemList[0].whereExpression)
      XCTAssertEqual(stmts.count, 2)
      XCTAssertTrue(stmts[0] is FunctionCallExpression)
      XCTAssertEqual(stmts[0].textDescription, "print(1)")
      XCTAssertTrue(stmts[1] is AssignmentOperatorExpression)
      XCTAssertEqual(stmts[1].textDescription, "foo = 2")
    })
  }

  func testCaseWithWhereCondition() {
    parseStatementAndTest("switch foo { case let (x, y) where x == y: print(x); print(y); }",
      "switch foo {\ncase let (x, y) where x == y:\nprint(x)\nprint(y)\n}",
      testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertTrue(switchStmt.expression is IdentifierExpression)
      XCTAssertEqual(switchStmt.expression.textDescription, "foo")
      XCTAssertEqual(switchStmt.cases.count, 1)
      guard case let .case(itemList, stmts) = switchStmt.cases[0] else {
        XCTFail("Failed in getting a case label.")
        return
      }
      XCTAssertEqual(itemList.count, 1)
      XCTAssertTrue(itemList[0].pattern is ValueBindingPattern)
      XCTAssertEqual(itemList[0].pattern.textDescription, "let (x, y)")
      guard let whereExpr = itemList[0].whereExpression else {
        XCTFail("Failed in getting a where conditino clause.")
        return
      }
      XCTAssertTrue(whereExpr is BinaryOperatorExpression)
      XCTAssertEqual(whereExpr.textDescription, "x == y")
      XCTAssertEqual(stmts.textDescription, "print(x)\nprint(y)")
    })
  }

  func testCaseItems() {
    parseStatementAndTest("switch foo { case 1, 2, 3, x where x < 0: foo = 0; }",
      "switch foo {\ncase 1, 2, 3, x where x < 0:\nfoo = 0\n}",
      testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertTrue(switchStmt.expression is IdentifierExpression)
      XCTAssertEqual(switchStmt.expression.textDescription, "foo")
      XCTAssertEqual(switchStmt.cases.count, 1)
      guard case let .case(itemList, stmts) = switchStmt.cases[0] else {
        XCTFail("Failed in getting a case label.")
        return
      }
      XCTAssertEqual(itemList.count, 4)
      XCTAssertTrue(itemList[0].pattern is ExpressionPattern)
      XCTAssertEqual(itemList[0].pattern.textDescription, "1")
      XCTAssertNil(itemList[0].whereExpression)
      XCTAssertTrue(itemList[1].pattern is ExpressionPattern)
      XCTAssertEqual(itemList[1].pattern.textDescription, "2")
      XCTAssertNil(itemList[1].whereExpression)
      XCTAssertTrue(itemList[2].pattern is ExpressionPattern)
      XCTAssertEqual(itemList[2].pattern.textDescription, "3")
      XCTAssertNil(itemList[2].whereExpression)
      XCTAssertTrue(itemList[3].pattern is IdentifierPattern)
      XCTAssertEqual(itemList[3].pattern.textDescription, "x")
      guard let whereExpr = itemList[3].whereExpression else {
        XCTFail("Failed in getting a where conditino clause.")
        return
      }
      XCTAssertTrue(whereExpr is BinaryOperatorExpression)
      XCTAssertEqual(whereExpr.textDescription, "x < 0")
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is AssignmentOperatorExpression)
      XCTAssertEqual(stmts[0].textDescription, "foo = 0")
    })
  }

  func testCasesAndDefault() {
    parseStatementAndTest(
    "switch controlExpression {\n" +
    "case pattern1:\n" +
    "    statements\n" +
    "case pattern2 where condition:\n" +
    "    statements\n" +
    "case pattern3 where condition,\n" +
    "     pattern4 where condition:\n" +
    "    statements\n" +
    "default:\n" +
    "    statements\n" +
    "}",
    "switch controlExpression {\n" +
    "case pattern1:\n" +
    "statements\n" +
    "case pattern2 where condition:\n" +
    "statements\n" +
    "case pattern3 where condition, pattern4 where condition:\n" +
    "statements\n" +
    "default:\n" +
    "statements\n" +
    "}")
  }

  func testSourceRange() {
    parseStatementAndTest("switch foo {}", "switch foo {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 14))
    })
  }

  static var allTests = [
    ("testEmptySwitch", testEmptySwitch),
    ("testDefault", testDefault),
    ("testSimpleCase", testSimpleCase),
    ("testCaseWithWhereCondition", testCaseWithWhereCondition),
    ("testCaseItems", testCaseItems),
    ("testCasesAndDefault", testCasesAndDefault),
    ("testSourceRange", testSourceRange),
  ]
}
