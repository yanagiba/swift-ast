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

class ParserPrefixOperatorExpressionTests: XCTestCase {
  func testPrefixOperator() {
    let testOps = [
      // regular operators
      "!",
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
      // dot operators
      "..",
      "...",
      ".......................",
      "../",
      "...++",
      "..--"
    ]
    for testOp in testOps {
      let testCode = "\(testOp)foo"

      parseExpressionAndTest(testCode, testCode, testClosure: { expr in
        guard let prefixOperator = expr as? PrefixOperatorExpression else {
          XCTFail("Failed in getting a prefix operator expression")
          return
        }
        XCTAssertEqual(prefixOperator.prefixOperator, testOp)
        XCTAssertTrue(prefixOperator.postfixExpression is IdentifierExpression)
      })
    }
  }

  func testPostfixExpressionAsImplicitMemberExpression() {
    // https://github.com/yanagiba/swift-lint/issues/37
    let testOps = [
      // regular operators
      "!",
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
      // dot operators
      // "..",
      // "...",
      // ".......................",
      // "../",
      // "...++",
      // "..--"
      // TODO: RS: need more understanding towards dot operators
      //           followed by an implicit member expression
    ]
    for testOp in testOps {
      let testCode = "\(testOp).pi"

      parseExpressionAndTest(testCode, testCode, testClosure: { expr in
        guard let prefixOperator = expr as? PrefixOperatorExpression else {
          XCTFail("Failed in getting a prefix operator expression")
          return
        }
        XCTAssertEqual(prefixOperator.prefixOperator, testOp)
        guard let implicitMemberExpr =
          prefixOperator.postfixExpression as? ImplicitMemberExpression
        else {
          XCTFail("Failed in getting an implicit member expression.")
          return
        }
        ASTTextEqual(implicitMemberExpr.identifier, "pi")
      })
    }
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("/foo", 5),
      ("<>foo", 6),
      ("...foo", 7),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testPrefixOperator", testPrefixOperator),
    ("testPostfixExpressionAsImplicitMemberExpression",
      testPostfixExpressionAsImplicitMemberExpression),
    ("testSourceRange", testSourceRange),
  ]
}
