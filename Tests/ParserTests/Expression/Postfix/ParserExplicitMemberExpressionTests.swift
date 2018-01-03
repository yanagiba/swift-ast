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

class ParserExplicitMemberExpressionTests: XCTestCase {
  func testTupleMember() {
    let testMembers = ["0": 0, "1": 1, "23": 23]
    for (testStr, expectedIndex) in testMembers {
      parseExpressionAndTest("foo.\(testStr)", "foo.\(expectedIndex)", testClosure: { expr in
        guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
          case let .tuple(postfixExpr, index) = explicitMemberExpr.kind else {
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
        case let .namedType(postfixExpr, identifier) = explicitMemberExpr.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      ASTTextEqual(identifier, "someProperty")
    })
  }

  func testGenericArgumentClause() {
    parseExpressionAndTest("foo.bar<a, b, c>", "foo.bar<a, b, c>", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .generic(postfixExpr, identifier, genericArgumentClause) = explicitMemberExpr.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      ASTTextEqual(identifier, "bar")
      XCTAssertEqual(genericArgumentClause.textDescription, "<a, b, c>")
    })
  }

  func testArgumentName() {
    parseExpressionAndTest("foo.bar(a:b:c:)", "foo.bar(a:b:c:)", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .argument(postfixExpr, identifier, argumentNames) = explicitMemberExpr.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      ASTTextEqual(identifier, "bar")
      ASTTextEqual(argumentNames, ["a", "b", "c"])
    })
  }

  func testUnderscoreAsArgumentName() {
    parseExpressionAndTest("foo.bar(_:)", "foo.bar(_:)", testClosure: { expr in
      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .argument(postfixExpr, identifier, argumentNames) = explicitMemberExpr.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertTrue(postfixExpr is IdentifierExpression)
      ASTTextEqual(identifier, "bar")
      ASTTextEqual(argumentNames, ["_"])
    })
  }

  func testNested() {
    parseExpressionAndTest("foo . bar.a< x > \n. 100 . b ( y : ) ", "foo.bar.a<x>.100.b(y:)", testClosure: { expr in
      guard let exprB = expr as? ExplicitMemberExpression,
        case let .argument(postfixExprB, identifierB, argumentNamesB) = exprB.kind else {
        XCTFail("Failed in getting an explicit member expression `foo.bar.a<x>.100.b(y:)`")
        return
      }

      ASTTextEqual(identifierB, "b")
      ASTTextEqual(argumentNamesB, ["y"])

      guard let exprHundred = postfixExprB as? ExplicitMemberExpression,
        case let .tuple(postfixExprHundred, indexHundred) = exprHundred.kind else {
        XCTFail("Failed in getting an explicit member expression `foo.bar.a<x>.100`")
        return
      }

      XCTAssertEqual(indexHundred, 100)

      guard let exprA = postfixExprHundred as? ExplicitMemberExpression,
        case let .generic(postfixExprA, identifierA, genericA) = exprA.kind else {
        XCTFail("Failed in getting an explicit member expression `foo.bar.a<x>`")
        return
      }

      ASTTextEqual(identifierA, "a")
      XCTAssertEqual(genericA.textDescription, "<x>")

      guard let exprBar = postfixExprA as? ExplicitMemberExpression,
        case let .namedType(postfixExprBar, identifierBar) = exprBar.kind else {
        XCTFail("Failed in getting an explicit member expression `foo.bar`")
        return
      }

      ASTTextEqual(identifierBar, "bar")

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

  func testPostfixExpressionAsLiteralExpression() {
    // Address an issue described in @angelolloqui's October 27, 2017 email
    for member in ["float", "a", "abc", "z", "zyx"] {
      let expressionString = "3.\(member)"
      parseExpressionAndTest(expressionString, expressionString, testClosure: { expr in
        guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
          case let .namedType(postfixExpr, identifier) = explicitMemberExpr.kind else {
          XCTFail("Failed in getting an explicit member expression for `\(expressionString)`.")
          return
        }

        XCTAssertTrue(postfixExpr is LiteralExpression)
        ASTTextEqual(identifier, member)
      })
    }
    for member in ["float", "z", "zyx", "abcxyz"] {
      let expressionString = "0x3a.\(member)"
      parseExpressionAndTest(expressionString, expressionString, testClosure: { expr in
        guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
          case let .namedType(postfixExpr, identifier) = explicitMemberExpr.kind else {
          XCTFail("Failed in getting an explicit member expression for `\(expressionString)`.")
          return
        }

        XCTAssertTrue(postfixExpr is LiteralExpression)
        ASTTextEqual(identifier, member)
      })
    }
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo.0", 6),
      ("foo.bar", 8),
      ("foo.bar<a, b, c>", 17),
      ("foo.bar(a:b:c:)", 16),
      ("foo.bar.a<x>.100.b(y:)", 23),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }

    parseExpressionAndTest("foo.0.bar", "foo.0.bar", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 10))

      guard let explicitMemberExpr = expr as? ExplicitMemberExpression,
        case let .namedType(postfixExpr, _) = explicitMemberExpr.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertEqual(postfixExpr.sourceRange, getRange(1, 1, 1, 6))
    })

    parseExpressionAndTest("$0.1.2.3", "$0.1.2.3", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 9))

      guard let explicitMemberExpr3 = expr as? ExplicitMemberExpression,
        case let .tuple(postfixExpr2, _) = explicitMemberExpr3.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertEqual(postfixExpr2.sourceRange, getRange(1, 1, 1, 7))

      guard let explicitMemberExpr2 = postfixExpr2 as? ExplicitMemberExpression,
        case let .tuple(postfixExpr1, _) = explicitMemberExpr2.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }

      XCTAssertEqual(postfixExpr1.sourceRange, getRange(1, 1, 1, 5))
    })
  }

  static var allTests = [
    ("testTupleMember", testTupleMember),
    ("testIdentifier", testIdentifier),
    ("testGenericArgumentClause", testGenericArgumentClause),
    ("testArgumentName", testArgumentName),
    ("testUnderscoreAsArgumentName", testUnderscoreAsArgumentName),
    ("testNested", testNested),
    ("testImplicitParameterName", testImplicitParameterName),
    ("testPostfixExpressionAsLiteralExpression", testPostfixExpressionAsLiteralExpression),
    ("testSourceRange", testSourceRange),
  ]
}
