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

  func visit(_ decl: ClassDeclaration) throws -> Bool {
    for member in decl.members {
      switch member {
      case .declaration(let d):
        d.setLexicalParent(decl)
      case .compilerControl(let s):
        s.setLexicalParent(decl)
      }
    }

    return true
  }

  func visit(_ decl: ConstantDeclaration) throws -> Bool {
    for pttrnInit in decl.initializerList {
      pttrnInit.initializerExpression?.setLexicalParent(decl)
    }

    return true
  }

  func visit(_ decl: DeinitializerDeclaration) throws -> Bool {
    decl.body.setLexicalParent(decl)
    return true
  }

  func visit(_ decl: EnumDeclaration) throws -> Bool {
    for member in decl.members {
      switch member {
      case .declaration(let d):
        d.setLexicalParent(decl)
      case .compilerControl(let s):
        s.setLexicalParent(decl)
      default:
        continue
      }
    }

    return true
  }

  func visit(_ decl: ExtensionDeclaration) throws -> Bool {
    for member in decl.members {
      switch member {
      case .declaration(let d):
        d.setLexicalParent(decl)
      case .compilerControl(let s):
        s.setLexicalParent(decl)
      }
    }

    return true
  }

  func visit(_ decl: FunctionDeclaration) throws -> Bool {
    decl.body?.setLexicalParent(decl)
    for param in decl.signature.parameterList {
      param.defaultArgumentClause?.setLexicalParent(decl)
    }

    return true
  }

  func visit(_ decl: InitializerDeclaration) throws -> Bool {
    decl.body.setLexicalParent(decl)
    for param in decl.parameterList {
      param.defaultArgumentClause?.setLexicalParent(decl)
    }

    return true
  }

  func visit(_ decl: StructDeclaration) throws -> Bool {
    for member in decl.members {
      switch member {
      case .declaration(let d):
        d.setLexicalParent(decl)
      case .compilerControl(let s):
        s.setLexicalParent(decl)
      }
    }

    return true
  }

  func visit(_ decl: SubscriptDeclaration) throws -> Bool {
    if case .codeBlock(let codeBlock) = decl.body {
      codeBlock.setLexicalParent(decl)
    }
    for param in decl.parameterList {
      param.defaultArgumentClause?.setLexicalParent(decl)
    }

    return true
  }

  func visit(_ decl: VariableDeclaration) throws -> Bool {
    switch decl.body {
    case .initializerList(let initList):
      for pttrnInit in initList {
        pttrnInit.initializerExpression?.setLexicalParent(decl)
      }
    case .codeBlock(_, _, let codeBlock):
      codeBlock.setLexicalParent(decl)
    default:
      break
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

  func visit(_ expr: AssignmentOperatorExpression) throws -> Bool {
    expr.leftExpression.setLexicalParent(expr)
    expr.rightExpression.setLexicalParent(expr)

    return true
  }

  func visit(_ expr: BinaryOperatorExpression) throws -> Bool {
    expr.leftExpression.setLexicalParent(expr)
    expr.rightExpression.setLexicalParent(expr)

    return true
  }

  func visit(_ expr: ClosureExpression) throws -> Bool {
    for stmt in expr.statements ?? [] {
      stmt.setLexicalParent(expr)
    }

    return true
  }

  func visit(_ expr: ExplicitMemberExpression) throws -> Bool {
    switch expr.kind {
    case .tuple(let e, _):
      e.setLexicalParent(expr)
    case .namedType(let e, _):
      e.setLexicalParent(expr)
    case .generic(let e, _, _):
      e.setLexicalParent(expr)
    case .argument(let e, _, _):
      e.setLexicalParent(expr)
    }

    return true
  }

  func visit(_ expr: ForcedValueExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)

    return true
  }

  func visit(_ expr: FunctionCallExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    for arg in expr.argumentClause ?? [] {
      switch arg {
      case .expression(let e):
        e.setLexicalParent(expr)
      case .namedExpression(_, let e):
        e.setLexicalParent(expr)
      case .memoryReference(let e):
        e.setLexicalParent(expr)
      case .namedMemoryReference(_, let e):
        e.setLexicalParent(expr)
      default:
        continue
      }
    }
    expr.trailingClosure?.setLexicalParent(expr)

    return true
  }

  func visit(_ expr: InitializerExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: KeyPathStringExpression) throws -> Bool {
    expr.expression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: LiteralExpression) throws -> Bool {
    switch expr.kind {
    case .interpolatedString(let es, _):
      for e in es {
        e.setLexicalParent(expr)
      }
    case .array(let es):
      for e in es {
        e.setLexicalParent(expr)
      }
    case .dictionary(let d):
      for entry in d {
        entry.key.setLexicalParent(expr)
        entry.value.setLexicalParent(expr)
      }
    default:
      break
    }

    return true
  }

  func visit(_ expr: OptionalChainingExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: ParenthesizedExpression) throws -> Bool {
    expr.expression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: PostfixOperatorExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: PostfixSelfExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: PrefixOperatorExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    return true
  }

  func visit(_ expr: SelectorExpression) throws -> Bool {
    switch expr.kind {
    case .selector(let e):
      e.setLexicalParent(expr)
    case .getter(let e):
      e.setLexicalParent(expr)
    case .setter(let e):
      e.setLexicalParent(expr)
    default:
      break
    }

    return true
  }

  func visit(_ expr: SelfExpression) throws -> Bool {
    if case .subscript(let args) = expr.kind {
      for arg in args {
        arg.expression.setLexicalParent(expr)
      }
    }

    return true
  }

  func visit(_ expr: SequenceExpression) throws -> Bool {
    for element in expr.elements {
      switch element {
      case .expression(let e):
        e.setLexicalParent(expr)
      case .ternaryConditionalOperator(let e):
        e.setLexicalParent(expr)
      default:
        continue
      }
    }

    return true
  }

  func visit(_ expr: SubscriptExpression) throws -> Bool {
    expr.postfixExpression.setLexicalParent(expr)
    for arg in expr.arguments {
      arg.expression.setLexicalParent(expr)
    }

    return true
  }

  func visit(_ expr: SuperclassExpression) throws -> Bool {
    if case .subscript(let args) = expr.kind {
      for arg in args {
        arg.expression.setLexicalParent(expr)
      }
    }

    return true
  }

  func visit(_ expr: TernaryConditionalOperatorExpression) throws -> Bool {
    expr.conditionExpression.setLexicalParent(expr)
    expr.trueExpression.setLexicalParent(expr)
    expr.falseExpression.setLexicalParent(expr)

    return true
  }

  func visit(_ expr: TryOperatorExpression) throws -> Bool {
    switch expr.kind {
    case .try(let e):
      e.setLexicalParent(expr)
    case .forced(let e):
      e.setLexicalParent(expr)
    case .optional(let e):
      e.setLexicalParent(expr)
    }

    return true
  }

  func visit(_ expr: TupleExpression) throws -> Bool {
    for element in expr.elementList {
      element.expression.setLexicalParent(expr)
    }

    return true
  }

  func visit(_ expr: TypeCastingOperatorExpression) throws -> Bool {
    switch expr.kind {
    case .check(let e, _):
      e.setLexicalParent(expr)
    case .cast(let e, _):
      e.setLexicalParent(expr)
    case .conditionalCast(let e, _):
      e.setLexicalParent(expr)
    case .forcedCast(let e, _):
      e.setLexicalParent(expr)
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
