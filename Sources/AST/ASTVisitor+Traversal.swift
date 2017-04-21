/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

// extends AST traverseor with preordor depth-first traversal
extension ASTVisitor {
  public func traverse(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
    guard try visit(topLevelDecl) else { return false }

    return try traverse(topLevelDecl.statements)
  }

  public func traverse(_ codeBlock: CodeBlock) throws -> Bool {
    guard try visit(codeBlock) else { return false }

    return try traverse(codeBlock.statements)
  }

  // Declarations

  public func traverse(_ declaration: Declaration) throws -> Bool {
    switch declaration {
    case let decl as ClassDeclaration:
      return try traverse(decl)
    case let decl as ConstantDeclaration:
      return try traverse(decl)
    case let decl as DeinitializerDeclaration:
      return try traverse(decl)
    case let decl as EnumDeclaration:
      return try traverse(decl)
    case let decl as ExtensionDeclaration:
      return try traverse(decl)
    case let decl as FunctionDeclaration:
      return try traverse(decl)
    case let decl as ImportDeclaration:
      return try traverse(decl)
    case let decl as InitializerDeclaration:
      return try traverse(decl)
    case let decl as OperatorDeclaration:
      return try traverse(decl)
    case let decl as PrecedenceGroupDeclaration:
      return try traverse(decl)
    case let decl as ProtocolDeclaration:
      return try traverse(decl)
    case let decl as StructDeclaration:
      return try traverse(decl)
    case let decl as SubscriptDeclaration:
      return try traverse(decl)
    case let decl as TypealiasDeclaration:
      return try traverse(decl)
    case let decl as VariableDeclaration:
      return try traverse(decl)
    default:
      return true // no implementation for this declaration, just continue
    }
  }

  public func traverse(_ decl: ClassDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for member in decl.members {
      switch member {
      case .declaration(let decl):
        guard try traverse(decl) else { return false }
      case .compilerControl(let stmt):
        guard try traverse(stmt) else { return false }
      }
    }

    return true
  }

  public func traverse(_ decl: ConstantDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for initializer in decl.initializerList {
      if let expr = initializer.initializerExpression {
        guard try traverse(expr) else { return false }
      }
    }

    return true
  }

  public func traverse(_ decl: DeinitializerDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    return try traverse(decl.body)
  }

  public func traverse(_ decl: EnumDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for member in decl.members {
      switch member {
      case .declaration(let decl):
        guard try traverse(decl) else { return false }
      case .compilerControl(let stmt):
        guard try traverse(stmt) else { return false }
      default:
        continue // we don't traverse `union` and `rawValue` cases for now
      }
    }

    return true
  }

  public func traverse(_ decl: ExtensionDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for member in decl.members {
      switch member {
      case .declaration(let decl):
        guard try traverse(decl) else { return false }
      case .compilerControl(let stmt):
        guard try traverse(stmt) else { return false }
      }
    }

    return true
  }

  public func traverse(_ decl: FunctionDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for param in decl.signature.parameterList {
      if let defaultArg = param.defaultArgumentClause {
        guard try traverse(defaultArg) else { return false }
      }
    }

    if let body = decl.body {
      guard try traverse(body) else { return false }
    }

    return true
  }

  public func traverse(_ decl: ImportDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: InitializerDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: OperatorDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: PrecedenceGroupDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: ProtocolDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for member in decl.members {
      switch member {
      case .method(let method):
        for param in method.signature.parameterList {
          if let defaultArg = param.defaultArgumentClause {
            guard try traverse(defaultArg) else { return false }
          }
        }
      case .initializer(let initializer):
        for param in initializer.parameterList {
          if let defaultArg = param.defaultArgumentClause {
            guard try traverse(defaultArg) else { return false }
          }
        }
      case .subscript(let member):
        for param in member.parameterList {
          if let defaultArg = param.defaultArgumentClause {
            guard try traverse(defaultArg) else { return false }
          }
        }
      case .compilerControl(let stmt):
        guard try traverse(stmt) else { return false }
      default:
        continue
      }
    }

    return true
  }

  public func traverse(_ decl: StructDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for member in decl.members {
      switch member {
      case .declaration(let decl):
        guard try traverse(decl) else { return false }
      case .compilerControl(let stmt):
        guard try traverse(stmt) else { return false }
      }
    }

    return true
  }

  public func traverse(_ decl: SubscriptDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    for param in decl.parameterList {
      if let defaultArg = param.defaultArgumentClause {
        guard try traverse(defaultArg) else { return false }
      }
    }

    switch decl.body {
    case .codeBlock(let codeBlock):
      return try traverse(codeBlock)
    case .getterSetterBlock(let block):
      guard try traverse(block.getter.codeBlock) else { return false }
      if let setterBlock = block.setter?.codeBlock {
        guard try traverse(setterBlock) else { return false }
      }
    default:
      return true
    }

    return true
  }

