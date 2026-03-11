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

class ParserSwitchExpressionTests: XCTestCase {
  func testBasicSwitchExpression() {
    parseExpressionAndTest(
      "switch val {\ncase 1:\nfoo\ndefault:\nbar\n}",
      "switch val {\ncase 1:\nfoo\ndefault:\nbar\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 2)
    })
  }

  func testSwitchExpressionDefaultOnly() {
    parseExpressionAndTest(
      "switch x {\ndefault:\nfoo\n}",
      "switch x {\ndefault:\nfoo\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 1)
    })
  }

  func testSwitchExpressionMultipleCases() {
    parseExpressionAndTest(
      "switch x {\ncase 1:\none\ncase 2:\ntwo\ncase 3:\nthree\ndefault:\nother\n}",
      "switch x {\ncase 1:\none\ncase 2:\ntwo\ncase 3:\nthree\ndefault:\nother\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 4)
    })
  }

  func testSwitchExpressionEnumPattern() {
    parseExpressionAndTest(
      "switch direction {\ncase .north:\ngoNorth()\ncase .south:\ngoSouth()\ndefault:\nstop()\n}",
      "switch direction {\ncase .north:\ngoNorth()\ncase .south:\ngoSouth()\ndefault:\nstop()\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 3)
    })
  }

  func testSwitchExpressionWithWhereClause() {
    parseExpressionAndTest(
      "switch value {\ncase let x where x > 0:\npositive\ndefault:\nnonPositive\n}",
      "switch value {\ncase let x where x > 0:\npositive\ndefault:\nnonPositive\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 2)
    })
  }

  func testSwitchExpressionTuplePattern() {
    parseExpressionAndTest(
      "switch point {\ncase (0, 0):\norigin\ncase (_, 0):\nxAxis\ndefault:\nother\n}",
      "switch point {\ncase (0, 0):\norigin\ncase (_, 0):\nxAxis\ndefault:\nother\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 3)
    })
  }

  func testSwitchExpressionMultipleItemsPerCase() {
    parseExpressionAndTest(
      "switch x {\ncase 1, 2, 3:\nsmall\ndefault:\nbig\n}",
      "switch x {\ncase 1, 2, 3:\nsmall\ndefault:\nbig\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 2)
    })
  }

  func testSwitchExpressionMemberAccess() {
    parseExpressionAndTest(
      "switch foo.bar {\ncase 1:\none\ndefault:\nother\n}",
      "switch foo.bar {\ncase 1:\none\ndefault:\nother\n}",
      testClosure: { expr in
      guard let switchExpr = expr as? SwitchExpression else {
        XCTFail("Failed in getting a switch expression")
        return
      }
      XCTAssertEqual(switchExpr.cases.count, 2)
    })
  }
}
