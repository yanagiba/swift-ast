/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class ParserSelfExpressionTests: XCTestCase {
  func testSelfExpression() {
    parseExpressionAndTest("self", "self", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .self = selfExpr.kind else {
        XCTFail("Failed in getting a self expression")
        return
      }
    })
  }

  func testSelfMethodExpression() {
    parseExpressionAndTest("self.foo", "self.foo", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .method(let name) = selfExpr.kind,
        name == "foo" else {
        XCTFail("Failed in getting a self expression")
        return
      }
    })
  }

  func testSelfSubscriptExpression() {
    parseExpressionAndTest("self[0]", "self[0]", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .subscript(let exprs) = selfExpr.kind,
        exprs.count == 1,
        let literalExpr = exprs[0] as? LiteralExpression,
        case .integer(let i, _) = literalExpr.kind,
        i == 0 else {
        XCTFail("Failed in getting a self expression")
        return
      }
    })
  }

  func testSelfSubscriptExprWithExprList() {
    parseExpressionAndTest("self[0, 1, 5]", "self[0, 1, 5]", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .subscript(let exprs) = selfExpr.kind,
        exprs.count == 3 else {
        XCTFail("Failed in getting a self expression")
        return
      }

      XCTAssertTrue(exprs[0] is LiteralExpression)
      XCTAssertTrue(exprs[1] is LiteralExpression)
      XCTAssertTrue(exprs[2] is LiteralExpression)
    })
  }

  func testSelfSubscriptExprWithVariables() {
    parseExpressionAndTest("self [ foo,   0, bar,1, 5 ] ", "self[foo, 0, bar, 1, 5]", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .subscript(let exprs) = selfExpr.kind,
        exprs.count == 5 else {
        XCTFail("Failed in getting a self expression")
        return
      }

      XCTAssertTrue(exprs[0] is IdentifierExpression)
      XCTAssertTrue(exprs[1] is LiteralExpression)
      XCTAssertTrue(exprs[2] is IdentifierExpression)
      XCTAssertTrue(exprs[3] is LiteralExpression)
      XCTAssertTrue(exprs[4] is LiteralExpression)
    })
  }

  func testSelfInitializerExpression() {
    parseExpressionAndTest("self.init", "self.init", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .initializer = selfExpr.kind else {
        XCTFail("Failed in getting a self expression")
        return
      }
    })
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("self", 5),
      ("self.foo", 9),
      ("self.init", 10),
      ("self[foo]", 10),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testSelfExpression", testSelfExpression),
    ("testSelfMethodExpression", testSelfMethodExpression),
    ("testSelfSubscriptExpression", testSelfSubscriptExpression),
    ("testSelfSubscriptExprWithExprList", testSelfSubscriptExprWithExprList),
    ("testSelfSubscriptExprWithVariables", testSelfSubscriptExprWithVariables),
    ("testSelfInitializerExpression", testSelfInitializerExpression),
    ("testSourceRange", testSourceRange),
  ]
}
