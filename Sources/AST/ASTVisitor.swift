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

public protocol ASTVisitor {
  func visit(_: TopLevelDeclaration) throws -> Bool
  func visit(_: CodeBlock) throws -> Bool

  // Declarations

  func visit(_: ClassDeclaration) throws -> Bool
  func visit(_: ConstantDeclaration) throws -> Bool
  func visit(_: DeinitializerDeclaration) throws -> Bool
  func visit(_: EnumDeclaration) throws -> Bool
  func visit(_: ExtensionDeclaration) throws -> Bool
  func visit(_: FunctionDeclaration) throws -> Bool
  func visit(_: ImportDeclaration) throws -> Bool
  func visit(_: InitializerDeclaration) throws -> Bool
  func visit(_: OperatorDeclaration) throws -> Bool
  func visit(_: PrecedenceGroupDeclaration) throws -> Bool
  func visit(_: ProtocolDeclaration) throws -> Bool
  func visit(_: StructDeclaration) throws -> Bool
  func visit(_: SubscriptDeclaration) throws -> Bool
  func visit(_: TypealiasDeclaration) throws -> Bool
  func visit(_: VariableDeclaration) throws -> Bool

  // Statements

  func visit(_: BreakStatement) throws -> Bool
  func visit(_: CompilerControlStatement) throws -> Bool
  func visit(_: ContinueStatement) throws -> Bool
  func visit(_: DeferStatement) throws -> Bool
  func visit(_: DoStatement) throws -> Bool
  func visit(_: FallthroughStatement) throws -> Bool
  func visit(_: ForInStatement) throws -> Bool
  func visit(_: GuardStatement) throws -> Bool
  func visit(_: IfStatement) throws -> Bool
  func visit(_: LabeledStatement) throws -> Bool
  func visit(_: RepeatWhileStatement) throws -> Bool
  func visit(_: ReturnStatement) throws -> Bool
  func visit(_: SwitchStatement) throws -> Bool
  func visit(_: ThrowStatement) throws -> Bool
  func visit(_: WhileStatement) throws -> Bool

  // Expressions

  func visit(_: AssignmentOperatorExpression) throws -> Bool
  func visit(_: BinaryOperatorExpression) throws -> Bool
  func visit(_: ClosureExpression) throws -> Bool
  func visit(_: DynamicTypeExpression) throws -> Bool
  func visit(_: ExplicitMemberExpression) throws -> Bool
  func visit(_: ForcedValueExpression) throws -> Bool
  func visit(_: FunctionCallExpression) throws -> Bool
  func visit(_: IdentifierExpression) throws -> Bool
  func visit(_: ImplicitMemberExpression) throws -> Bool
  func visit(_: InOutExpression) throws -> Bool
  func visit(_: InitializerExpression) throws -> Bool
  func visit(_: KeyPathExpression) throws -> Bool
  func visit(_: LiteralExpression) throws -> Bool
  func visit(_: OptionalChainingExpression) throws -> Bool
  func visit(_: ParenthesizedExpression) throws -> Bool
  func visit(_: PostfixOperatorExpression) throws -> Bool
  func visit(_: PostfixSelfExpression) throws -> Bool
  func visit(_: PrefixOperatorExpression) throws -> Bool
  func visit(_: SelectorExpression) throws -> Bool
  func visit(_: SelfExpression) throws -> Bool
  func visit(_: SubscriptExpression) throws -> Bool
  func visit(_: SuperclassExpression) throws -> Bool
  func visit(_: TernaryConditionalOperatorExpression) throws -> Bool
  func visit(_: TryOperatorExpression) throws -> Bool
  func visit(_: TupleExpression) throws -> Bool
  func visit(_: TypeCastingOperatorExpression) throws -> Bool
  func visit(_: WildcardExpression) throws -> Bool
}
