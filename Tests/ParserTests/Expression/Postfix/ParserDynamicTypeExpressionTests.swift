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

class ParserDynamicTypeExpressionTests: XCTestCase {
  func testDynamicTypeExpressions() {
    parseExpressionAndTest("type(of: foo)", "type(of: foo)", testClosure: { expr in
      XCTAssertTrue(expr is DynamicTypeExpression)
    })
  }

  func testOldSyntax() {
    parseExpressionAndTest("foo.dynamicType", "type(of: foo)")
  }

  func testMixed() {
    parseExpressionAndTest("type(of: foo).dynamicType", "type(of: type(of: foo))")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedString: String, expectedEndColumn: Int)] = [
      ("type(of: foo)", "type(of: foo)", 14),
      ("foo.dynamicType", "type(of: foo)", 16),
      ("type(of: foo).dynamicType", "type(of: type(of: foo))", 26),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.expectedString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testDynamicTypeExpressions", testDynamicTypeExpressions),
    ("testOldSyntax", testOldSyntax),
    ("testMixed", testMixed),
    ("testSourceRange", testSourceRange),
  ]
}
