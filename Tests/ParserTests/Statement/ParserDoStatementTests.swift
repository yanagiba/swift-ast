/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserDoStatementTests: XCTestCase {
  func testNoCatch() {
    parseStatementAndTest("do { try foo() }", "do {\ntry foo()\n}", testClosure: { stmt in
      guard let doStmt = stmt as? DoStatement else {
        XCTFail("Failed in parsing a do statement.")
        return
      }
      let stmts = doStmt.codeBlock.statements
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is TryOperatorExpression)
      XCTAssertEqual(stmts[0].textDescription, "try foo()")
      XCTAssertTrue(doStmt.catchClauses.isEmpty)
    })
  }

  func testCatchAll() {
    parseStatementAndTest("do { try foo() } catch { print(\"bar\") }",
      """
      do {
      try foo()
      } catch {
      print(\"bar\")
      }
      """,
      testClosure: { stmt in
      guard let doStmt = stmt as? DoStatement else {
        XCTFail("Failed in parsing a do statement.")
        return
      }
      let stmts = doStmt.codeBlock.statements
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is TryOperatorExpression)
      XCTAssertEqual(stmts[0].textDescription, "try foo()")
      let catchClauses = doStmt.catchClauses
      XCTAssertEqual(catchClauses.count, 1)
      XCTAssertNil(catchClauses[0].pattern)
      XCTAssertNil(catchClauses[0].whereExpression)
      let catchStmts = catchClauses[0].codeBlock.statements
      XCTAssertEqual(catchStmts.count, 1)
      XCTAssertTrue(catchStmts[0] is FunctionCallExpression)
      XCTAssertEqual(catchStmts[0].textDescription, "print(\"bar\")")
    })
  }

  func testCatchPattern() {
    parseStatementAndTest("do { try foo() } catch e { print(e.localizedDescription) }",
      """
      do {
      try foo()
      } catch e {
      print(e.localizedDescription)
      }
      """,
      testClosure: { stmt in
      guard let doStmt = stmt as? DoStatement else {
        XCTFail("Failed in parsing a do statement.")
        return
      }
      XCTAssertEqual(doStmt.codeBlock.statements.count, 1)
      let catchClauses = doStmt.catchClauses
      XCTAssertEqual(catchClauses.count, 1)
      guard let catchPattern = catchClauses[0].pattern else  {
        XCTFail("Failed in getting a pattern in the catch clause.")
        return
      }
      XCTAssertTrue(catchPattern is IdentifierPattern)
      XCTAssertEqual(catchPattern.textDescription, "e")
      XCTAssertNil(catchClauses[0].whereExpression)
      XCTAssertEqual(catchClauses[0].codeBlock.statements.count, 1)
    })
  }

  func testCatchWhere() {
    parseStatementAndTest("do { try foo() } catch where error is NSError {}",
      """
      do {
      try foo()
      } catch where error is NSError {}
      """,
      testClosure: { stmt in
      guard let doStmt = stmt as? DoStatement else {
        XCTFail("Failed in parsing a do statement.")
        return
      }
      XCTAssertEqual(doStmt.codeBlock.statements.count, 1)
      let catchClauses = doStmt.catchClauses
      XCTAssertEqual(catchClauses.count, 1)
      XCTAssertNil(catchClauses[0].pattern)
      guard let whereExpr = catchClauses[0].whereExpression else  {
        XCTFail("Failed in getting a where expression in the catch clause.")
        return
      }
      XCTAssertTrue(whereExpr is TypeCastingOperatorExpression)
      XCTAssertEqual(whereExpr.textDescription, "error is NSError")
      XCTAssertTrue(catchClauses[0].codeBlock.statements.isEmpty)
    })
  }

  func testCatchPatternAndWhere() {
    parseStatementAndTest("do { try foo() } catch e where e is NSError {}",
      """
      do {
      try foo()
      } catch e where e is NSError {}
      """,
      testClosure: { stmt in
      guard let doStmt = stmt as? DoStatement else {
        XCTFail("Failed in parsing a do statement.")
        return
      }
      XCTAssertEqual(doStmt.codeBlock.statements.count, 1)
      let catchClauses = doStmt.catchClauses
      XCTAssertEqual(catchClauses.count, 1)
      guard let catchPattern = catchClauses[0].pattern else  {
        XCTFail("Failed in getting a pattern in the catch clause.")
        return
      }
      XCTAssertTrue(catchPattern is IdentifierPattern)
      XCTAssertEqual(catchPattern.textDescription, "e")
      guard let whereExpr = catchClauses[0].whereExpression else  {
        XCTFail("Failed in getting a where expression in the catch clause.")
        return
      }
      XCTAssertTrue(whereExpr is TypeCastingOperatorExpression)
      XCTAssertEqual(whereExpr.textDescription, "e is NSError")
      XCTAssertTrue(catchClauses[0].codeBlock.statements.isEmpty)
    })
  }

  func testMultipleCatches() {
    parseStatementAndTest("""
    do {
      try expression
      statements
    } catch pattern1 {
      statements
    } catch pattern2 where condition {
      statements
    }
    """,
    """
    do {
    try expression
    statements
    } catch pattern1 {
    statements
    } catch pattern2 where condition {
    statements
    }
    """)
  }

  func testCatchPatternMatching() {
    // test cases for issue #69: https://github.com/yanagiba/swift-ast/issues/69
    parseStatementAndTest("""
    do {
      try expression
    } catch VendingMachineError.insufficientFunds(3) {
      statements
    } catch VendingMachineError.insufficientFunds(let coinsNeeded) {
      statements
    }
    """,
    """
    do {
    try expression
    } catch VendingMachineError.insufficientFunds(3) {
    statements
    } catch VendingMachineError.insufficientFunds(let coinsNeeded) {
    statements
    }
    """)

    // test cases for issue #75: https://github.com/yanagiba/swift-ast/issues/75
    parseStatementAndTest("""
    do {
      try expression
    } catch someErr.woops {
      statements
    } catch is someErr {
      statements
    }
    """,
    """
    do {
    try expression
    } catch someErr.woops {
    statements
    } catch is someErr {
    statements
    }
    """)
  }

  func testSourceRange() {
    parseStatementAndTest("do { try foo() }", "do {\ntry foo()\n}", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 17))
    })
    parseStatementAndTest(
      "do { try foo() } catch { print(\"bar\") }",
      """
      do {
      try foo()
      } catch {
      print(\"bar\")
      }
      """,
      testClosure: { stmt in
        XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 40))
      }
    )
  }

  static var allTests = [
    ("testNoCatch", testNoCatch),
    ("testCatchAll", testCatchAll),
    ("testCatchPattern", testCatchPattern),
    ("testCatchWhere", testCatchWhere),
    ("testCatchPatternAndWhere", testCatchPatternAndWhere),
    ("testMultipleCatches", testMultipleCatches),
    ("testCatchPatternMatching", testCatchPatternMatching),
    ("testSourceRange", testSourceRange),
  ]
}
