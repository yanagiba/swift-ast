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

class ParserExplicitMemberExpressionTests: XCTestCase {
  func testTupleMember() {
    let testMembers = ["0": 0, "1": 1, "23": 23]
    for (testStr, expectedIndex) in testMembers {
      parseExpressionAndTest("foo.\(testStr)", "foo.\(expectedIndex)", testClosure: { expr in
        guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
          case let .tuple(postfixExpr, index) = explicitMemberExpr else {
          XCTFail("Failed in getting an explicit member expression")
          return
        }

        XCTAssertTrue(postfixExpr is IdentifierExpression)
        XCTAssertEqual(index, expectedIndex)
      })
    }
  }

  func testIdentifier() {
    parseExpressionAndTest("foo.someProperty", "foo.someProperty", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .namedType(postfixExpr, identifier) = explicitMemberExpr else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      XCTAssertEqual(identifier, "someProperty")
    })
  }

  func testGenericArgumentClause() {
    parseExpressionAndTest("foo.bar<a, b, c>", "foo.bar<a, b, c>", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .generic(postfixExpr, identifier, genericArgumentClause) = explicitMemberExpr else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      XCTAssertEqual(identifier, "bar")
      XCTAssertEqual(genericArgumentClause.textDescription, "<a, b, c>")
    })
  }

  func testArgumentName() {
    parseExpressionAndTest("foo.bar(a:b:c:)", "foo.bar(a:b:c:)", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .argument(postfixExpr, identifier, argumentNames) = explicitMemberExpr else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      XCTAssertEqual(identifier, "bar")
      XCTAssertEqual(argumentNames, ["a", "b", "c"])
    })
  }

  func testUnderscoreAsArgumentName() {
    parseExpressionAndTest("foo.bar(_:)", "foo.bar(_:)", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .argument(postfixExpr, identifier, argumentNames) = explicitMemberExpr else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      XCTAssertEqual(identifier, "bar")
      XCTAssertEqual(argumentNames, ["_"])
    })
  }

  func testNested() {
    parseExpressionAndTest("foo . bar.a< x > \n. 100 . b ( y : ) ", "foo.bar.a<x>.100.b(y:)", testClosure: { expr in
      guard let exprB = expr as? ExplicitMemberExpression,
        case let .argument(postfixExprB, identifierB, argumentNamesB) = exprB else {
        XCTFail("Failed in getting an explicit member expression `foo.bar.a<x>.100.b(y:)`")
        return
      }

      XCTAssertEqual(identifierB, "b")
      XCTAssertEqual(argumentNamesB, ["y"])

      guard let exprHundred = postfixExprB as? ExplicitMemberExpression,
        case let .tuple(postfixExprHundred, indexHundred) = exprHundred else {
        XCTFail("Failed in getting an explicit member expression `foo.bar.a<x>.100`")
        return
      }

      XCTAssertEqual(indexHundred, 100)

      guard let exprA = postfixExprHundred as? ExplicitMemberExpression,
        case let .generic(postfixExprA, identifierA, genericA) = exprA else {
        XCTFail("Failed in getting an explicit member expression `foo.bar.a<x>`")
        return
      }

      XCTAssertEqual(identifierA, "a")
      XCTAssertEqual(genericA.textDescription, "<x>")

      guard let exprBar = postfixExprA as? ExplicitMemberExpression,
        case let .namedType(postfixExprBar, identifierBar) = exprBar else {
        XCTFail("Failed in getting an explicit member expression `foo.bar`")
        return
      }

      XCTAssertEqual(identifierBar, "bar")

      XCTAssertTrue(postfixExprBar is IdentifierExpression)
    })
  }

  func testImplicitParameterName() {
    let testMembers = ["0": 0, "1": 1, "23": 23]
    for (testStr, expectedIndex) in testMembers {
      parseExpressionAndTest("$0.\(testStr)", "$0.\(expectedIndex)")
      parseExpressionAndTest("$0.\(testStr).bar", "$0.\(expectedIndex).bar")
      parseExpressionAndTest(
        "$0.\(testStr).\(testStr)",
        "$0.\(expectedIndex).\(expectedIndex)")
      parseExpressionAndTest(
        "$0.\(testStr).\(testStr).\(testStr)",
        "$0.\(expectedIndex).\(expectedIndex).\(expectedIndex)")
    }
  }

  static var allTests = [
    ("testTupleMember", testTupleMember),
    ("testIdentifier", testIdentifier),
    ("testGenericArgumentClause", testGenericArgumentClause),
    ("testArgumentName", testArgumentName),
    ("testUnderscoreAsArgumentName", testUnderscoreAsArgumentName),
    ("testNested", testNested),
    ("testImplicitParameterName", testImplicitParameterName),
  ]
}
