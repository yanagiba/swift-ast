/*
   Copyright 2017, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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
      """
      switch foo {
      case 1:
      print(1)
      foo = 2
      }
      """,
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
      """
      switch foo {
      case let (x, y) where x == y:
      print(x)
      print(y)
      }
      """,
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
      """
      switch foo {
      case 1, 2, 3, x where x < 0:
      foo = 0
      }
      """,
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
    """
    switch controlExpression {
    case pattern1:
        statements
    case pattern2 where condition:
        statements
    case pattern3 where condition,
         pattern4 where condition:
        statements
    default:
        statements
    }
    """,
    """
    switch controlExpression {
    case pattern1:
    statements
    case pattern2 where condition:
    statements
    case pattern3 where condition, pattern4 where condition:
    statements
    default:
    statements
    }
    """)
  }

  func testCompilerControlStatementsInsideCaseBody() {
    parseStatementAndTest(
    """
    switch foo {
    case 1:
    #warning("message")
    print(1)
    default:
    #sourceLocation(file: "file-name", line: 10)
    print(2)
    }
    """,
    """
    switch foo {
    case 1:
    #warning("message")
    print(1)
    default:
    #sourceLocation(file: "file-name", line: 10)
    print(2)
    }
    """,
    testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertEqual(switchStmt.cases.count, 2)
      guard case let .case(_, caseStatements) = switchStmt.cases[0] else {
        XCTFail("Failed in getting the first case body.")
        return
      }
      XCTAssertEqual(caseStatements.count, 2)
      XCTAssertTrue(caseStatements[0] is CompilerControlStatement)
      XCTAssertTrue(caseStatements[1] is FunctionCallExpression)
      guard case let .default(defaultStatements) = switchStmt.cases[1] else {
        XCTFail("Failed in getting the default case body.")
        return
      }
      XCTAssertEqual(defaultStatements.count, 2)
      XCTAssertTrue(defaultStatements[0] is CompilerControlStatement)
      XCTAssertTrue(defaultStatements[1] is FunctionCallExpression)
    })
  }

  func testConditionalCompilationCase() {
    parseStatementAndTest(
    """
    switch foo {
    #if DEBUG
    case .debug:
        debugAction()
    #else
    case .release:
        releaseAction()
    #endif
    }
    """,
    """
    switch foo {
    #if DEBUG
    case .debug:
    debugAction()
    #else
    case .release:
    releaseAction()
    #endif
    }
    """,
    testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertEqual(switchStmt.cases.count, 5)
      guard case .compilerControl(let ifStmt) = switchStmt.cases[0] else {
        XCTFail("Expected compiler control statement.")
        return
      }
      XCTAssertEqual(ifStmt.textDescription, "#if DEBUG")
      guard case .case = switchStmt.cases[1] else {
        XCTFail("Expected case.")
        return
      }
      guard case .compilerControl(let elseStmt) = switchStmt.cases[2] else {
        XCTFail("Expected compiler control statement.")
        return
      }
      XCTAssertEqual(elseStmt.textDescription, "#else")
      guard case .case = switchStmt.cases[3] else {
        XCTFail("Expected case.")
        return
      }
      guard case .compilerControl(let endifStmt) = switchStmt.cases[4] else {
        XCTFail("Expected compiler control statement.")
        return
      }
      XCTAssertEqual(endifStmt.textDescription, "#endif")
    })
  }

  func testConditionalCompilationWithRegularCases() {
    parseStatementAndTest(
    """
    switch value {
    case .a:
        handleA()
    #if os(iOS)
    case .b:
        handleB()
    #endif
    default:
        handleDefault()
    }
    """,
    """
    switch value {
    case .a:
    handleA()
    #if os(iOS)
    case .b:
    handleB()
    #endif
    default:
    handleDefault()
    }
    """,
    testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      // .case(.a), #if, .case(.b), #endif, .default
      XCTAssertEqual(switchStmt.cases.count, 5)
      guard case .case = switchStmt.cases[0] else {
        XCTFail("Expected case.")
        return
      }
      guard case .compilerControl = switchStmt.cases[1] else {
        XCTFail("Expected compiler control statement.")
        return
      }
      guard case .case = switchStmt.cases[2] else {
        XCTFail("Expected case.")
        return
      }
      guard case .compilerControl = switchStmt.cases[3] else {
        XCTFail("Expected compiler control statement.")
        return
      }
      guard case .default = switchStmt.cases[4] else {
        XCTFail("Expected default.")
        return
      }
    })
  }

  func testConditionalCompilationWithElseIf() {
    parseStatementAndTest(
    """
    switch mode {
    #if os(iOS)
    case .touch:
        handleTouch()
    #elseif os(macOS)
    case .click:
        handleClick()
    #else
    case .generic:
        handleGeneric()
    #endif
    }
    """,
    """
    switch mode {
    #if os(iOS)
    case .touch:
    handleTouch()
    #elseif os(macOS)
    case .click:
    handleClick()
    #else
    case .generic:
    handleGeneric()
    #endif
    }
    """,
    testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      // Should have compiler control cases for #if, case, #elseif, case, #else, case, #endif
      XCTAssertEqual(switchStmt.cases.count, 7)
    })
  }

  func testMultipleConditionalBlocks() {
    parseStatementAndTest(
    """
    switch value {
    case .a:
        handleA()
    #if DEBUG
    case .debug:
        debugOnly()
    #endif
    #if VERBOSE
    case .verbose:
        verboseOnly()
    #endif
    default:
        handleDefault()
    }
    """,
    """
    switch value {
    case .a:
    handleA()
    #if DEBUG
    case .debug:
    debugOnly()
    #endif
    #if VERBOSE
    case .verbose:
    verboseOnly()
    #endif
    default:
    handleDefault()
    }
    """,
    testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      // case .a + #if + case .debug + #endif + #if + case .verbose + #endif + default = 8
      XCTAssertEqual(switchStmt.cases.count, 8)
    })
  }

  func testConditionalAroundDefault() {
    parseStatementAndTest(
    """
    switch x {
    case 1:
        one()
    #if DEBUG
    default:
        debugDefault()
    #else
    default:
        releaseDefault()
    #endif
    }
    """,
    """
    switch x {
    case 1:
    one()
    #if DEBUG
    default:
    debugDefault()
    #else
    default:
    releaseDefault()
    #endif
    }
    """,
    testClosure: { stmt in
      guard let switchStmt = stmt as? SwitchStatement else {
        XCTFail("Failed in parsing a switch statement.")
        return
      }
      XCTAssertEqual(switchStmt.cases.count, 6)
    })
  }

  func testSourceRange() {
    parseStatementAndTest("switch foo {}", "switch foo {}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 14))
    })
  }
}
