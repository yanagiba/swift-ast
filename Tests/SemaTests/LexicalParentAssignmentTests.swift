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
  ]
}