  public func traverse(_ decl: TypealiasDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: VariableDeclaration) throws -> Bool {
    guard try visit(decl) else { return false }

    switch decl.body {
    case .initializerList(let initializerList):
      for initializer in initializerList {
        if let expr = initializer.initializerExpression {
          guard try traverse(expr) else { return false }
        }
      }
    case .codeBlock(_, _, let codeBlock):
      return try traverse(codeBlock)
    case .getterSetterBlock(_, _, let block):
      guard try traverse(block.getter.codeBlock) else { return false }
      if let setterBlock = block.setter?.codeBlock {
        guard try traverse(setterBlock) else { return false }
      }
    case let .willSetDidSetBlock(_, _, expr?, block):
      guard try traverse(expr) else { return false }
      if let willSetBlock = block.willSetClause?.codeBlock {
        guard try traverse(willSetBlock) else { return false }
      }
      if let didSetBlock = block.didSetClause?.codeBlock {
        guard try traverse(didSetBlock) else { return false }
      }
    default:
      return true
    }

    return true
  }

  // Statements

  public func traverse(_ statement: Statement) throws -> Bool {
    switch statement {
    case let decl as Declaration:
      return try traverse(decl)
    case let expr as Expression:
      return try traverse(expr)
    case let stmt as BreakStatement:
      return try traverse(stmt)
    case let stmt as CompilerControlStatement:
      return try traverse(stmt)
    case let stmt as ContinueStatement:
      return try traverse(stmt)
    case let stmt as DeferStatement:
      return try traverse(stmt)
    case let stmt as DoStatement:
      return try traverse(stmt)
    case let stmt as FallthroughStatement:
      return try traverse(stmt)
    case let stmt as ForInStatement:
      return try traverse(stmt)
    case let stmt as GuardStatement:
      return try traverse(stmt)
    case let stmt as IfStatement:
      return try traverse(stmt)
    case let stmt as LabeledStatement:
      return try traverse(stmt)
    case let stmt as RepeatWhileStatement:
      return try traverse(stmt)
    case let stmt as ReturnStatement:
      return try traverse(stmt)
    case let stmt as SwitchStatement:
      return try traverse(stmt)
    case let stmt as ThrowStatement:
      return try traverse(stmt)
    case let stmt as WhileStatement:
      return try traverse(stmt)
    default:
      return true
    }
  }

  private func traverse(_ statements: Statements) throws -> Bool {
    for stmt in statements {
      guard try traverse(stmt) else { return false }
    }
    return true
  }

  public func traverse(_ stmt: BreakStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: CompilerControlStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: ContinueStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: DeferStatement) throws -> Bool {
    guard try visit(stmt) else { return false }
    return try traverse(stmt.codeBlock)
  }

  public func traverse(_ stmt: DoStatement) throws -> Bool {
    guard try visit(stmt) else { return false }

    guard try traverse(stmt.codeBlock) else { return false }
    for catchBlock in stmt.catchClauses {
      if let expr = catchBlock.whereExpression {
        guard try traverse(expr) else { return false }
      }
      guard try traverse(catchBlock.codeBlock) else { return false }
    }

    return true
  }

  public func traverse(_ stmt: FallthroughStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: ForInStatement) throws -> Bool {
    guard try visit(stmt) else { return false }

    guard try traverse(stmt.collection) else { return false }
    if let expr = stmt.item.whereClause {
      guard try traverse(expr) else { return false }
    }
    return try traverse(stmt.codeBlock)
  }

  private func traverse(_ condition: Condition) throws -> Bool {
    switch condition {
    case .expression(let expr):
      return try traverse(expr)
    case .case(_, let expr):
      return try traverse(expr)
    case .let(_, let expr):
      return try traverse(expr)
    case .var(_, let expr):
      return try traverse(expr)
    default:
      return true
    }
  }

  private func traverse(_ conditionList: ConditionList) throws -> Bool {
    for condition in conditionList {
      guard try traverse(condition) else { return false }
    }

    return true
  }

  public func traverse(_ stmt: GuardStatement) throws -> Bool {
    guard try visit(stmt) else { return false }

    guard try traverse(stmt.conditionList) else { return false }
    return try traverse(stmt.codeBlock)
  }

