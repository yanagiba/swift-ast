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

class ParserBinaryOperatorExpressionTests: XCTestCase {
  func testBinaryOperators() {
    let testOps = [
      // regular operators
      "/",
      "-",
      "+",
      "--",
      "++",
      "+=",
      "=-",
      "==",
      "!*",
      "*<",
      "<>",
      "<!>",
      ">?>?>",
      "&|^~?",
      ">>>!!>>",
      "??",
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]
    for testOp in testOps {
      for space in ["", " ", "     "] {
        let testCode = "foo\(space)\(testOp)\(space)bar"
        let expectedCode = "foo \(testOp) bar"

        parseExpressionAndTest(testCode, expectedCode, testClosure: { expr in
          guard let biOperator = expr as? BinaryOperatorExpression else {
            XCTFail("Failed in getting a binary operator expression")
            return
          }
          XCTAssertEqual(biOperator.binaryOperator, testOp)
          XCTAssertTrue(biOperator.leftExpression is IdentifierExpression)
          XCTAssertTrue(biOperator.rightExpression is IdentifierExpression)
        })
      }
    }
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo / bar", 10),
      ("foo <> bar", 11),
      ("foo ... bar", 12),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testBinaryOperators", testBinaryOperators),
    ("testSourceRange", testSourceRange),
  ]
}
