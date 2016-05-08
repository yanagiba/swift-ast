/*
   Copyright 2016 Ryuichi Saito, LLC

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

@testable import parser
@testable import ast

class ParsingExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseIdentifierExpression() {
    parser.setupTestCode("foo")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
  }

  func testParseLiteralExpression() {
    let testLiteralExpressions = [
      "nil",
      "1",
      "1.23",
      "\"foo\"",
      "\"\\(1 + 2)\"",
      "true",
      "[1, 2, 3]",
      "[1: true, 2: false, 3: true, 4: false]",
      "__FILE__"
    ]
    for testLiteral in testLiteralExpressions {
      parser.setupTestCode(testLiteral)
      guard let expr = try? parser.parseExpression() else {
        XCTFail("Failed in getting an expression.")
        return
      }
      guard expr is LiteralExpression else {
        XCTFail("Failed in getting a literal expression.")
        return
      }
    }
  }

  func testParseSelfExpression() {
    let testLiteralExpressions = [
      "self",
      "self.foo",
      "self[0, 1]",
      "self.init"
    ]
    for testLiteral in testLiteralExpressions {
      parser.setupTestCode(testLiteral)
      guard let expr = try? parser.parseExpression() else {
        XCTFail("Failed in getting an expression.")
        return
      }
      guard expr is SelfExpression else {
        XCTFail("Failed in getting a self expression.")
        return
      }
    }
  }

  func testParseSuperclassExpression() {
    let testLiteralExpressions = [
      "super.foo",
      "super[0, 1]",
      "super.init"
    ]
    for testLiteral in testLiteralExpressions {
      parser.setupTestCode(testLiteral)
      guard let expr = try? parser.parseExpression() else {
        XCTFail("Failed in getting an expression.")
        return
      }
      guard expr is SuperclassExpression else {
        XCTFail("Failed in getting a superclass expression.")
        return
      }
    }
  }

  func testParseClosureExpression() {
    parser.setupTestCode("{ $0 > $1 }")
    /*
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is ClosureExpression else {
      XCTFail("Failed in getting a closure expression.")
      return
    }
    */
  }

  func testParseImplicitMemberExpression() {
    parser.setupTestCode(".foo")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is ImplicitMemberExpression else {
      XCTFail("Failed in getting an implicit member expression.")
      return
    }
  }

  func testParseParenthesizedExpression() {
    parser.setupTestCode("( _, foo: 0, bar: 2.3) ")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is ParenthesizedExpression else {
      XCTFail("Failed in getting a parenthesized expression.")
      return
    }
  }

  func testParseWildcardExpression() {
    parser.setupTestCode("_ ")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is WildcardExpression else {
      XCTFail("Failed in getting a wildcard expression.")
      return
    }
  }

  func testParsePostfixOperatorExpression() {
    parser.setupTestCode("happy^-^")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is PostfixOperatorExpression else {
      XCTFail("Failed in getting a postfix operator expression.")
      return
    }
  }

  func testParseFunctionCallExpression() {
    parser.setupTestCode("foo(x, y: 1, z: true)")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is FunctionCallExpression else {
      XCTFail("Failed in getting a function call expression.")
      return
    }
  }

  func testParseExplicitMemberExpression() {
    let testMembers = ["0", "1", "foo", "bar"]
    for testMember in testMembers {
      parser.setupTestCode("foo.\(testMember)")
      guard let expr = try? parser.parseExpression() else {
        XCTFail("Failed in getting an expression.")
        return
      }
      guard expr is ExplicitMemberExpression else {
        XCTFail("Failed in getting an explicit member expression.")
        return
      }
    }
  }

  func testParseInitializerExpression() {
    parser.setupTestCode("foo.init")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is InitializerExpression else {
      XCTFail("Failed in getting an initializer expression.")
      return
    }
  }

  func testParsePostfixSelfExpression() {
    parser.setupTestCode("foo.self")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is PostfixSelfExpression else {
      XCTFail("Failed in getting a postfix self expression.")
      return
    }
  }

  func testParseDynamicTypeExpression() {
    parser.setupTestCode("foo.dynamicType")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is DynamicTypeExpression else {
      XCTFail("Failed in getting a dynamic type expression.")
      return
    }
  }

  func testParseSubscriptExpression() {
    parser.setupTestCode("foo[0, 1, 5]")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is SubscriptExpression else {
      XCTFail("Failed in getting a subscript expression.")
      return
    }
  }

  func testParseForcedValueExpression() {
    parser.setupTestCode("foo!")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is ForcedValueExpression else {
      XCTFail("Failed in getting a forced value expression.")
      return
    }
  }

  func testParseOptionalChainingExpression() {
    parser.setupTestCode("foo?")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is OptionalChainingExpression else {
      XCTFail("Failed in getting an optional chaining expression.")
      return
    }
  }

  func testParsePrefixOperatorExpression() {
    parser.setupTestCode("^-^happy")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is PrefixOperatorExpression else {
      XCTFail("Failed in getting a prefix operator expression.")
      return
    }
  }

  func testParseInoutExpression() {
    parser.setupTestCode("&a")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is InOutExpression else {
      XCTFail("Failed in getting an in-out expression.")
      return
    }
  }

  func testParseTryOperatorExpression() {
    parser.setupTestCode("try foo")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is TryOperatorExpression else {
      XCTFail("Failed in getting a try operator expression.")
      return
    }
  }

  func testParseBinaryOperatorExpression() {
    parser.setupTestCode("foo == bar")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is BinaryOperatorExpression else {
      XCTFail("Failed in getting a binary operator expression.")
      return
    }
  }

  func testParseAssignmentOperatorExpression() {
    parser.setupTestCode("a = 1")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is AssignmentOperatorExpression else {
      XCTFail("Failed in getting an assignment operator expression.")
      return
    }
  }

  func testParseTernaryConditionalOperatorExpression() {
    parser.setupTestCode("a ? b : c")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }
    guard expr is TernaryConditionalOperatorExpression else {
      XCTFail("Failed in getting a ternary conditional operator expression.")
      return
    }
  }

  func testParseTypeCastingOperatorExpression() {
    let testTypeCasts = [
      "is",
      "as",
      "as?",
      "as!"
    ]
    for testTypeCast in testTypeCasts {
      parser.setupTestCode("foo \(testTypeCast) bar")
      guard let expr = try? parser.parseExpression() else {
        XCTFail("Failed in getting an expression.")
        return
      }
      guard expr is TypeCastingOperatorExpression else {
        XCTFail("Failed in getting a type-casting operator expression.")
        return
      }
    }
  }

  func testParseBinaryExpression() {
    parser.setupTestCode("1 + 2 * 3 - 4")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting an expression.")
      return
    }

    guard let biExpr1 = expr as? BinaryOperatorExpression else {
      XCTFail("Failed in getting a binary operator expression.")
      return
    }
    XCTAssertEqual(biExpr1.binaryOperator, "-")
    XCTAssertTrue(biExpr1.rightExpression is IntegerLiteralExpression)

    guard let biExpr2 = biExpr1.leftExpression as? BinaryOperatorExpression else {
      XCTFail("Failed in getting a binary operator expression.")
      return
    }
    XCTAssertEqual(biExpr2.binaryOperator, "*")
    XCTAssertTrue(biExpr2.rightExpression is IntegerLiteralExpression)

    guard let biExpr3 = biExpr2.leftExpression as? BinaryOperatorExpression else {
      XCTFail("Failed in getting a binary operator expression.")
      return
    }
    XCTAssertEqual(biExpr3.binaryOperator, "+")
    XCTAssertTrue(biExpr3.leftExpression is IntegerLiteralExpression)
    XCTAssertTrue(biExpr3.rightExpression is IntegerLiteralExpression)
  }
}
