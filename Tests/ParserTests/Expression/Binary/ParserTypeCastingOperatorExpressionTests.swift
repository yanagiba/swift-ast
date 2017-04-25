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

class ParserTypeCastingOperatorExpressionTests: XCTestCase {
  func testCheck() {
    parseExpressionAndTest("foo is bar", "foo is bar", testClosure: { expr in
      guard let typeCastingOpExpr = expr as? TypeCastingOperatorExpression,
        case let .check(checkExpr, type) = typeCastingOpExpr.kind else {
        XCTFail("Failed in getting a type casting operator expression")
        return
      }

      XCTAssertTrue(checkExpr is IdentifierExpression)
      XCTAssertTrue(type is TypeIdentifier)
    })
  }

  func testCast() {
    parseExpressionAndTest("foo as bar", "foo as bar", testClosure: { expr in
      guard let typeCastingOpExpr = expr as? TypeCastingOperatorExpression,
        case let .cast(castExpr, type) = typeCastingOpExpr.kind else {
        XCTFail("Failed in getting a type casting operator expression")
        return
      }

      XCTAssertTrue(castExpr is IdentifierExpression)
      XCTAssertTrue(type is TypeIdentifier)
    })
  }

  func testForcedCast() {
    parseExpressionAndTest("foo as! bar", "foo as! bar")
  }

  func testOptionalCast() {
    parseExpressionAndTest("foo as? bar", "foo as? bar")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo is bar", 11),
      ("foo as bar", 11),
      ("foo as? bar", 12),
      ("foo as! bar", 12),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testCheck", testCheck),
    ("testCast", testCast),
    ("testForcedCast", testForcedCast),
    ("testOptionalCast", testOptionalCast),
    ("testSourceRange", testSourceRange),
  ]
}
