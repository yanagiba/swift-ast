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

class ParserFunctionCallExpressionTests: XCTestCase {
  func testEmptyParameter() {
    parseExpressionAndTest("foo()", "foo()", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      XCTAssertNotNil(funcCallExpr.argumentClause)
      XCTAssertTrue(funcCallExpr.argumentClause?.isEmpty ?? false)
      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testArgumentAsExpression() {
    parseExpressionAndTest("foo(1)", "foo(1)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .expression(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting an expression argument.")
        return
      }
      XCTAssertTrue(argExpr is LiteralExpression)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testArgumentAsNamedExpression() {
    parseExpressionAndTest("foo(a: 1)", "foo(a: 1)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case let .namedExpression(name, argExpr) = arguments[0] else {
        XCTFail("Failed in getting a named expression argument.")
        return
      }
      XCTAssertEqual(name.textDescription, "a")
      XCTAssertTrue(argExpr is LiteralExpression)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testArgumentAsOperator() {
    parseExpressionAndTest("foo(+)", "foo(+)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case let .operator(op) = arguments[0] else {
        XCTFail("Failed in getting an operator argument.")
        return
      }
      XCTAssertEqual(op, "+")

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testOperators() {
    parseExpressionAndTest("foo( +)", "foo(+)")
    parseExpressionAndTest("foo(+ )", "foo(+)")
    parseExpressionAndTest("foo( + )", "foo(+)")
    parseExpressionAndTest("foo(<+>)", "foo(<+>)")
    parseExpressionAndTest("foo(!)", "foo(!)")
    parseExpressionAndTest("foo(....)", "foo(....)")
  }

  func testArgumentAsNamedOperator() {
    parseExpressionAndTest("foo(op: +)", "foo(op: +)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case let .namedOperator(name, op) = arguments[0] else {
        XCTFail("Failed in getting an operator argument.")
        return
      }
      XCTAssertEqual(name.textDescription, "op")
      XCTAssertEqual(op, "+")

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testArgumentsStartWithMinusSign() {
    parseExpressionAndTest(
      "foo(-,op:-,-bar,expr:-bar)",
      "foo(-, op: -, -bar, expr: -bar)",
      testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 4)

      guard case let .operator(op0) = arguments[0], op0 == "-" else {
        XCTFail("Failed in getting an operator argument `-`.")
        return
      }
      guard case let .namedOperator(name1, op1) = arguments[1],
        name1.textDescription == "op", op1 == "-" else
      {
        XCTFail("Failed in getting a named operator argument `op: -`.")
        return
      }
      guard case let .expression(expr2) = arguments[2],
        expr2 is PrefixOperatorExpression, expr2.textDescription == "-bar" else
      {
        XCTFail("Failed in getting an expression argument `-bar`.")
        return
      }
      guard case let .namedExpression(name3, expr3) = arguments[3], name3.textDescription == "expr",
        expr3 is PrefixOperatorExpression, expr3.textDescription == "-bar" else
      {
        XCTFail("Failed in getting an operator argument `expr: -bar`.")
        return
      }

      XCTAssertNil(funcCallExpr.trailingClosure)
    })

    parseExpressionAndTest(
      "min(-data.yMax*0.1, data.yMin)",
      "min(-data.yMax * 0.1, data.yMin)")
  }

  func testArgumentsStartWithExclamation() {
    parseExpressionAndTest("assert(!bytes.isEmpty)", "assert(!bytes.isEmpty)")
  }

  func testMultipleArguments() {
    parseExpressionAndTest("foo( +, a:-,b : b , _)", "foo(+, a: -, b: b, _)")
  }

  func testClosureArgument() {
    parseExpressionAndTest("map({ $0.textDescription })", "map({ $0.textDescription })", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .expression(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting an expression argument.")
        return
      }
      XCTAssertTrue(argExpr is ClosureExpression)
      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testTrailingClosureOneArgument() {
    parseExpressionAndTest("foo(1) { self.foo = $0 }", "foo(1) { self.foo = $0 }", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard let closureExpr = funcCallExpr.trailingClosure else {
        XCTFail("Failed in getting a trailing closure.")
        return
      }
      XCTAssertEqual(closureExpr.textDescription, "{ self.foo = $0 }")
    })
  }

  func testTrailingClosureZeroArgument() {
    parseExpressionAndTest("foo() { self.foo = $0 }", "foo() { self.foo = $0 }", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      XCTAssertNotNil(funcCallExpr.argumentClause)
      XCTAssertTrue(funcCallExpr.argumentClause?.isEmpty ?? false)
      guard let closureExpr = funcCallExpr.trailingClosure else {
        XCTFail("Failed in getting a trailing closure.")
        return
      }
      XCTAssertEqual(closureExpr.textDescription, "{ self.foo = $0 }")
    })
  }

  func testTrailingClosureNoArgumentClause() {
    parseExpressionAndTest("foo { self.foo = $0 }", "foo { self.foo = $0 }", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      XCTAssertNil(funcCallExpr.argumentClause)
      guard let closureExpr = funcCallExpr.trailingClosure else {
        XCTFail("Failed in getting a trailing closure.")
        return
      }
      XCTAssertEqual(closureExpr.textDescription, "{ self.foo = $0 }")
    })
  }

  func testTrailingClosureSameLine() {
    parseExpressionAndTest("foo\n{ self.foo = $0 }", "foo")
  }

  func testDistinguishFromExplicitMemberExpr() {
    // with argument names
    parseExpressionAndTest("foo.bar(x)", "foo.bar(x)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is ExplicitMemberExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .expression(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting an expression argument.")
        return
      }
      XCTAssertTrue(argExpr is IdentifierExpression)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })

