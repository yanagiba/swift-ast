/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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
      ASTTextEqual(keyPathExpr.components[0].0, "foo")
      XCTAssertTrue(keyPathExpr.components[0].1.isEmpty)
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
      ASTTextEqual(keyPathExpr.components[0].0, "foo")
      XCTAssertTrue(keyPathExpr.components[0].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[1].0, "bar")
      XCTAssertTrue(keyPathExpr.components[1].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[2].0, "a")
      XCTAssertTrue(keyPathExpr.components[2].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[3].0, "b")
      XCTAssertTrue(keyPathExpr.components[3].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[4].0, "c")
      XCTAssertTrue(keyPathExpr.components[4].1.isEmpty)
    })
  }

  func testComponentsWithPostfixes() { // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    parseExpressionAndTest(
      "\\.?.!.[foo, bar].a?.b!.c[foo, bar].?!?!.![x]!?[y][z]!",
      "\\.?.!.[foo, bar].a?.b!.c[foo, bar].?!?!.![x]!?[y][z]!",
      testClosure: { expr in

      guard let keyPathExpr = expr as? KeyPathExpression else {
        XCTFail("Failed in getting a key path expression")
        return
      }
      XCTAssertNil(keyPathExpr.type)
      XCTAssertEqual(keyPathExpr.components.count, 8)

      XCTAssertNil(keyPathExpr.components[0].0)
      let postfixes0 = keyPathExpr.components[0].1
      XCTAssertEqual(postfixes0.count, 1)
      guard case .question = postfixes0[0] else {
        XCTFail("Failed in getting a question postfix for keypath expression component 0.")
        return
      }

      XCTAssertNil(keyPathExpr.components[1].0)
      let postfixes1 = keyPathExpr.components[1].1
      XCTAssertEqual(postfixes1.count, 1)
      guard case .exclaim = postfixes1[0] else {
        XCTFail("Failed in getting an exclaim postfix for keypath expression component 1.")
        return
      }

      XCTAssertNil(keyPathExpr.components[2].0)
      let postfixes2 = keyPathExpr.components[2].1
      XCTAssertEqual(postfixes2.count, 1)
      guard case .subscript(let arg2) = postfixes2[0], arg2.count == 2 else {
        XCTFail("Failed in getting a subscript postfix for keypath expression component 2.")
        return
      }

      ASTTextEqual(keyPathExpr.components[3].0, "a")
      let postfixes3 = keyPathExpr.components[3].1
      XCTAssertEqual(postfixes3.count, 1)
      guard case .question = postfixes3[0] else {
        XCTFail("Failed in getting a question postfix for keypath expression component 3.")
        return
      }

      ASTTextEqual(keyPathExpr.components[4].0, "b")
      let postfixes4 = keyPathExpr.components[4].1
      XCTAssertEqual(postfixes4.count, 1)
      guard case .exclaim = postfixes4[0] else {
        XCTFail("Failed in getting an exclaim postfix for keypath expression component 4.")
        return
      }

      ASTTextEqual(keyPathExpr.components[5].0, "c")
      let postfixes5 = keyPathExpr.components[5].1
      XCTAssertEqual(postfixes5.count, 1)
      guard case .subscript(let arg5) = postfixes5[0], arg5.count == 2 else {
        XCTFail("Failed in getting a subscript postfix for keypath expression component 5.")
        return
      }

      XCTAssertNil(keyPathExpr.components[6].0)
      let postfixes6 = keyPathExpr.components[6].1
      XCTAssertEqual(postfixes6.count, 4)
      guard
        case .question = postfixes6[0],
        case .exclaim = postfixes6[1],
        case .question = postfixes6[2],
        case .exclaim = postfixes6[3]
      else {
        XCTFail("Failed in getting mixed postfixes for keypath expression component 6.")
        return
      }

      XCTAssertNil(keyPathExpr.components[7].0)
      let postfixes7 = keyPathExpr.components[7].1
      XCTAssertEqual(postfixes7.count, 7)
      guard
        case .exclaim = postfixes7[0],
        case .subscript = postfixes7[1],
        case .exclaim = postfixes7[2],
        case .question = postfixes7[3],
        case .subscript = postfixes7[4],
        case .subscript = postfixes7[5],
        case .exclaim = postfixes7[6]
      else {
        XCTFail("Failed in getting mixed postfixes for keypath expression component 7.")
        return
      }
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
      ASTTextEqual(typeIdentifier.names[0].name, "foo")
      XCTAssertNil(typeIdentifier.names[0].genericArgumentClause)
      XCTAssertEqual(keyPathExpr.components.count, 1)
      ASTTextEqual(keyPathExpr.components[0].0, "bar")
      XCTAssertTrue(keyPathExpr.components[0].1.isEmpty)
    })
    parseExpressionAndTest("\\foo.bar.a.b.c", "\\foo.bar.a.b.c", testClosure: { expr in
      guard let keyPathExpr = expr as? KeyPathExpression,
        let typeIdentifier = keyPathExpr.type as? TypeIdentifier else {
        XCTFail("Failed in getting a key path expression")
        return
      }

      XCTAssertEqual(typeIdentifier.names.count, 1)
      ASTTextEqual(typeIdentifier.names[0].name, "foo")
      XCTAssertNil(typeIdentifier.names[0].genericArgumentClause)
      XCTAssertEqual(keyPathExpr.components.count, 4)
      ASTTextEqual(keyPathExpr.components[0].0, "bar")
      XCTAssertTrue(keyPathExpr.components[0].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[1].0, "a")
      XCTAssertTrue(keyPathExpr.components[1].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[2].0, "b")
      XCTAssertTrue(keyPathExpr.components[2].1.isEmpty)
      ASTTextEqual(keyPathExpr.components[3].0, "c")
      XCTAssertTrue(keyPathExpr.components[3].1.isEmpty)
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
    ("testComponentsWithPostfixes", testComponentsWithPostfixes),
    ("testType", testType),
    ("testSourceRange", testSourceRange),
  ]
}
