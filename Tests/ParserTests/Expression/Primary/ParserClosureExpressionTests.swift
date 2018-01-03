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

class ParserClosureExpressionTests: XCTestCase {
  func testEmptyClosure() {
    parseExpressionAndTest("{}", "{}", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      XCTAssertNil(closureExpr.statements)
    })
  }

  func testSingleStatement() {
    parseExpressionAndTest("{ self.present(vc, animated: true) }",
      "{ self.present(vc, animated: true) }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      guard let stmts = closureExpr.statements else {
        XCTFail("Failed in getting statements.")
        return
      }
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is FunctionCallExpression)
      XCTAssertEqual(stmts[0].textDescription, "self.present(vc, animated: true)")
    })
  }

  func testMultipleStatements() {
    parseExpressionAndTest("{ vc.foo = foo;self.present(vc, animated: true) }",
      """
      {
      vc.foo = foo
      self.present(vc, animated: true)
      }
      """,
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      guard let stmts = closureExpr.statements else {
        XCTFail("Failed in getting statements.")
        return
      }
      XCTAssertEqual(stmts.count, 2)
      XCTAssertTrue(stmts[0] is AssignmentOperatorExpression)
      XCTAssertEqual(stmts[0].textDescription, "vc.foo = foo")
      XCTAssertTrue(stmts[1] is FunctionCallExpression)
      XCTAssertEqual(stmts[1].textDescription, "self.present(vc, animated: true)")
    })
  }

  func testOneCaptureItem() {
    parseExpressionAndTest("{ [self] in }", "{ [self] in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature, let captureList = signature.captureList else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(captureList.count, 1)
      XCTAssertNil(captureList[0].specifier)
      XCTAssertTrue(captureList[0].expression is SelfExpression)
      XCTAssertEqual(captureList[0].expression.textDescription, "self")
      XCTAssertNil(signature.parameterClause)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testCaptureItemSpecifier() {
    parseExpressionAndTest("{ [weak self] in }", "{ [weak self] in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature, let captureList = signature.captureList else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(captureList.count, 1)
      XCTAssertEqual(captureList[0].specifier, .weak)
      XCTAssertTrue(captureList[0].expression is SelfExpression)
      XCTAssertEqual(captureList[0].expression.textDescription, "self")

      XCTAssertNil(closureExpr.statements)
    })
    parseExpressionAndTest("{ [unowned self] in }", "{ [unowned self] in }")
    parseExpressionAndTest("{ [unowned(safe) foo] in }", "{ [unowned(safe) foo] in }")
    parseExpressionAndTest("{ [unowned(unsafe) bar] in }", "{ [unowned(unsafe) bar] in }")
  }

  func testMultiCaptureItem() {
    parseExpressionAndTest(
      "{ [weak self, foo, unowned bar, unowned(safe) abc, unowned(unsafe) xyz] in }",
      "{ [weak self, foo, unowned bar, unowned(safe) abc, unowned(unsafe) xyz] in }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature, let captureList = signature.captureList else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(captureList.count, 5)
      XCTAssertEqual(captureList[0].textDescription, "weak self")
      XCTAssertEqual(captureList[1].textDescription, "foo")
      XCTAssertEqual(captureList[2].textDescription, "unowned bar")
      XCTAssertEqual(captureList[3].textDescription, "unowned(safe) abc")
      XCTAssertEqual(captureList[4].textDescription, "unowned(unsafe) xyz")

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testCaptureListAndStatements() {
    parseExpressionAndTest(
      "{ [weak self] in self.present(vc, animated: true) }",
      "{ [weak self] in\nself.present(vc, animated: true)\n}",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression,
        let signature = closureExpr.signature,
        let captureList = signature.captureList,
        let stmts = closureExpr.statements else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      XCTAssertEqual(captureList.count, 1)
      XCTAssertEqual(captureList[0].textDescription, "weak self")

      XCTAssertEqual(stmts.count, 1)
      XCTAssertEqual(stmts[0].textDescription, "self.present(vc, animated: true)")
    })
  }

  func testEmptyParameterList() {
    parseExpressionAndTest("{ () in }", "{ () in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertTrue(params.isEmpty)

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testParamName() {
    parseExpressionAndTest("{ (foo) in }", "{ (foo) in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(params.count, 1)
      XCTAssertEqual(params[0].name.textDescription, "foo")
      XCTAssertNil(params[0].typeAnnotation)
      XCTAssertFalse(params[0].isVarargs)

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testParamNameAndTypeAnnotation() {
    parseExpressionAndTest("{ (foo: Foo) in }", "{ (foo: Foo) in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(params.count, 1)
      XCTAssertEqual(params[0].name.textDescription, "foo")
      XCTAssertEqual(params[0].typeAnnotation?.textDescription, ": Foo")
      XCTAssertFalse(params[0].isVarargs)

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testParamNameAndTypeAnnotationVarargs() {
    parseExpressionAndTest("{ (foo: Foo...) in }", "{ (foo: Foo...) in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(params.count, 1)
      XCTAssertEqual(params[0].name.textDescription, "foo")
      XCTAssertEqual(params[0].typeAnnotation?.textDescription, ": Foo")
      XCTAssertTrue(params[0].isVarargs)

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testMultipleParameters() {
    parseExpressionAndTest(
      "{ (_, b: Bar<B>, c: Foo...) in }",
      "{ (_, b: Bar<B>, c: Foo...) in }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertEqual(params.count, 3)
      XCTAssertEqual(params[0].textDescription, "_")
      XCTAssertEqual(params[1].textDescription, "b: Bar<B>")
      XCTAssertEqual(params[2].textDescription, "c: Foo...")

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testParameterListAndStatements() {
    parseExpressionAndTest(
      "{ (a, b, c) in print(a);print(b);print(c) }",
      """
      { (a, b, c) in
      print(a)
      print(b)
      print(c)
      }
      """,
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression,
        let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause,
        let stmts = closureExpr.statements else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      XCTAssertEqual(params.count, 3)
      XCTAssertEqual(params[0].textDescription, "a")
      XCTAssertEqual(params[1].textDescription, "b")
      XCTAssertEqual(params[2].textDescription, "c")

      XCTAssertEqual(stmts.count, 3)
      XCTAssertEqual(stmts[0].textDescription, "print(a)")
      XCTAssertEqual(stmts[1].textDescription, "print(b)")
      XCTAssertEqual(stmts[2].textDescription, "print(c)")
    })
  }

  func testOneIdentifier() {
    parseExpressionAndTest("{ foo in }", "{ foo in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .identifierList(let ids) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      ASTTextEqual(ids, ["foo"])

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testMultipleIdentifiers() {
    parseExpressionAndTest("{ foo, _, bar in }", "{ foo, _, bar in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .identifierList(let ids) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      ASTTextEqual(ids, ["foo", "_", "bar"])

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
    parseExpressionAndTest("{ _, bar, _, foo in }", "{ _, bar, _, foo in }")
  }

  func testIdentifierListAndStatements() {
    parseExpressionAndTest(
      "{ a, b, c in print(a);print(b);print(c) }",
      """
      { a, b, c in
      print(a)
      print(b)
      print(c)
      }
      """,
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression,
        let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .identifierList(let ids) = clause,
        let stmts = closureExpr.statements else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      XCTAssertEqual(ids.count, 3)
      XCTAssertEqual(ids[0].textDescription, "a")
      XCTAssertEqual(ids[1].textDescription, "b")
      XCTAssertEqual(ids[2].textDescription, "c")

      XCTAssertEqual(stmts.count, 3)
      XCTAssertEqual(stmts[0].textDescription, "print(a)")
      XCTAssertEqual(stmts[1].textDescription, "print(b)")
      XCTAssertEqual(stmts[2].textDescription, "print(c)")
    })
  }

  func testThrows() {
    parseExpressionAndTest("{ () throws in }", "{ () throws in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertTrue(params.isEmpty)

      XCTAssertNil(signature.captureList)
      XCTAssertTrue(signature.canThrow)
      XCTAssertNil(signature.functionResult)

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testFunctionResult() {
    parseExpressionAndTest("{ () -> Foo in }", "{ () -> Foo in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertTrue(params.isEmpty)

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)

      guard let funcResult = signature.functionResult else {
        XCTFail("Failed in getting a function result.")
        return
      }
      XCTAssertTrue(funcResult.attributes.isEmpty)
      XCTAssertTrue(funcResult.type is TypeIdentifier)
      XCTAssertEqual(funcResult.type.textDescription, "Foo")

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testFunctionResultWithAttributes() {
    parseExpressionAndTest("{ () -> @a @b @c Foo in }", "{ () -> @a @b @c Foo in }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertTrue(params.isEmpty)

      XCTAssertNil(signature.captureList)
      XCTAssertFalse(signature.canThrow)

      guard let funcResult = signature.functionResult else {
        XCTFail("Failed in getting a function result.")
        return
      }
      XCTAssertEqual(funcResult.attributes.count, 3)
      XCTAssertEqual(funcResult.attributes[0].name.textDescription, "a")
      XCTAssertEqual(funcResult.attributes[1].name.textDescription, "b")
      XCTAssertEqual(funcResult.attributes[2].name.textDescription, "c")
      XCTAssertTrue(funcResult.type is TypeIdentifier)
      XCTAssertEqual(funcResult.type.textDescription, "Foo")

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testThrowsAndFunctionResult() {
    parseExpressionAndTest(
      "{ () throws -> @foo Bar in }",
      "{ () throws -> @foo Bar in }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      guard let signature = closureExpr.signature,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause else {
        XCTFail("Failed in getting a closure signature.")
        return
      }
      XCTAssertTrue(params.isEmpty)

      XCTAssertNil(signature.captureList)
      XCTAssertTrue(signature.canThrow)

      guard let funcResult = signature.functionResult else {
        XCTFail("Failed in getting a function result.")
        return
      }
      XCTAssertEqual(funcResult.attributes.count, 1)
      XCTAssertEqual(funcResult.attributes[0].name.textDescription, "foo")
      XCTAssertTrue(funcResult.type is TypeIdentifier)
      XCTAssertEqual(funcResult.type.textDescription, "Bar")

      XCTAssertNil(closureExpr.statements)
    })
  }

  func testCaptureListAndFullSignature() {
    parseExpressionAndTest(
      "{ [weak foo = self.foo] (a, b, c) throws -> @x @y @z Bar in print(foo!.title) }",
      "{ [weak foo = self.foo] (a, b, c) throws -> @x @y @z Bar in\nprint(foo!.title)\n}",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression,
        let signature = closureExpr.signature,
        let captureList = signature.captureList,
        let clause = signature.parameterClause,
        case .parameterList(let params) = clause,
        let funcResult = signature.functionResult,
        let stmts = closureExpr.statements else {
        XCTFail("Failed in getting a closure expression.")
        return
      }

      XCTAssertEqual(captureList.count, 1)
      XCTAssertEqual(captureList[0].specifier, .weak)
      XCTAssertTrue(captureList[0].expression is AssignmentOperatorExpression)
      XCTAssertEqual(captureList[0].expression.textDescription, "foo = self.foo")

      XCTAssertEqual(params.count, 3)
      XCTAssertEqual(params[0].textDescription, "a")
      XCTAssertEqual(params[1].textDescription, "b")
      XCTAssertEqual(params[2].textDescription, "c")

      XCTAssertTrue(signature.canThrow)

      XCTAssertEqual(funcResult.attributes.count, 3)
      XCTAssertEqual(funcResult.attributes[0].name.textDescription, "x")
      XCTAssertEqual(funcResult.attributes[1].name.textDescription, "y")
      XCTAssertEqual(funcResult.attributes[2].name.textDescription, "z")
      XCTAssertTrue(funcResult.type is TypeIdentifier)
      XCTAssertEqual(funcResult.type.textDescription, "Bar")

      XCTAssertEqual(stmts.count, 1)
      XCTAssertEqual(stmts[0].textDescription, "print(foo!.title)")
    })
  }

  func testStatementsStartWithLeftParen() {
    parseExpressionAndTest("{ (foo ?? bar).sync() }",
      "{ (foo ?? bar).sync() }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      guard let stmts = closureExpr.statements else {
        XCTFail("Failed in getting statements.")
        return
      }
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is FunctionCallExpression)
      XCTAssertEqual(stmts[0].textDescription, "(foo ?? bar).sync()")
    })
  }

  func testStatementStartWithLeftSquare() {
    parseExpressionAndTest("{ [1, 3, 5].reduce(0, +) }",
      "{ [1, 3, 5].reduce(0, +) }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      guard let stmts = closureExpr.statements else {
        XCTFail("Failed in getting statements.")
        return
      }
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is FunctionCallExpression)
      XCTAssertEqual(stmts[0].textDescription, "[1, 3, 5].reduce(0, +)")
    })
  }

  func testStatementsStartWithIdentifier() {
    parseExpressionAndTest("{ foo = bar }",
      "{ foo = bar }",
      testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      guard let stmts = closureExpr.statements else {
        XCTFail("Failed in getting statements.")
        return
      }
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is AssignmentOperatorExpression)
      XCTAssertEqual(stmts[0].textDescription, "foo = bar")
    })
  }

  func testImplicitlyReturnTuple() {
    parseExpressionAndTest("{ (.region, $0) }", "{ (.region, $0) }", testClosure: { expr in
      guard let closureExpr = expr as? ClosureExpression else {
        XCTFail("Failed in getting a closure expression.")
        return
      }
      XCTAssertNil(closureExpr.signature)
      guard let stmts = closureExpr.statements else {
        XCTFail("Failed in getting statements.")
        return
      }
      XCTAssertEqual(stmts.count, 1)
      XCTAssertTrue(stmts[0] is TupleExpression)
      XCTAssertEqual(stmts[0].textDescription, "(.region, $0)")
    })

    parseExpressionAndTest("{ ($0, .region) }", "{ ($0, .region) }")
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedEndColumn: Int)] = [
      ("{}", 3),
      ("{ (foo) in }", 13),
      ("{ (.region, $0) }", 18),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.testString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testEmptyClosure", testEmptyClosure),
    ("testSingleStatement", testSingleStatement),
    ("testMultipleStatements", testMultipleStatements),
    ("testOneCaptureItem", testOneCaptureItem),
    ("testCaptureItemSpecifier", testCaptureItemSpecifier),
    ("testMultiCaptureItem", testMultiCaptureItem),
    ("testCaptureListAndStatements", testCaptureListAndStatements),
    ("testEmptyParameterList", testEmptyParameterList),
    ("testParamName", testParamName),
    ("testParamNameAndTypeAnnotation", testParamNameAndTypeAnnotation),
    ("testParamNameAndTypeAnnotationVarargs", testParamNameAndTypeAnnotationVarargs),
    ("testMultipleParameters", testMultipleParameters),
    ("testOneIdentifier", testOneIdentifier),
    ("testMultipleIdentifiers", testMultipleIdentifiers),
    ("testParameterListAndStatements", testParameterListAndStatements),
    ("testIdentifierListAndStatements", testIdentifierListAndStatements),
    ("testThrows", testThrows),
    ("testFunctionResult", testFunctionResult),
    ("testFunctionResultWithAttributes", testFunctionResultWithAttributes),
    ("testThrowsAndFunctionResult", testThrowsAndFunctionResult),
    ("testCaptureListAndFullSignature", testCaptureListAndFullSignature),
    ("testStatementsStartWithLeftParen", testStatementsStartWithLeftParen),
    ("testStatementStartWithLeftSquare", testStatementStartWithLeftSquare),
    ("testStatementsStartWithIdentifier", testStatementsStartWithIdentifier),
    ("testImplicitlyReturnTuple", testImplicitlyReturnTuple),
    ("testSourceRange", testSourceRange),
  ]
}
