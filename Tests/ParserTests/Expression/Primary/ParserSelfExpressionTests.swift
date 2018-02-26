/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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
      guard
        let selfExpr = expr as? SelfExpression,
        case .method(let name) = selfExpr.kind,
        name.isSyntacticallyEqual(to: .name("foo"))
      else {
        XCTFail("Failed in getting a self expression")
        return
      }
    })
  }

  func testSelfSubscriptExpression() {
    parseExpressionAndTest("self[0]", "self[0]", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .subscript(let args) = selfExpr.kind,
        args.count == 1,
        let literalExpr = args[0].expression as? LiteralExpression,
        case .integer(let i, _) = literalExpr.kind,
        i == 0
      else {
        XCTFail("Failed in getting a self expression")
        return
      }
      XCTAssertNil(args[0].identifier)
    })
  }

  func testSelfSubscriptExprWithExprList() {
    parseExpressionAndTest("self[0, 1, 5]", "self[0, 1, 5]", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .subscript(let args) = selfExpr.kind,
        args.count == 3
      else {
        XCTFail("Failed in getting a self expression")
        return
      }

      XCTAssertNil(args[0].identifier)
      XCTAssertTrue(args[0].expression is LiteralExpression)
      XCTAssertNil(args[1].identifier)
      XCTAssertTrue(args[1].expression is LiteralExpression)
      XCTAssertNil(args[2].identifier)
      XCTAssertTrue(args[2].expression is LiteralExpression)
    })
  }

  func testSelfSubscriptExprWithVariables() {
    parseExpressionAndTest("self [ foo,   0, bar,1, 5 ] ", "self[foo, 0, bar, 1, 5]", testClosure: { expr in
      guard let selfExpr = expr as? SelfExpression,
        case .subscript(let args) = selfExpr.kind,
        args.count == 5
      else {
        XCTFail("Failed in getting a self expression")
        return
      }

      XCTAssertNil(args[0].identifier)
      XCTAssertTrue(args[0].expression is IdentifierExpression)
      XCTAssertNil(args[1].identifier)
      XCTAssertTrue(args[1].expression is LiteralExpression)
      XCTAssertNil(args[2].identifier)
      XCTAssertTrue(args[2].expression is IdentifierExpression)
      XCTAssertNil(args[3].identifier)
      XCTAssertTrue(args[3].expression is LiteralExpression)
      XCTAssertNil(args[4].identifier)
      XCTAssertTrue(args[4].expression is LiteralExpression)
    })
  }

  func testSelfSubscriptArgumentWithIdentifier() {
    // https://github.com/yanagiba/swift-ast/issues/38
    parseExpressionAndTest("self[bar: 0]", "self[bar: 0]", testClosure: { expr in
      XCTAssertTrue(expr is SelfExpression)
    })
    parseExpressionAndTest("self[a: 0, b: 1, c: 2]", "self[a: 0, b: 1, c: 2]")
    parseExpressionAndTest("self [bar: n+1]", "self[bar: n + 1]")
    parseExpressionAndTest("self [bar: bar()]", "self[bar: bar()]")
    parseExpressionAndTest("self [bar: try bar()]", "self[bar: try bar()]")
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

  func testArgumentListOnSameLine() {
    parseExpressionAndTest("self\n[foo]", "self")
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
    ("testSelfSubscriptArgumentWithIdentifier", testSelfSubscriptArgumentWithIdentifier),
    ("testSelfInitializerExpression", testSelfInitializerExpression),
    ("testArgumentListOnSameLine", testArgumentListOnSameLine),
    ("testSourceRange", testSourceRange),
  ]
}
