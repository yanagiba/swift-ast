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

    for stmt in topLevelDecl.statements {
      guard try traverse(stmt) else { return false }
    }

    return true
  }

  public func traverse(_ codeBlock: CodeBlock) throws -> Bool {
    guard try visit(codeBlock) else { return false }

    for stmt in codeBlock.statements {
      guard try traverse(stmt) else { return false }
    }

    return true
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
    return try visit(decl)
  }

  public func traverse(_ decl: ConstantDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: DeinitializerDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: EnumDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: ExtensionDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: FunctionDeclaration) throws -> Bool {
    return try visit(decl)
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
    return try visit(decl)
  }

  public func traverse(_ decl: StructDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: SubscriptDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: TypealiasDeclaration) throws -> Bool {
    return try visit(decl)
  }

  public func traverse(_ decl: VariableDeclaration) throws -> Bool {
    return try visit(decl)
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
    return try visit(stmt)
  }

  public func traverse(_ stmt: DoStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: FallthroughStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: ForInStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: GuardStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: IfStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: LabeledStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: RepeatWhileStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: ReturnStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: SwitchStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: ThrowStatement) throws -> Bool {
    return try visit(stmt)
  }

  public func traverse(_ stmt: WhileStatement) throws -> Bool {
    return try visit(stmt)
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
