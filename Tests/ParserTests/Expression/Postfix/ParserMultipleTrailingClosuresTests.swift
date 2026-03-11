/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

class ParserMultipleTrailingClosuresTests: XCTestCase {
  func testSingleTrailingClosureBackwardCompat() {
    parseExpressionAndTest("foo { }", "foo {}",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertTrue(funcCallExpr.additionalTrailingClosures.isEmpty)
      })
  }

  func testOneAdditionalTrailingClosure() {
    parseExpressionAndTest("foo { a } bar: { b }", "foo { a } bar: { b }",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures.count, 1)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures[0].0.textDescription, "bar")
      })
  }

  func testTwoAdditionalTrailingClosuresWithArgs() {
    parseExpressionAndTest("foo(x) { a } bar: { b } baz: { c }",
      "foo(x) { a } bar: { b } baz: { c }",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertNotNil(funcCallExpr.argumentClause)
        XCTAssertEqual(funcCallExpr.argumentClause?.count, 1)
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures.count, 2)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures[0].0.textDescription, "bar")
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures[1].0.textDescription, "baz")
      })
  }

  func testMacroWithMultipleTrailingClosures() {
    parseExpressionAndTest("#myMacro { a } label: { b }",
      "#myMacro { a } label: { b }",
      testClosure: { expr in
        guard let macroExpr = expr as? MacroExpansionExpression else {
          XCTFail("Failed in getting a macro expansion expression")
          return
        }
        XCTAssertNotNil(macroExpr.trailingClosure)
        XCTAssertEqual(macroExpr.additionalTrailingClosures.count, 1)
        XCTAssertEqual(macroExpr.additionalTrailingClosures[0].0.textDescription, "label")
      })
  }

  func testThreeAdditionalTrailingClosures() {
    parseExpressionAndTest(
      "animate { start } completion: { done } cleanup: { tidy } finally: { end }",
      "animate { start } completion: { done } cleanup: { tidy } finally: { end }",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures.count, 3)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures[0].0.textDescription, "completion")
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures[1].0.textDescription, "cleanup")
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures[2].0.textDescription, "finally")
      })
  }

  func testTrailingClosureWithParameters() {
    parseExpressionAndTest(
      "fetch { data in process(data) } error: { err in handle(err) }",
      "fetch { data in\nprocess(data)\n} error: { err in\nhandle(err)\n}",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures.count, 1)
      })
  }

  func testMethodCallWithMultipleTrailingClosures() {
    parseExpressionAndTest(
      "obj.configure { setup } completion: { done }",
      "obj.configure { setup } completion: { done }",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures.count, 1)
      })
  }

  func testTrailingClosuresWithExplicitArgs() {
    parseExpressionAndTest(
      "foo(a: 1, b: 2) { x } then: { y }",
      "foo(a: 1, b: 2) { x } then: { y }",
      testClosure: { expr in
        guard let funcCallExpr = expr as? FunctionCallExpression else {
          XCTFail("Failed in getting a function call expression")
          return
        }
        XCTAssertEqual(funcCallExpr.argumentClause?.count, 2)
        XCTAssertNotNil(funcCallExpr.trailingClosure)
        XCTAssertEqual(funcCallExpr.additionalTrailingClosures.count, 1)
      })
  }
}
