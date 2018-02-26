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

class ParserSelectorExpressionTests: XCTestCase {
  func testSelectorExpression() {
    parseExpressionAndTest("#selector(foo)", "#selector(foo)", testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case .selector(let e) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector expression")
        return
      }
      XCTAssertTrue(e is IdentifierExpression)
    })
  }

  func testContainsSelfExpression() {
    parseExpressionAndTest("#selector   (   self.bar    )", "#selector(self.bar)", testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case .selector(let e) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector expression")
        return
      }
      XCTAssertTrue(e is SelfExpression)
    })
  }

  func testGetterSelector() {
    parseExpressionAndTest("#selector(getter: bar)", "#selector(getter: bar)", testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case .getter(let e) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector expression")
        return
      }
      XCTAssertTrue(e is IdentifierExpression)
    })
  }

  func testSetterSelector() {
    parseExpressionAndTest("#selector(setter: bar)", "#selector(setter: bar)", testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case .setter(let e) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector expression")
        return
      }
      XCTAssertTrue(e is IdentifierExpression)
    })
  }

  func testSelectorForMethods() {
    parseExpressionAndTest(
      "#selector(pillTapped(_:))",
      "#selector(pillTapped(_:))",
      testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case let .selfMember(id, names) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector self-member")
        return
      }
      ASTTextEqual(id, "pillTapped")
      ASTTextEqual(names, ["_"])
    })
    parseExpressionAndTest(
      "#selector(self.pillTapped(_:))",
      "#selector(self.pillTapped(_:))",
      testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case let .selfMember(id, names) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector self-member")
        return
      }
      ASTTextEqual(id, "self.pillTapped")
      ASTTextEqual(names, ["_"])
    })
    parseExpressionAndTest(
      "#selector(SomeClass.doSomething(_:))",
      "#selector(SomeClass.doSomething(_:))",
      testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case .selector(let e) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector expression")
        return
      }
      XCTAssertTrue(e is ExplicitMemberExpression)
    })
    parseExpressionAndTest(
      "#selector(getter: SomeClass.property)",
      "#selector(getter: SomeClass.property)")
    parseExpressionAndTest(
      "#selector(SomeClass.doSomething(_:) as (SomeClass) -> (String) -> Void)",
      "#selector(SomeClass.doSomething(_:) as (SomeClass) -> (String) -> Void)",
      testClosure: { expr in
      guard let selectorExpr = expr as? SelectorExpression,
        case .selector(let e) = selectorExpr.kind else {
        XCTFail("Failed in getting a selector expression")
        return
      }
      XCTAssertTrue(e is TypeCastingOperatorExpression)
    })
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("#selector(foo)", 15),
      ("#selector(self.bar)", 20),
      ("#selector(getter: SomeClass.property)", 38),
      ("#selector(pillTapped(_:))", 26),
      ("#selector(self.pillTapped(_:))", 31),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testSelectorExpression", testSelectorExpression),
    ("testContainsSelfExpression", testContainsSelfExpression),
    ("testGetterSelector", testGetterSelector),
    ("testSetterSelector", testSetterSelector),
    ("testSelectorForMethods", testSelectorForMethods),
    ("testSourceRange", testSourceRange),
  ]
}
