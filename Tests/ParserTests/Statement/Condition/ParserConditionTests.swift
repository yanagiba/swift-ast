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

class ParserConditionTests: XCTestCase { // Note: we will test condition and condition-list in the while-statement
  func testBooleanCondition() {
    parseStatementAndTest("while true {}", "while true {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .expression(let expr) = conditionList[0] else {
        XCTFail("Failed in getting an expression condition.")
        return
      }
      XCTAssertTrue(expr is LiteralExpression)
      XCTAssertEqual(expr.textDescription, "true")
    })
  }

  func testBooleanOperator() {
    parseStatementAndTest("while cond1 && cond2 || cond3 {}", "while cond1 && cond2 || cond3 {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .expression(let expr) = conditionList[0] else {
        XCTFail("Failed in getting an expression condition.")
        return
      }
      XCTAssertTrue(expr is BinaryOperatorExpression)
      XCTAssertEqual(expr.textDescription, "cond1 && cond2 || cond3")
    })
  }

  func testParenthesized() {
    parseStatementAndTest("while (cond1 && cond2 || cond3) {}", "while (cond1 && cond2 || cond3) {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .expression(let expr) = conditionList[0] else {
        XCTFail("Failed in getting an expression condition.")
        return
      }
      XCTAssertTrue(expr is ParenthesizedExpression)
      XCTAssertEqual(expr.textDescription, "(cond1 && cond2 || cond3)")
    })
  }

  func testAvailableToAll() {
    parseStatementAndTest("while #available(*) {}", "while #available(*) {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .availability(let avail) = conditionList[0] else {
        XCTFail("Failed in getting an availability condition.")
        return
      }
      XCTAssertEqual(avail.arguments.count, 1)
      guard case .all = avail.arguments[0] else {
        XCTFail("Failed in getting an availability argument `*`")
        return
      }
      XCTAssertEqual(avail.arguments[0].textDescription, "*")
      XCTAssertEqual(avail.textDescription, "#available(*)")
    })
    parseStatementAndTest("while #available(  *  ) {}", "while #available(*) {}")
    parseStatementAndTest("while #available( *) {}", "while #available(*) {}")
    parseStatementAndTest("while #available(* ) {}", "while #available(*) {}")
  }

  func testAvailableToMajorVersion() {
    parseStatementAndTest("while #available(iOS 10, *) {}", "while #available(iOS 10, *) {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .availability(let avail) = conditionList[0] else {
        XCTFail("Failed in getting an availability condition.")
        return
      }
      let args = avail.arguments
      XCTAssertEqual(args.count, 2)
      guard case let .major(platform, majorVersion) = args[0] else {
        XCTFail("Failed in getting an availability argument `iOS 10`")
        return
      }
      XCTAssertEqual(platform, "iOS")
      XCTAssertEqual(majorVersion, 10)
      XCTAssertEqual(args[0].textDescription, "iOS 10")
      guard case .all = args[1] else {
        XCTFail("Failed in getting an availability argument `*`")
        return
      }
      XCTAssertEqual(args[1].textDescription, "*")
      XCTAssertEqual(avail.textDescription, "#available(iOS 10, *)")
    })
  }

  func testAvailableToMinorVersion() {
    parseStatementAndTest("while #available(iOS 10.2, *) {}", "while #available(iOS 10.2, *) {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .availability(let avail) = conditionList[0] else {
        XCTFail("Failed in getting an availability condition.")
        return
      }
      let args = avail.arguments
      XCTAssertEqual(args.count, 2)
      guard case let .minor(platform, majorVersion, minorVersion) = args[0] else {
        XCTFail("Failed in getting an availability argument `iOS 10.2`")
        return
      }
      XCTAssertEqual(platform, "iOS")
      XCTAssertEqual(majorVersion, 10)
      XCTAssertEqual(minorVersion, 2)
      XCTAssertEqual(args[0].textDescription, "iOS 10.2")
      guard case .all = args[1] else {
        XCTFail("Failed in getting an availability argument `*`")
        return
      }
      XCTAssertEqual(args[1].textDescription, "*")
      XCTAssertEqual(avail.textDescription, "#available(iOS 10.2, *)")
    })
  }

  func testAvailableToPatchVersion() {
    parseStatementAndTest("while #available(iOS 10.2.1, *) {}", "while #available(iOS 10.2.1, *) {}", testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case .availability(let avail) = conditionList[0] else {
        XCTFail("Failed in getting an availability condition.")
        return
      }
      let args = avail.arguments
      XCTAssertEqual(args.count, 2)
      guard case let .patch(platform, majorVersion, minorVersion, patchVersion) = args[0] else {
        XCTFail("Failed in getting an availability argument `iOS 10.2.1`")
        return
      }
      XCTAssertEqual(platform, "iOS")
      XCTAssertEqual(majorVersion, 10)
      XCTAssertEqual(minorVersion, 2)
      XCTAssertEqual(patchVersion, 1)
      XCTAssertEqual(args[0].textDescription, "iOS 10.2.1")
      guard case .all = args[1] else {
        XCTFail("Failed in getting an availability argument `*`")
        return
      }
      XCTAssertEqual(args[1].textDescription, "*")
      XCTAssertEqual(avail.textDescription, "#available(iOS 10.2.1, *)")
    })
  }

  func testCaseCondition() {
    parseStatementAndTest("while case .foo(let bar) = foobar {}",
      "while case .foo(let bar) = foobar {}",
      testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case let .case(pattern, initExpr) = conditionList[0] else {
        XCTFail("Failed in getting a case condition.")
        return
      }
      XCTAssertTrue(pattern is EnumCasePattern)
      XCTAssertEqual(pattern.textDescription, ".foo(let bar)")
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr.textDescription, "foobar")
    })
  }

  func testExprPatternIsAssignmentOperatorExpr() {
    parseStatementAndTest("while case 0..<255 = aNumber {}",
      "while case 0 ..< 255 = aNumber {}",
      testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 1)
      guard case let .case(pattern, initExpr) = conditionList[0] else {
        XCTFail("Failed in getting a case condition.")
        return
      }
      XCTAssertTrue(pattern is ExpressionPattern)
      XCTAssertEqual(pattern.textDescription, "0 ..< 255")
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr.textDescription, "aNumber")
    })
  }

  func testLetCondition() {
    parseStatementAndTest("while let foo = foo, !foo.isEmpty {}",
      "while let foo = foo, !foo.isEmpty {}",
      testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 2)
      guard case let .let(pattern, initExpr) = conditionList[0] else {
        XCTFail("Failed in getting an optional-binding condition.")
        return
      }
      XCTAssertTrue(pattern is IdentifierPattern)
      XCTAssertEqual(pattern.textDescription, "foo")
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr.textDescription, "foo")
      guard case .expression(let expr) = conditionList[1] else {
        XCTFail("Failed in getting an expression condition.")
        return
      }
      XCTAssertTrue(expr is PrefixOperatorExpression)
      XCTAssertEqual(expr.textDescription, "!foo.isEmpty")
    })
  }

  func testVarCondition() {
    parseStatementAndTest("while var foo = foo, !foo.isEmpty {}",
      "while var foo = foo, !foo.isEmpty {}",
      testClosure: { stmt in
      let conditionList = self.getConditionList(from: stmt)
      XCTAssertEqual(conditionList.count, 2)
      guard case let .var(pattern, initExpr) = conditionList[0] else {
        XCTFail("Failed in getting an optional-binding condition.")
        return
      }
      XCTAssertTrue(pattern is IdentifierPattern)
      XCTAssertEqual(pattern.textDescription, "foo")
      XCTAssertTrue(initExpr is IdentifierExpression)
      XCTAssertEqual(initExpr.textDescription, "foo")
      guard case .expression(let expr) = conditionList[1] else {
        XCTFail("Failed in getting an expression condition.")
        return
      }
      XCTAssertTrue(expr is PrefixOperatorExpression)
      XCTAssertEqual(expr.textDescription, "!foo.isEmpty")
    })
  }

  private func getConditionList(from stmt: Statement) -> ConditionList {
    if let whileStmt = stmt as? WhileStatement, !whileStmt.conditionList.isEmpty {
      return whileStmt.conditionList
    }
    fatalError("Failed in parsing a while statement or getting its condition list.")
  }

  func testOpenChveronIsProperlyChecked() {
    parseStatementAndTest("if foo < 1 {}", "if foo < 1 {}")
    parseStatementAndTest("if foo < bar {}", "if foo < bar {}")
    parseStatementAndTest("if foo < (bar) {}", "if foo < (bar) {}")
  }

  static var allTests = [
    ("testBooleanCondition", testBooleanCondition),
    ("testBooleanOperator", testBooleanOperator),
    ("testParenthesized", testParenthesized),
    ("testAvailableToAll", testAvailableToAll),
    ("testAvailableToMajorVersion", testAvailableToMajorVersion),
    ("testAvailableToMinorVersion", testAvailableToMinorVersion),
    ("testAvailableToPatchVersion", testAvailableToPatchVersion),
    ("testCaseCondition",testCaseCondition),
    ("testExprPatternIsAssignmentOperatorExpr", testExprPatternIsAssignmentOperatorExpr),
    ("testLetCondition", testLetCondition),
    ("testVarCondition", testVarCondition),
    ("testOpenChveronIsProperlyChecked", testOpenChveronIsProperlyChecked),
  ]
}