  public func traverse(_ stmt: IfStatement) throws -> Bool {
    guard try visit(stmt) else { return false }

    guard try traverse(stmt.conditionList) else { return false }
    guard try traverse(stmt.codeBlock) else { return false }
    if let elseClause = stmt.elseClause {
      switch elseClause {
      case .else(let codeBlock):
        return try traverse(codeBlock)
      case .elseif(let ifStmt):
        return try traverse(ifStmt)
      }
    }
    return true
  }

  public func traverse(_ stmt: LabeledStatement) throws -> Bool {
    guard try visit(stmt) else { return false }
    return try traverse(stmt.statement)
  }

  public func traverse(_ stmt: RepeatWhileStatement) throws -> Bool {
    guard try visit(stmt) else { return false }
    guard try traverse(stmt.codeBlock) else { return false }
    return try traverse(stmt.conditionExpression)
  }

  public func traverse(_ stmt: ReturnStatement) throws -> Bool {
    guard try visit(stmt) else { return false }
    if let expr = stmt.expression {
      guard try traverse(expr) else { return false }
    }
    return true
  }

  public func traverse(_ stmt: SwitchStatement) throws -> Bool {
    guard try visit(stmt) else { return false }

    for eachCase in stmt.cases {
      switch eachCase {
      case let .case(items, statements):
        for item in items {
          if let expr = item.whereExpression {
            guard try traverse(expr) else { return false }
          }
        }
        guard try traverse(statements) else { return false }
      case .default(let statements):
        guard try traverse(statements) else { return false }
      }
    }

    return true
  }

  public func traverse(_ stmt: ThrowStatement) throws -> Bool {
    guard try visit(stmt) else { return false }
    return try traverse(stmt.expression)
  }

  public func traverse(_ stmt: WhileStatement) throws -> Bool {
    guard try visit(stmt) else { return false }
    guard try traverse(stmt.conditionList) else { return false }
    return try traverse(stmt.codeBlock)
  }

  // Expressions

  public func traverse(_ expression: Expression) throws -> Bool {
    switch expression {
    case let expr as AssignmentOperatorExpression:
      return try traverse(expr)
    case let expr as BinaryOperatorExpression:
      return try traverse(expr)
    case let expr as ClosureExpression:
      return try traverse(expr)
    case let expr as DynamicTypeExpression:
      return try traverse(expr)
    case let expr as ExplicitMemberExpression:
      return try traverse(expr)
    case let expr as ForcedValueExpression:
      return try traverse(expr)
    case let expr as FunctionCallExpression:
      return try traverse(expr)
    case let expr as IdentifierExpression:
      return try traverse(expr)
    case let expr as ImplicitMemberExpression:
      return try traverse(expr)
    case let expr as InOutExpression:
      return try traverse(expr)
    case let expr as InitializerExpression:
      return try traverse(expr)
    case let expr as KeyPathExpression:
      return try traverse(expr)
    case let expr as LiteralExpression:
      return try traverse(expr)
    case let expr as OptionalChainingExpression:
      return try traverse(expr)
    case let expr as ParenthesizedExpression:
      return try traverse(expr)
    case let expr as PostfixOperatorExpression:
      return try traverse(expr)
    case let expr as PostfixSelfExpression:
      return try traverse(expr)
    case let expr as PrefixOperatorExpression:
      return try traverse(expr)
    case let expr as SelectorExpression:
      return try traverse(expr)
    case let expr as SelfExpression:
      return try traverse(expr)
    case let expr as SubscriptExpression:
      return try traverse(expr)
    case let expr as SuperclassExpression:
      return try traverse(expr)
    case let expr as TernaryConditionalOperatorExpression:
      return try traverse(expr)
    case let expr as TryOperatorExpression:
      return try traverse(expr)
    case let expr as TupleExpression:
      return try traverse(expr)
    case let expr as TypeCastingOperatorExpression:
      return try traverse(expr)
    case let expr as WildcardExpression:
      return try traverse(expr)
    default:
      return true
    }
  }

  public func traverse(_ expr: AssignmentOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: BinaryOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: ClosureExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: DynamicTypeExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: ExplicitMemberExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: ForcedValueExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: FunctionCallExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: IdentifierExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: ImplicitMemberExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: InOutExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: InitializerExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: KeyPathExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: LiteralExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: OptionalChainingExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: ParenthesizedExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: PostfixOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: PostfixSelfExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: PrefixOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: SelectorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: SelfExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: SubscriptExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: SuperclassExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: TernaryConditionalOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: TryOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: TupleExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: TypeCastingOperatorExpression) throws -> Bool {
    return try visit(expr)
  }

  public func traverse(_ expr: WildcardExpression) throws -> Bool {
    return try visit(expr)
  }
}
