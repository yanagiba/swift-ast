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

class ParserInitializerExpressionTests: XCTestCase {
  func testInitExpression() {
    parseExpressionAndTest("foo.init", "foo.init", testClosure: { expr in
      guard let initExpr = expr as? InitializerExpression else {
        XCTFail("Failed in getting an initializer expression")
        return
      }

      XCTAssertTrue(initExpr.postfixExpression is IdentifierExpression)
      XCTAssertTrue(initExpr.argumentNames.isEmpty)
    })
  }

  func testArgumentName() {
    parseExpressionAndTest("foo.init(bar:)", "foo.init(bar:)", testClosure: { expr in
      guard let initExpr = expr as? InitializerExpression else {
        XCTFail("Failed in getting an initializer expression")
        return
      }

      XCTAssertTrue(initExpr.postfixExpression is IdentifierExpression)
      ASTTextEqual(initExpr.argumentNames, ["bar"])
    })
  }

  func testUnderscoreAsArgumentName() {
    parseExpressionAndTest("foo.init(_:)", "foo.init(_:)", testClosure: { expr in
      guard let initExpr = expr as? InitializerExpression else {
        XCTFail("Failed in getting an initializer expression")
        return
      }

      XCTAssertTrue(initExpr.postfixExpression is IdentifierExpression)
      ASTTextEqual(initExpr.argumentNames, ["_"])
    })
  }

  func testMultipleArgumentNames() {
    parseExpressionAndTest("foo . init  (  a  :b   :    c:)", "foo.init(a:b:c:)", testClosure: { expr in
      guard let initExpr = expr as? InitializerExpression else {
        XCTFail("Failed in getting an initializer expression")
        return
      }

      XCTAssertTrue(initExpr.postfixExpression is IdentifierExpression)
      ASTTextEqual(initExpr.argumentNames, ["a", "b", "c"])
    })
  }

  func testNestedInitExpression() {
    parseExpressionAndTest("foo.init(x:).init(y:)", "foo.init(x:).init(y:)", testClosure: { expr in
      guard let outterExpr = expr as? InitializerExpression else {
        XCTFail("Failed in getting an initializer expression")
        return
      }

      guard let innerExpr = outterExpr.postfixExpression as? InitializerExpression else {
        XCTFail("Failed in getting an initializer expression as inner expr")
        return
      }

      ASTTextEqual(outterExpr.argumentNames, ["y"])
      ASTTextEqual(innerExpr.argumentNames, ["x"])
    })
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo.init", 9),
      ("foo.init(bar:)", 15),
      ("foo.init(a:b:c:)", 17),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testInitExpression", testInitExpression),
    ("testArgumentName", testArgumentName),
    ("testUnderscoreAsArgumentName", testUnderscoreAsArgumentName),
    ("testMultipleArgumentNames", testMultipleArgumentNames),
    ("testNestedInitExpression", testNestedInitExpression),
    ("testSourceRange", testSourceRange),
  ]
}