    // no argument name
    parseExpressionAndTest("foo.bar()", "foo.bar()", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is ExplicitMemberExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertTrue(arguments.isEmpty)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testMemoryReference() {
    parseExpressionAndTest("foo(&bar)", "foo(&bar)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .memoryReference(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting a memory reference argument.")
        return
      }
      XCTAssertTrue(argExpr is IdentifierExpression)
      XCTAssertEqual(argExpr.textDescription, "bar")

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testNamedMemoryReference() {
    parseExpressionAndTest("foo(a: &A.b)", "foo(a: &A.b)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case let .namedMemoryReference(name, argExpr) = arguments[0] else {
        XCTFail("Failed in getting a named memory reference argument.")
        return
      }
      XCTAssertEqual(name.textDescription, "a")
      XCTAssertTrue(argExpr is ExplicitMemberExpression)
      XCTAssertEqual(argExpr.textDescription, "A.b")

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testArgumentAsFunctionCallExprWithTrailingClosure() {
    parseExpressionAndTest(
      "foo([1,2,3].map { i in i^2 }.joined())",
      "foo([1, 2, 3].map { i in\ni ^ 2\n}.joined())",
      testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .expression(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting an expression argument.")
        return
      }
      XCTAssertTrue(argExpr is FunctionCallExpression)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })

    parseExpressionAndTest(
      "foo([1,2,3].map { i in i^2 })",
      "foo([1, 2, 3].map { i in\ni ^ 2\n})",
      testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .expression(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting an expression argument.")
        return
      }
      XCTAssertTrue(argExpr is FunctionCallExpression)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testArgumentAsEmptyDictionary() {
    parseExpressionAndTest("foo([:])", "foo([:])", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      XCTAssertTrue(funcCallExpr.postfixExpression is IdentifierExpression)
      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)
      guard case .expression(let argExpr) = arguments[0] else {
        XCTFail("Failed in getting an expression argument.")
        return
      }
      XCTAssertTrue(argExpr is LiteralExpression)
      XCTAssertEqual(argExpr.textDescription, "[:]")

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testPostfixExpressionAsLiteralExpression() {
    // https://github.com/yanagiba/swift-lint/issues/37
    parseExpressionAndTest("5.power(of: 2)", "5.power(of: 2)", testClosure: { expr in
      guard let funcCallExpr = expr as? FunctionCallExpression else {
        XCTFail("Failed in getting a function call expression")
        return
      }

      guard let explicitMemberExpr = funcCallExpr.postfixExpression as? ExplicitMemberExpression,
        case let .namedType(postfixExpr, identifier) = explicitMemberExpr.kind else {
        XCTFail("Failed in getting an explicit member expression")
        return
      }
      XCTAssertTrue(postfixExpr is LiteralExpression)
      XCTAssertEqual(identifier.textDescription, "power")

      guard let arguments = funcCallExpr.argumentClause else {
        XCTFail("Failed in getting an argument clause.")
        return
      }
      XCTAssertEqual(arguments.count, 1)

      XCTAssertNil(funcCallExpr.trailingClosure)
    })
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("foo()", 6),
      ("foo(0)", 7),
      ("foo() { self.foo = $0 }", 24),
      ("foo(0) { self.foo = $0 }", 25),
      ("foo { self.foo = $0 }", 22),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testEmptyParameter", testEmptyParameter),
    ("testArgumentAsExpression", testArgumentAsExpression),
    ("testArgumentAsNamedExpression", testArgumentAsNamedExpression),
    ("testArgumentAsOperator", testArgumentAsOperator),
    ("testOperators", testOperators),
    ("testArgumentAsNamedOperator", testArgumentAsNamedOperator),
    ("testArgumentsStartWithMinusSign", testArgumentsStartWithMinusSign),
    ("testArgumentsStartWithExclamation", testArgumentsStartWithExclamation),
    ("testMultipleArguments", testMultipleArguments),
    ("testClosureArgument", testClosureArgument),
    ("testTrailingClosureOneArgument", testTrailingClosureOneArgument),
    ("testTrailingClosureZeroArgument", testTrailingClosureZeroArgument),
    ("testTrailingClosureNoArgumentClause", testTrailingClosureNoArgumentClause),
    ("testTrailingClosureSameLine", testTrailingClosureSameLine),
    ("testDistinguishFromExplicitMemberExpr", testDistinguishFromExplicitMemberExpr),
    ("testMemoryReference", testMemoryReference),
    ("testNamedMemoryReference", testNamedMemoryReference),
    ("testArgumentAsFunctionCallExprWithTrailingClosure", testArgumentAsFunctionCallExprWithTrailingClosure),
    ("testArgumentAsEmptyDictionary", testArgumentAsEmptyDictionary),
    ("testPostfixExpressionAsLiteralExpression", testPostfixExpressionAsLiteralExpression),
    ("testSourceRange", testSourceRange),
  ]
}
