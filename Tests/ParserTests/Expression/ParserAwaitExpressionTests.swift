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

class ParserAwaitExpressionTests: XCTestCase {
  func testAwaitExpression() {
    parseExpressionAndTest("await foo()", "await foo()", testClosure: { expr in
      guard let awaitExpr = expr as? AwaitExpression else {
        XCTFail("Failed in getting an await expression.")
        return
      }
      XCTAssertTrue(awaitExpr.expression is FunctionCallExpression)
      XCTAssertEqual(awaitExpr.expression.textDescription, "foo()")
    })
  }

  func testAwaitIdentifier() {
    parseExpressionAndTest("await someValue", "await someValue", testClosure: { expr in
      guard let awaitExpr = expr as? AwaitExpression else {
        XCTFail("Failed in getting an await expression.")
        return
      }
      XCTAssertTrue(awaitExpr.expression is IdentifierExpression)
    })
  }

  func testTryAwaitExpression() {
    parseExpressionAndTest("try await foo()", "try await foo()", testClosure: { expr in
      guard let tryExpr = expr as? TryOperatorExpression else {
        XCTFail("Failed in getting a try expression.")
        return
      }
      if case .try(let innerExpr) = tryExpr.kind {
        XCTAssertTrue(innerExpr is AwaitExpression)
      } else {
        XCTFail("Expected .try kind.")
      }
    })
  }

  func testTryForceAwaitExpression() {
    parseExpressionAndTest("try! await foo()", "try! await foo()", testClosure: { expr in
      guard let tryExpr = expr as? TryOperatorExpression else {
        XCTFail("Failed in getting a try expression.")
        return
      }
      if case .forced(let innerExpr) = tryExpr.kind {
        XCTAssertTrue(innerExpr is AwaitExpression)
      } else {
        XCTFail("Expected .forced kind.")
      }
    })
  }

  func testTryOptionalAwaitExpression() {
    parseExpressionAndTest("try? await foo()", "try? await foo()", testClosure: { expr in
      guard let tryExpr = expr as? TryOperatorExpression else {
        XCTFail("Failed in getting a try expression.")
        return
      }
      if case .optional(let innerExpr) = tryExpr.kind {
        XCTAssertTrue(innerExpr is AwaitExpression)
      } else {
        XCTFail("Expected .optional kind.")
      }
    })
  }

  func testAwaitMemberAccess() {
    parseExpressionAndTest("await obj.method()", "await obj.method()")
  }

  func testAwaitInAssignment() {
    parseStatementAndTest("let x = await foo()", "let x = await foo()")
  }

  func testAwaitSubscriptAccess() {
    parseExpressionAndTest("await array[0]", "await array[0]", testClosure: { expr in
      guard let awaitExpr = expr as? AwaitExpression else {
        XCTFail("Failed in getting an await expression.")
        return
      }
      XCTAssertTrue(awaitExpr.expression is SubscriptExpression)
    })
  }

  func testAwaitOptionalChaining() {
    parseExpressionAndTest("await obj?.method()", "await obj?.method()", testClosure: { expr in
      guard let awaitExpr = expr as? AwaitExpression else {
        XCTFail("Failed in getting an await expression.")
        return
      }
      XCTAssertEqual(awaitExpr.expression.textDescription, "obj?.method()")
    })
  }

  func testAwaitForcedValue() {
    parseExpressionAndTest("await obj!.method()", "await obj!.method()", testClosure: { expr in
      guard let awaitExpr = expr as? AwaitExpression else {
        XCTFail("Failed in getting an await expression.")
        return
      }
      XCTAssertEqual(awaitExpr.expression.textDescription, "obj!.method()")
    })
  }

  func testAwaitWithArguments() {
    parseExpressionAndTest("await fetch(url: u, timeout: 30)", "await fetch(url: u, timeout: 30)", testClosure: { expr in
      guard let awaitExpr = expr as? AwaitExpression else {
        XCTFail("Failed in getting an await expression.")
        return
      }
      XCTAssertTrue(awaitExpr.expression is FunctionCallExpression)
    })
  }

  func testAwaitChainedMethodCalls() {
    parseExpressionAndTest("await session.data(from: url).0", "await session.data(from: url).0")
  }

  func testAwaitInReturnStatement() {
    parseStatementAndTest("return await fetchData()", "return await fetchData()")
  }

  func testAwaitWithClosure() {
    parseExpressionAndTest("await withCheckedContinuation { c in }", "await withCheckedContinuation { c in }")
  }
}
