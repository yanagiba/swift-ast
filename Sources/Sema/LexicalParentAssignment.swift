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

import AST

public struct LexicalParentAssignment {
  private let _assignmentVisitor = AssignmentVisitor()

  public init() {}

  public func assign(_ collection: ASTUnitCollection) {
    return collection.forEach(assign)
  }

  private func assign(_ unit: ASTUnit) {
    do {
      _ = try _assignmentVisitor.traverse(unit.translationUnit)
      unit.translationUnit.assignedLexicalParent()
    } catch {}
  }
}

private class AssignmentVisitor : ASTVisitor {
  func visit(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
    for stmt in topLevelDecl.statements {
      stmt.setLexicalParent(topLevelDecl)
    }

    return true
  }

  func visit(_ codeBlock: CodeBlock) throws -> Bool {
    for stmt in codeBlock.statements {
      stmt.setLexicalParent(codeBlock)
    }

    return true
  }

  func visit(_ stmt: DeferStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)

    return true
  }

  func visit(_ stmt: DoStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)

    for catchClause in stmt.catchClauses {
      catchClause.codeBlock.setLexicalParent(stmt)
      catchClause.whereExpression?.setLexicalParent(stmt)
    }

    return true
  }

  func visit(_ stmt: ForInStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)
    stmt.collection.setLexicalParent(stmt)
    stmt.item.whereClause?.setLexicalParent(stmt)

    return true
  }

  func visit(_ stmt: GuardStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)
    for condition in stmt.conditionList {
      switch condition {
      case .expression(let expr):
        expr.setLexicalParent(stmt)
      case .case(_, let expr):
        expr.setLexicalParent(stmt)
      case .let(_, let expr):
        expr.setLexicalParent(stmt)
      case .var(_, let expr):
        expr.setLexicalParent(stmt)
      default:
        continue
      }
    }

    return true
  }

  func visit(_ stmt: IfStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)

    for condition in stmt.conditionList {
      switch condition {
      case .expression(let expr):
        expr.setLexicalParent(stmt)
      case .case(_, let expr):
        expr.setLexicalParent(stmt)
      case .let(_, let expr):
        expr.setLexicalParent(stmt)
      case .var(_, let expr):
        expr.setLexicalParent(stmt)
      default:
        continue
      }
    }

    switch stmt.elseClause {
    case .else(let codeBlock)?:
      codeBlock.setLexicalParent(stmt)
    case .elseif(let elseIfStmt)?:
      elseIfStmt.setLexicalParent(stmt)
    default:
      break
    }

    return true
  }

  func visit(_ stmt: LabeledStatement) throws -> Bool {
    stmt.statement.setLexicalParent(stmt)
    return true
  }

  func visit(_ stmt: RepeatWhileStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)
    stmt.conditionExpression.setLexicalParent(stmt)
    return true
  }

  func visit(_ stmt: ReturnStatement) throws -> Bool {
    stmt.expression?.setLexicalParent(stmt)
    return true
  }

  func visit(_ stmt: SwitchStatement) throws -> Bool {
    stmt.expression.setLexicalParent(stmt)
    for c in stmt.cases {
      switch c {
      case let .case(items, stmts):
        for i in items {
          i.whereExpression?.setLexicalParent(stmt)
        }
        for s in stmts {
          s.setLexicalParent(stmt)
        }
      case .default(let stmts):
        for s in stmts {
          s.setLexicalParent(stmt)
        }
      }
    }
    return true
  }

  func visit(_ stmt: ThrowStatement) throws -> Bool {
    stmt.expression.setLexicalParent(stmt)
    return true
  }

  func visit(_ stmt: WhileStatement) throws -> Bool {
    stmt.codeBlock.setLexicalParent(stmt)
    for condition in stmt.conditionList {
      switch condition {
      case .expression(let expr):
        expr.setLexicalParent(stmt)
      case .case(_, let expr):
        expr.setLexicalParent(stmt)
      case .let(_, let expr):
        expr.setLexicalParent(stmt)
      case .var(_, let expr):
        expr.setLexicalParent(stmt)
      default:
        continue
      }
    }

    return true
  }

}

fileprivate extension Statement {
  fileprivate func setLexicalParent(_ parentNode: ASTNode) {
    if let node = self as? ASTNode {
      node.setLexicalParent(parentNode)
    }
  }
}
