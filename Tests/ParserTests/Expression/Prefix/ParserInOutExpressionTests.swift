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

class ParserInOutExpressionTests: XCTestCase {
  func testInOut() {
    parseExpressionAndTest("&foo", "&foo", testClosure: { expr in
      guard let inOutExpr = expr as? InOutExpression else {
        XCTFail("Failed in getting an in-out expression")
        return
      }
      ASTTextEqual(inOutExpr.identifier, "foo")
    })
  }

  func testSourceRange() {
    parseExpressionAndTest("&foo", "&foo", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 5))
    })
  }

  static var allTests = [
    ("testInOut", testInOut),
    ("testSourceRange", testSourceRange),
  ]
}
