/*
   Copyright 2016 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserKeyPathStringExpressionTests: XCTestCase {
  func testKeyPathStringExpression() {
    parseExpressionAndTest("#keyPath(foo)", "#keyPath(foo)", testClosure: { expr in
      guard let keyPathStrExpr = expr as? KeyPathStringExpression else {
        XCTFail("Failed in getting a key path string expression")
        return
      }
      XCTAssertTrue(keyPathStrExpr.expression is IdentifierExpression)
    })
  }

  func testContainsSelfExpression() {
    parseExpressionAndTest("#keyPath   (   self.bar    )", "#keyPath(self.bar)", testClosure: { expr in
      guard let keyPathStrExpr = expr as? KeyPathStringExpression else {
        XCTFail("Failed in getting a key path string expression")
        return
      }
      XCTAssertTrue(keyPathStrExpr.expression is SelfExpression)
    })
  }

  func testSourceRange() {
    parseExpressionAndTest("#keyPath(foo)", "#keyPath(foo)", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 14))
    })
  }

  static var allTests = [
    ("testKeyPathStringExpression", testKeyPathStringExpression),
    ("testContainsSelfExpression", testContainsSelfExpression),
    ("testSourceRange", testSourceRange),
  ]
}
