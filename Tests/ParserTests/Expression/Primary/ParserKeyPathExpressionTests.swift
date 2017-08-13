/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserKeyPathExpressionTests: XCTestCase {
  func testOneComponent() {
    parseExpressionAndTest("\\.foo", "\\.foo", testClosure: { expr in
      guard let keyPathExpr = expr as? KeyPathExpression else {
        XCTFail("Failed in getting a key path expression")
        return
      }
      XCTAssertNil(keyPathExpr.type)
      XCTAssertEqual(keyPathExpr.components.count, 1)
      XCTAssertEqual(keyPathExpr.components[0], "foo")
    })
  }

  func testMultipleComponents() {
    parseExpressionAndTest("\\.foo.bar.a.b.c", "\\.foo.bar.a.b.c", testClosure: { expr in
      guard let keyPathExpr = expr as? KeyPathExpression else {
        XCTFail("Failed in getting a key path expression")
        return
      }
      XCTAssertNil(keyPathExpr.type)
      XCTAssertEqual(keyPathExpr.components.count, 5)
      XCTAssertEqual(keyPathExpr.components[0], "foo")
      XCTAssertEqual(keyPathExpr.components[1], "bar")
      XCTAssertEqual(keyPathExpr.components[2], "a")
      XCTAssertEqual(keyPathExpr.components[3], "b")
      XCTAssertEqual(keyPathExpr.components[4], "c")
    })
  }

  func testType() {
    parseExpressionAndTest("\\foo.bar", "\\foo.bar", testClosure: { expr in
      guard let keyPathExpr = expr as? KeyPathExpression,
        let typeIdentifier = keyPathExpr.type as? TypeIdentifier else {
        XCTFail("Failed in getting a key path expression")
        return
      }

      XCTAssertEqual(typeIdentifier.names.count, 1)
      XCTAssertEqual(typeIdentifier.names[0].name, "foo")
      XCTAssertNil(typeIdentifier.names[0].genericArgumentClause)
      XCTAssertEqual(keyPathExpr.components.count, 1)
      XCTAssertEqual(keyPathExpr.components[0], "bar")
    })
    parseExpressionAndTest("\\foo.bar.a.b.c", "\\foo.bar.a.b.c", testClosure: { expr in
      guard let keyPathExpr = expr as? KeyPathExpression,
        let typeIdentifier = keyPathExpr.type as? TypeIdentifier else {
        XCTFail("Failed in getting a key path expression")
        return
      }

      XCTAssertEqual(typeIdentifier.names.count, 1)
      XCTAssertEqual(typeIdentifier.names[0].name, "foo")
      XCTAssertNil(typeIdentifier.names[0].genericArgumentClause)
      XCTAssertEqual(keyPathExpr.components.count, 4)
      XCTAssertEqual(keyPathExpr.components[0], "bar")
      XCTAssertEqual(keyPathExpr.components[1], "a")
      XCTAssertEqual(keyPathExpr.components[2], "b")
      XCTAssertEqual(keyPathExpr.components[3], "c")
    })
  }

  func testSourceRange() {
    parseExpressionAndTest("\\.foo", "\\.foo", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 6))
    })
  }

  static var allTests = [
    ("testOneComponent", testOneComponent),
    ("testMultipleComponents", testMultipleComponents),
    ("testType", testType),
    ("testSourceRange", testSourceRange),
  ]
}
