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

class ParserSuperclassExpressionTests: XCTestCase {
  func testSuperclassMethodExpression() {
    parseExpressionAndTest("super.foo", "super.foo", testClosure: { expr in
      guard
        let superExpr = expr as? SuperclassExpression,
        case .method(let name) = superExpr.kind,
        name.isSyntacticallyEqual(to: .name("foo"))
      else {
        XCTFail("Failed in getting a superclass expression")
        return
      }
    })
  }

  func testSuperclassSubscriptExpression() {
    parseExpressionAndTest("super[0]", "super[0]", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .subscript(let args) = superExpr.kind,
        args.count == 1,
        let literalExpr = args[0].expression as? LiteralExpression,
        case .integer(let i, _) = literalExpr.kind,
        i == 0
      else {
        XCTFail("Failed in getting a superclass expression")
        return
      }
      XCTAssertNil(args[0].identifier)
    })
  }

  func testSuperclassSubscriptExprWithExprList() {
    parseExpressionAndTest("super[0, 1, 5]", "super[0, 1, 5]", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .subscript(let args) = superExpr.kind,
        args.count == 3
      else {
        XCTFail("Failed in getting a superclass expression")
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

  func testSuperclassSubscriptExprWithVariables() {
    parseExpressionAndTest("super [ foo,   0, bar,1, 5 ] ", "super[foo, 0, bar, 1, 5]", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .subscript(let args) = superExpr.kind,
        args.count == 5
      else {
        XCTFail("Failed in getting a superclass expression")
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

  func testSuperclassSubscriptArgumentWithIdentifier() {
    // https://github.com/yanagiba/swift-ast/issues/38
    parseExpressionAndTest("super[bar: 0]", "super[bar: 0]", testClosure: { expr in
      XCTAssertTrue(expr is SuperclassExpression)
    })
    parseExpressionAndTest("super[a: 0, b: 1, c: 2]", "super[a: 0, b: 1, c: 2]")
    parseExpressionAndTest("super [bar: n+1]", "super[bar: n + 1]")
    parseExpressionAndTest("super [bar: bar()]", "super[bar: bar()]")
    parseExpressionAndTest("super [bar: try bar()]", "super[bar: try bar()]")
  }

  func testSuperclassInitializerExpression() {
    parseExpressionAndTest("super.init", "super.init", testClosure: { expr in
      guard let superExpr = expr as? SuperclassExpression,
        case .initializer = superExpr.kind else {
        XCTFail("Failed in getting a superclass expression")
        return
      }
    })
  }

  func testArgumentListOnSameLine() {
    parseExpressionAndTest("super\n[foo]", "", errorClosure: { error in
      // :)
    })
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("super.foo", 10),
      ("super.init", 11),
      ("super[foo]", 11),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testSuperclassMethodExpression", testSuperclassMethodExpression),
    ("testSuperclassSubscriptExpression", testSuperclassSubscriptExpression),
    ("testSuperclassSubscriptExprWithExprList", testSuperclassSubscriptExprWithExprList),
    ("testSuperclassSubscriptExprWithVariables", testSuperclassSubscriptExprWithVariables),
    ("testSuperclassSubscriptArgumentWithIdentifier", testSuperclassSubscriptArgumentWithIdentifier),
    ("testSuperclassInitializerExpression", testSuperclassInitializerExpression),
    ("testArgumentListOnSameLine", testArgumentListOnSameLine),
    ("testSourceRange", testSourceRange),
  ]
}
