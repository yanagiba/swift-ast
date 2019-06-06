/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

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
@testable import Sema

class LexicalParentAssignmentTests: XCTestCase {
  func testTopLevelDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    let a = 1
    print(a)
    break
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        XCTAssertTrue(stmt.lexicalParent === topLevelDecl)
      }
    }
  }

  func testClassDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    class foo {
      #if os(macOS)
      let a = 1
      #endif
      func bar() {}
    }
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? ClassDeclaration else {
        XCTFail("Failed in getting a ClassDeclaration.")
        return
      }
      for member in decl.members {
        switch member {
        case .declaration(let d):
          XCTAssertTrue(d.lexicalParent === decl)
        case .compilerControl(let s):
          XCTAssertTrue(s.lexicalParent === decl)
        }
      }
    }
  }

  func testConstantDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    let a = 1, b = 2
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? ConstantDeclaration else {
        XCTFail("Failed in getting a ConstantDeclaration.")
        return
      }
      for pttrnInit in decl.initializerList {
        XCTAssertTrue(pttrnInit.initializerExpression?.lexicalParent === decl)
      }
    }
  }

  func testDeinitializerDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    deinit {}
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? DeinitializerDeclaration else {
        XCTFail("Failed in getting a DeinitializerDeclaration.")
        return
      }
      XCTAssertTrue(decl.body.lexicalParent === decl)
    }
  }

  func testEnumDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    enum foo {
      #if os(macOS)
      let a = 1
      #endif
      func bar() {}
      case a
    }
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? EnumDeclaration else {
        XCTFail("Failed in getting a EnumDeclaration.")
        return
      }
      for member in decl.members {
        switch member {
        case .declaration(let d):
          XCTAssertTrue(d.lexicalParent === decl)
        case .compilerControl(let s):
          XCTAssertTrue(s.lexicalParent === decl)
        default:
          continue
        }
      }
    }
  }

  func testExtensionDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    extension foo {
      #if os(macOS)
      var a: Int { return 1 }
      #endif
      func bar() {}
    }
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? ExtensionDeclaration else {
        XCTFail("Failed in getting a ExtensionDeclaration.")
        return
      }
      for member in decl.members {
        switch member {
        case .declaration(let d):
          XCTAssertTrue(d.lexicalParent === decl)
        case .compilerControl(let s):
          XCTAssertTrue(s.lexicalParent === decl)
        }
      }
    }
  }

  func testFunctionDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    func foo(i: Int = 1, j: Int = 2) {}
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? FunctionDeclaration else {
        XCTFail("Failed in getting a FunctionDeclaration.")
        return
      }
      XCTAssertTrue(decl.body?.lexicalParent === decl)
      for param in decl.signature.parameterList {
        XCTAssertTrue(param.defaultArgumentClause?.lexicalParent === decl)
      }
    }
  }

  func testInitializerDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    init(i: Int = 1, j: Int = 2) {}
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? InitializerDeclaration else {
        XCTFail("Failed in getting a InitializerDeclaration.")
        return
      }
      XCTAssertTrue(decl.body.lexicalParent === decl)
      for param in decl.parameterList {
        XCTAssertTrue(param.defaultArgumentClause?.lexicalParent === decl)
      }
    }
  }

  func testStructDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    struct foo {
      #if os(macOS)
      let a = 1
      #endif
      func bar() {}
    }
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? StructDeclaration else {
        XCTFail("Failed in getting a StructDeclaration.")
        return
      }
      for member in decl.members {
        switch member {
        case .declaration(let d):
          XCTAssertTrue(d.lexicalParent === decl)
        case .compilerControl(let s):
          XCTAssertTrue(s.lexicalParent === decl)
        }
      }
    }
  }

  func testSubscriptDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    subscript(i: Int = 1, j: Int = 2) -> Element {}
    """) { topLevelDecl in
      guard let decl = topLevelDecl.statements[0] as? SubscriptDeclaration else {
        XCTFail("Failed in getting a SubscriptDeclaration.")
        return
      }
      if case .codeBlock(let codeBlock) = decl.body {
        XCTAssertTrue(codeBlock.lexicalParent === decl)
      }
      for param in decl.parameterList {
        XCTAssertTrue(param.defaultArgumentClause?.lexicalParent === decl)
      }
    }
  }

  func testVariableDeclaration() {
    semaLexicalParentAssignmentAndTest("""
    var a = 1, b = 2
    var c: Int { return 3 }
    """) { topLevelDecl in
      guard let decl1 = topLevelDecl.statements[0] as? VariableDeclaration,
        let decl2 = topLevelDecl.statements[1] as? VariableDeclaration,
        case .initializerList(let initList) = decl1.body,
        case .codeBlock(_, _, let codeBlock) = decl2.body
      else {
        XCTFail("Failed in getting VariableDeclarations.")
        return
      }
      for pttrnInit in initList {
        XCTAssertTrue(pttrnInit.initializerExpression?.lexicalParent === decl1)
      }
      XCTAssertTrue(codeBlock.lexicalParent === decl2)
    }
  }

  func testDeferStatement() {
    semaLexicalParentAssignmentAndTest("""
    defer {
      let a = 1
      print(a)
      break
    }
    """) { topLevelDecl in
      guard let deferStmt = topLevelDecl.statements.first as? DeferStatement else {
        XCTFail("Failed in getting a defer statement.")
        return
      }
      let codeBlock = deferStmt.codeBlock
      XCTAssertTrue(codeBlock.lexicalParent === deferStmt)
      for stmt in codeBlock.statements {
        XCTAssertTrue(stmt.lexicalParent === codeBlock)
      }
    }
  }

  func testDoStatement() {
    semaLexicalParentAssignmentAndTest("""
    do {
    } catch err1 where exp1 {
    } catch err2 {
    } catch {
    }
    """) { topLevelDecl in
      guard let doStmt = topLevelDecl.statements.first as? DoStatement else {
        XCTFail("Failed in getting a do statement.")
        return
      }

      let codeBlock = doStmt.codeBlock
      XCTAssertTrue(codeBlock.lexicalParent === doStmt)

      let catch1 = doStmt.catchClauses[0]
      XCTAssertTrue(catch1.whereExpression?.lexicalParent === doStmt)
      XCTAssertTrue(catch1.codeBlock.lexicalParent === doStmt)

      let catch2 = doStmt.catchClauses[1]
      XCTAssertTrue(catch2.whereExpression?.lexicalParent === nil)
      XCTAssertTrue(catch2.codeBlock.lexicalParent === doStmt)

      let catch3 = doStmt.catchClauses[2]
      XCTAssertTrue(catch3.whereExpression?.lexicalParent === nil)
      XCTAssertTrue(catch3.codeBlock.lexicalParent === doStmt)
    }
  }

  func testForInStatement() {
    semaLexicalParentAssignmentAndTest("""
    for a in b {
    }
    for a in b where a == c {
    }
    """) { topLevelDecl in
      guard let forStmt1 = topLevelDecl.statements[0] as? ForInStatement,
        let forStmt2 = topLevelDecl.statements[1] as? ForInStatement
      else {
        XCTFail("Failed in getting for statements.")
        return
      }

      XCTAssertTrue(forStmt1.collection.lexicalParent === forStmt1)
      XCTAssertTrue(forStmt1.item.whereClause?.lexicalParent === nil)
      XCTAssertTrue(forStmt1.codeBlock.lexicalParent === forStmt1)

      XCTAssertTrue(forStmt2.collection.lexicalParent === forStmt2)
      XCTAssertTrue(forStmt2.item.whereClause?.lexicalParent === forStmt2)
      XCTAssertTrue(forStmt2.codeBlock.lexicalParent === forStmt2)
    }
  }

  func testGuardStatement() {
    semaLexicalParentAssignmentAndTest("""
    guard true, case .a(1) = b, let a = 1, var b = false else {
    }
    """) { topLevelDecl in
      guard let guardStmt = topLevelDecl.statements[0] as? GuardStatement else {
        XCTFail("Failed in getting a guard statement.")
        return
      }

      XCTAssertTrue(guardStmt.codeBlock.lexicalParent === guardStmt)
      for condition in guardStmt.conditionList {
        switch condition {
        case .expression(let expr):
          XCTAssertTrue(expr.lexicalParent === guardStmt)
        case .case(_, let expr):
          XCTAssertTrue(expr.lexicalParent === guardStmt)
        case .let(_, let expr):
          XCTAssertTrue(expr.lexicalParent === guardStmt)
        case .var(_, let expr):
          XCTAssertTrue(expr.lexicalParent === guardStmt)
        default:
          continue
        }
      }
    }
  }

  func testIfStatement() {
    semaLexicalParentAssignmentAndTest("""
    if true {
    } else if true {
    } else {
    }
    """) { topLevelDecl in
      guard let ifStmt = topLevelDecl.statements[0] as? IfStatement else {
        XCTFail("Failed in getting an if statement.")
        return
      }

      XCTAssertTrue(ifStmt.codeBlock.lexicalParent === ifStmt)
      if case .expression(let expr) = ifStmt.conditionList[0] {
        XCTAssertTrue(expr.lexicalParent === ifStmt)
      }

      guard case .elseif(let elseIfStmt)? = ifStmt.elseClause else {
        XCTFail("Failed in getting an elseif statement.")
        return
      }

      XCTAssertTrue(elseIfStmt.lexicalParent === ifStmt)
      XCTAssertTrue(elseIfStmt.codeBlock.lexicalParent === elseIfStmt)
      if case .expression(let expr) = elseIfStmt.conditionList[0] {
        XCTAssertTrue(expr.lexicalParent === elseIfStmt)
      }

      guard case .else(let elseCodeBlock)? = elseIfStmt.elseClause else {
        XCTFail("Failed in getting an else block.")
        return
      }
      XCTAssertTrue(elseCodeBlock.lexicalParent === elseIfStmt)
    }
  }

  func testLabeledStatement() {
    semaLexicalParentAssignmentAndTest("""
    a: for a in b {}
    b: while a {}
    c: repeat {} while a
    d: if a {}
    e: do {} catch {}
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        guard let labeledStmt = stmt as? LabeledStatement else {
          XCTFail("Failed in getting a labeled statement.")
          return
        }
        XCTAssertTrue(labeledStmt.lexicalParent === topLevelDecl)
        XCTAssertTrue(labeledStmt.statement.lexicalParent === labeledStmt)
      }
    }
  }

  func testRepeatWhileStatement() {
    semaLexicalParentAssignmentAndTest("""
    repeat {} while foo
    """) { topLevelDecl in
      guard let repeatStmt = topLevelDecl.statements[0] as? RepeatWhileStatement else {
        XCTFail("Failed in getting a repeat-while statement.")
        return
      }

      XCTAssertTrue(repeatStmt.codeBlock.lexicalParent === repeatStmt)
      XCTAssertTrue(repeatStmt.conditionExpression.lexicalParent === repeatStmt)
    }
  }

  func testReturnStatement() {
    semaLexicalParentAssignmentAndTest("""
    return foo
    return
    """) { topLevelDecl in
      guard let returnStmt1 = topLevelDecl.statements[0] as? ReturnStatement,
        let returnStmt2 = topLevelDecl.statements[1] as? ReturnStatement
      else {
        XCTFail("Failed in getting return statements.")
        return
      }

      XCTAssertTrue(returnStmt1.expression?.lexicalParent === returnStmt1)
      XCTAssertTrue(returnStmt2.expression?.lexicalParent === nil)
    }
  }

  func testSwitchStatement() {
    semaLexicalParentAssignmentAndTest("""
    switch foo {
    case true:
      print(a)
    case (a, _), (b, _) where a == b:
      print(b)
    default:
      print(a)
      print(b)
    }
    """) { topLevelDecl in
      guard let switchStmt = topLevelDecl.statements.first as? SwitchStatement,
        case let .case(items1, stmts1) = switchStmt.cases[0],
        case let .case(items2, stmts2) = switchStmt.cases[1],
        case let .default(stmts3) = switchStmt.cases[2]
      else {
        XCTFail("Failed in getting a switch statement.")
        return
      }

      XCTAssertTrue(switchStmt.expression.lexicalParent === switchStmt)

      XCTAssertTrue(items1[0].whereExpression?.lexicalParent === nil)
      for stmt in stmts1 {
        XCTAssertTrue(stmt.lexicalParent === switchStmt)
      }

      XCTAssertTrue(items2[0].whereExpression?.lexicalParent === nil)
      XCTAssertTrue(items2[1].whereExpression?.lexicalParent === switchStmt)
      for stmt in stmts2 {
        XCTAssertTrue(stmt.lexicalParent === switchStmt)
      }

      for stmt in stmts3 {
        XCTAssertTrue(stmt.lexicalParent === switchStmt)
      }
    }
  }

  func testThrowStatement() {
    semaLexicalParentAssignmentAndTest("""
    throw foo
    """) { topLevelDecl in
      guard let throwStmt = topLevelDecl.statements[0] as? ThrowStatement else {
        XCTFail("Failed in getting a throw statement.")
        return
      }

      XCTAssertTrue(throwStmt.expression.lexicalParent === throwStmt)
    }
  }

  func testWhileStatement() {
    semaLexicalParentAssignmentAndTest("""
    while true, case .a(1) = b, let a = 1, var b = false {
    }
    """) { topLevelDecl in
      guard let whileStmt = topLevelDecl.statements[0] as? WhileStatement else {
        XCTFail("Failed in getting a while statement.")
        return
      }

      XCTAssertTrue(whileStmt.codeBlock.lexicalParent === whileStmt)
      for condition in whileStmt.conditionList {
        switch condition {
        case .expression(let expr):
          XCTAssertTrue(expr.lexicalParent === whileStmt)
        case .case(_, let expr):
          XCTAssertTrue(expr.lexicalParent === whileStmt)
        case .let(_, let expr):
          XCTAssertTrue(expr.lexicalParent === whileStmt)
        case .var(_, let expr):
          XCTAssertTrue(expr.lexicalParent === whileStmt)
        default:
          continue
        }
      }
    }
  }

  func testAssignmentOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    a = 1
    """) { topLevelDecl in
      guard let assignOpExpr = topLevelDecl.statements[0] as? AssignmentOperatorExpression else {
        XCTFail("Failed in getting an assignment operator expression.")
        return
      }

      XCTAssertTrue(assignOpExpr.leftExpression.lexicalParent === assignOpExpr)
      XCTAssertTrue(assignOpExpr.rightExpression.lexicalParent === assignOpExpr)
    }
  }

  func testBinaryOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    a + b
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? BinaryOperatorExpression else {
        XCTFail("Failed in getting a BinaryOperatorExpression.")
        return
      }
      XCTAssertTrue(expr.leftExpression.lexicalParent === expr)
      XCTAssertTrue(expr.rightExpression.lexicalParent === expr)
    }
  }

  func testExplicitMemberExpression() {
    semaLexicalParentAssignmentAndTest("""
    foo.0
    foo.bar
    foo.bar<T>
    foo.bar(a:b:c:)
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        guard let expr = stmt as? ExplicitMemberExpression else {
          XCTFail("Failed in getting a ExplicitMemberExpression.")
          return
        }
        switch expr.kind {
        case .tuple(let e, _):
          XCTAssertTrue(e.lexicalParent === expr)
        case .namedType(let e, _):
          XCTAssertTrue(e.lexicalParent === expr)
        case .generic(let e, _, _):
          XCTAssertTrue(e.lexicalParent === expr)
        case .argument(let e, _, _):
          XCTAssertTrue(e.lexicalParent === expr)
        }
      }
    }
  }

  func testForcedValueExpression() {
    semaLexicalParentAssignmentAndTest("""
    a!
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? ForcedValueExpression else {
        XCTFail("Failed in getting a ForcedValueExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
    }
  }

  func testFunctionCallExpressionAndClosureExpression() {
    semaLexicalParentAssignmentAndTest("""
    foo(a, b: b, &c, d: &d) {
      print(a)
      print(b)
    }
    """) { topLevelDecl in
      guard let funcCallExpr = topLevelDecl.statements[0] as? FunctionCallExpression,
        let args = funcCallExpr.argumentClause,
        let closureExpr = funcCallExpr.trailingClosure,
        let closureStmts = closureExpr.statements
      else {
        XCTFail("Failed in getting a FunctionCallExpression.")
        return
      }
      XCTAssertTrue(funcCallExpr.postfixExpression.lexicalParent === funcCallExpr)
      for arg in args {
        switch arg {
        case .expression(let e):
          XCTAssertTrue(e.lexicalParent === funcCallExpr)
        case .namedExpression(_, let e):
          XCTAssertTrue(e.lexicalParent === funcCallExpr)
        case .memoryReference(let e):
          XCTAssertTrue(e.lexicalParent === funcCallExpr)
        case .namedMemoryReference(_, let e):
          XCTAssertTrue(e.lexicalParent === funcCallExpr)
        default:
          continue
        }
      }
      XCTAssertTrue(closureExpr.lexicalParent === funcCallExpr)
      for cs in closureStmts {
        XCTAssertTrue(cs.lexicalParent === closureExpr)
      }
    }
  }

  func testInitializerExpression() {
    semaLexicalParentAssignmentAndTest("""
    foo.init(a:b:c:)
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? InitializerExpression else {
        XCTFail("Failed in getting a InitializerExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
    }
  }

  func testKeyPathStringExpression() {
    semaLexicalParentAssignmentAndTest("""
    _ = #keyPath(foo)
    """) { topLevelDecl in
      guard let assignOpExpr = topLevelDecl.statements[0] as? AssignmentOperatorExpression,
        let expr = assignOpExpr.rightExpression as? KeyPathStringExpression
      else {
        XCTFail("Failed in getting a key-path string expression.")
        return
      }
      XCTAssertTrue(expr.expression.lexicalParent === expr)
    }
  }

  func testLiteralExpression() {
    semaLexicalParentAssignmentAndTest("""
    _ = "\(1)\(2)\(3)"
    _ = [1, 2, 3]
    _ = [a: 1, b: 2, c: 3]
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        guard let assignOpExpr = stmt as? AssignmentOperatorExpression,
          let expr = assignOpExpr.rightExpression as? LiteralExpression
        else {
          XCTFail("Failed in getting a LiteralExpression.")
          return
        }
        switch expr.kind {
        case .interpolatedString(let es, _):
          for e in es {
            XCTAssertTrue(e.lexicalParent === expr)
          }
        case .array(let es):
          for e in es {
            XCTAssertTrue(e.lexicalParent === expr)
          }
        case .dictionary(let d):
          for entry in d {
            XCTAssertTrue(entry.key.lexicalParent === expr)
            XCTAssertTrue(entry.value.lexicalParent === expr)
          }
        default:
          continue
        }
      }
    }
  }

  func testOptionalChainingExpression() {
    semaLexicalParentAssignmentAndTest("""
    a?
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? OptionalChainingExpression else {
        XCTFail("Failed in getting a OptionalChainingExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
    }
  }

  func testParenthesizedExpression() {
    semaLexicalParentAssignmentAndTest("""
    (a)
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? ParenthesizedExpression else {
        XCTFail("Failed in getting a ParenthesizedExpression.")
        return
      }
      XCTAssertTrue(expr.expression.lexicalParent === expr)
    }
  }

  func testPostfixOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    a++
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? PostfixOperatorExpression else {
        XCTFail("Failed in getting a PostfixOperatorExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
    }
  }

  func testPostfixSelfExpression() {
    semaLexicalParentAssignmentAndTest("""
    a.self
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? PostfixSelfExpression else {
        XCTFail("Failed in getting a PostfixSelfExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
    }
  }

  func testPrefixOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    --a
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? PrefixOperatorExpression else {
        XCTFail("Failed in getting a PrefixOperatorExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
    }
  }

  func testSelectorExpression() {
    semaLexicalParentAssignmentAndTest("""
    _ = #selector(foo)
    _ = #selector(getter: bar)
    _ = #selector(setter: bar)
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        guard let assignOpExpr = stmt as? AssignmentOperatorExpression,
          let expr = assignOpExpr.rightExpression as? SelectorExpression
        else {
          XCTFail("Failed in getting a SelectorExpression.")
          return
        }
        switch expr.kind {
        case .selector(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        case .getter(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        case .setter(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        default:
          continue
        }
      }
    }
  }

  func testSelfExpression() {
    semaLexicalParentAssignmentAndTest("""
    self[a, b]
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? SelfExpression else {
        XCTFail("Failed in getting a SelfExpression.")
        return
      }
      if case .subscript(let args) = expr.kind {
        for arg in args {
          XCTAssertTrue(arg.expression.lexicalParent === expr)
        }
      }
    }
  }

  func testSequenceExpression() {
    semaLexicalParentAssignmentAndTest("""
    a + b ? c : d
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? SequenceExpression else {
        XCTFail("Failed in getting a SequenceExpression.")
        return
      }
      for element in expr.elements {
        switch element {
        case .expression(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        case .ternaryConditionalOperator(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        default:
          continue
        }
      }
    }
  }

  func testSubscriptExpression() {
    semaLexicalParentAssignmentAndTest("""
    foo[a, b]
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? SubscriptExpression else {
        XCTFail("Failed in getting a SubscriptExpression.")
        return
      }
      XCTAssertTrue(expr.postfixExpression.lexicalParent === expr)
      for arg in expr.arguments {
        XCTAssertTrue(arg.expression.lexicalParent === expr)
      }
    }
  }

  func testSuperclassExpression() {
    semaLexicalParentAssignmentAndTest("""
    super[a, b]
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? SuperclassExpression else {
        XCTFail("Failed in getting a SuperclassExpression.")
        return
      }
      if case .subscript(let args) = expr.kind {
        for arg in args {
          XCTAssertTrue(arg.expression.lexicalParent === expr)
        }
      }
    }
  }

  func testTernaryConditionalOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    a ? b : c
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? TernaryConditionalOperatorExpression else {
        XCTFail("Failed in getting a TernaryConditionalOperatorExpression.")
        return
      }
      XCTAssertTrue(expr.conditionExpression.lexicalParent === expr)
      XCTAssertTrue(expr.trueExpression.lexicalParent === expr)
      XCTAssertTrue(expr.falseExpression.lexicalParent === expr)
    }
  }

  func testTryOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    try foo()
    try! foo()
    try? foo()
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        guard let expr = stmt as? TryOperatorExpression else {
          XCTFail("Failed in getting a TryOperatorExpression.")
          return
        }
        switch expr.kind {
        case .try(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        case .forced(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        case .optional(let e):
          XCTAssertTrue(e.lexicalParent === expr)
        }
      }
    }
  }

  func testTupleExpression() {
    semaLexicalParentAssignmentAndTest("""
    (1, 2, 3)
    """) { topLevelDecl in
      guard let expr = topLevelDecl.statements[0] as? TupleExpression else {
        XCTFail("Failed in getting a TupleExpression.")
        return
      }
      for element in expr.elementList {
        XCTAssertTrue(element.expression.lexicalParent === expr)
      }
    }
  }

  func testTypeCastingOperatorExpression() {
    semaLexicalParentAssignmentAndTest("""
    foo is Foo
    foo as Foo
    foo as? Foo
    foo as! Foo
    """) { topLevelDecl in
      for stmt in topLevelDecl.statements {
        guard let expr = stmt as? TypeCastingOperatorExpression else {
          XCTFail("Failed in getting a TypeCastingOperatorExpression.")
          return
        }
        switch expr.kind {
        case .check(let e, _):
          XCTAssertTrue(e.lexicalParent === expr)
        case .cast(let e, _):
          XCTAssertTrue(e.lexicalParent === expr)
        case .conditionalCast(let e, _):
          XCTAssertTrue(e.lexicalParent === expr)
        case .forcedCast(let e, _):
          XCTAssertTrue(e.lexicalParent === expr)
        }
      }
    }
  }

  private func semaLexicalParentAssignmentAndTest(
    _ content: String,
    testAssigned: (TopLevelDeclaration) -> Void
  ) {
    let topLevelDecl = parse(content)
    XCTAssertFalse(topLevelDecl.lexicalParentAssigned)
    XCTAssertNil(topLevelDecl.lexicalParent)
    let lexicalParentAssignment = LexicalParentAssignment()
    lexicalParentAssignment.assign([topLevelDecl])
    XCTAssertTrue(topLevelDecl.lexicalParentAssigned)
    XCTAssertNil(topLevelDecl.lexicalParent)
    testAssigned(topLevelDecl)
  }

  static var allTests = [
    ("testTopLevelDeclaration", testTopLevelDeclaration),
    ("testClassDeclaration", testClassDeclaration),
    ("testConstantDeclaration", testConstantDeclaration),
    ("testDeinitializerDeclaration", testDeinitializerDeclaration),
    ("testEnumDeclaration", testEnumDeclaration),
    ("testExtensionDeclaration", testExtensionDeclaration),
    ("testFunctionDeclaration", testFunctionDeclaration),
    ("testInitializerDeclaration", testInitializerDeclaration),
    ("testStructDeclaration", testStructDeclaration),
    ("testSubscriptDeclaration", testSubscriptDeclaration),
    ("testVariableDeclaration", testVariableDeclaration),
    ("testDeferStatement", testDeferStatement),
    ("testDoStatement", testDoStatement),
    ("testForInStatement", testForInStatement),
    ("testGuardStatement", testGuardStatement),
    ("testIfStatement", testIfStatement),
    ("testLabeledStatement", testLabeledStatement),
    ("testRepeatWhileStatement", testRepeatWhileStatement),
    ("testReturnStatement", testReturnStatement),
    ("testSwitchStatement", testSwitchStatement),
    ("testThrowStatement", testThrowStatement),
    ("testWhileStatement", testWhileStatement),
    ("testAssignmentOperatorExpression", testAssignmentOperatorExpression),
    ("testBinaryOperatorExpression", testBinaryOperatorExpression),
    ("testExplicitMemberExpression", testExplicitMemberExpression),
    ("testForcedValueExpression", testForcedValueExpression),
    ("testFunctionCallExpressionAndClosureExpression",
      testFunctionCallExpressionAndClosureExpression),
    ("testInitializerExpression", testInitializerExpression),
    ("testKeyPathStringExpression", testKeyPathStringExpression),
    ("testLiteralExpression", testLiteralExpression),
    ("testOptionalChainingExpression", testOptionalChainingExpression),
    ("testParenthesizedExpression", testParenthesizedExpression),
    ("testPostfixOperatorExpression", testPostfixOperatorExpression),
    ("testPostfixSelfExpression", testPostfixSelfExpression),
    ("testPrefixOperatorExpression", testPrefixOperatorExpression),
    ("testSelectorExpression", testSelectorExpression),
    ("testSelfExpression", testSelfExpression),
    ("testSequenceExpression", testSequenceExpression),
    ("testSubscriptExpression", testSubscriptExpression),
    ("testSuperclassExpression", testSuperclassExpression),
    ("testTernaryConditionalOperatorExpression", testTernaryConditionalOperatorExpression),
    ("testTryOperatorExpression", testTryOperatorExpression),
    ("testTupleExpression", testTupleExpression),
    ("testTypeCastingOperatorExpression", testTypeCastingOperatorExpression),
  ]
}
