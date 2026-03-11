/*
   Copyright 2017, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public struct SequenceExpressionFolding {
  private let _foldingVisitor = FoldingVisitor()

  public init() {}

  public func fold(_ collection: ASTUnitCollection) {
    return collection.forEach(fold)
  }

  private func fold(_ unit: ASTUnit) {
    do {
      _ = try _foldingVisitor.traverse(unit.translationUnit)
      unit.translationUnit.foldedSequenceExpression()
    } catch {}
  }
}

private class FoldingVisitor : ASTVisitor {
  func visit(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
    for i in topLevelDecl.statements.indices {
      if let seqExpr = topLevelDecl.statements[i] as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        topLevelDecl.replaceStatement(at: i, with: foldedExpr)
      }
    }

    return true
  }

  func visit(_ codeBlock: CodeBlock) throws -> Bool {
    for i in codeBlock.statements.indices {
      if let seqExpr = codeBlock.statements[i] as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        codeBlock.replaceStatement(at: i, with: foldedExpr)
      }
    }

    return true
  }

  func visit(_ decl: ConstantDeclaration) throws -> Bool {
    for i in decl.initializerList.indices {
      let pttrnInit = decl.initializerList[i]
      if let seqExpr = pttrnInit.initializerExpression as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        let foldedInit = PatternInitializer(
          pattern: pttrnInit.pattern,
          initializerExpression: foldedExpr)
        decl.replaceInitialize(at: i, with: foldedInit)
      }
    }

    return true
  }

  private func foldFunctionSignature(_ signature: FunctionSignature) -> FunctionSignature {
    let foldedParams = signature.parameterList.map(foldFunctionSignatureParameter)
    return FunctionSignature(
      parameterList: foldedParams,
      isAsync: signature.isAsync,
      throwsKind: signature.throwsKind,
      result: signature.result)
  }

  private func foldFunctionSignatureParameter(
    _ p: FunctionSignature.Parameter
  ) -> FunctionSignature.Parameter {
    guard let seqExpr = p.defaultArgumentClause as? SequenceExpression else {
      return p
    }

    let foldedExpr = foldSequenceExpression(seqExpr)
    return FunctionSignature.Parameter(
      externalName: p.externalName,
      localName: p.localName,
      typeAnnotation: p.typeAnnotation,
      defaultArgumentClause: foldedExpr)
  }

  func visit(_ decl: FunctionDeclaration) throws -> Bool {
    let foldedSignature = foldFunctionSignature(decl.signature)
    decl.replaceSignature(with: foldedSignature)

    return true
  }

  func visit(_ decl: MacroDeclaration) throws -> Bool {
    let foldedSignature = foldFunctionSignature(decl.signature)
    decl.replaceSignature(with: foldedSignature)

    return true
  }

  func visit(_ decl: InitializerDeclaration) throws -> Bool {
    for i in decl.parameterList.indices {
      let p = decl.parameterList[i]
      if let expr = p.defaultArgumentClause, expr is SequenceExpression {
        let foldedParam = foldFunctionSignatureParameter(p)
        decl.replaceParameter(at: i, with: foldedParam)
      }
    }

    return true
  }

  func visit(_ decl: ProtocolDeclaration) throws -> Bool {
    for i in decl.members.indices {
      let member = decl.members[i]
      switch member {
      case .method(let methodMember):
        let foldedSignature = foldFunctionSignature(methodMember.signature)
        let foldedMethodMember = ProtocolDeclaration.MethodMember(
          attributes: methodMember.attributes,
          modifiers: methodMember.modifiers,
          name: methodMember.name,
          genericParameter: methodMember.genericParameter,
          signature: foldedSignature,
          genericWhere: methodMember.genericWhere)
        decl.replaceMember(at: i, with: .method(foldedMethodMember))
      case .initializer(let initMember):
        let foldedParams = initMember.parameterList.map(foldFunctionSignatureParameter)
        let foldedInitMember = ProtocolDeclaration.InitializerMember(
          attributes: initMember.attributes,
          modifiers: initMember.modifiers,
          kind: initMember.kind,
          genericParameter: initMember.genericParameter,
          parameterList: foldedParams,
          isAsync: initMember.isAsync,
          throwsKind: initMember.throwsKind,
          genericWhere: initMember.genericWhere)
        decl.replaceMember(at: i, with: .initializer(foldedInitMember))
      case .subscript(let subscriptMember):
        let foldedParams = subscriptMember.parameterList.map(foldFunctionSignatureParameter)
        let foldedSubscriptMember = ProtocolDeclaration.SubscriptMember(
          attributes: subscriptMember.attributes,
          modifiers: subscriptMember.modifiers,
          genericParameter: subscriptMember.genericParameter,
          parameterList: foldedParams,
          resultAttributes: subscriptMember.resultAttributes,
          resultType: subscriptMember.resultType,
          genericWhere: subscriptMember.genericWhere,
          getterSetterKeywordBlock: subscriptMember.getterSetterKeywordBlock)
        decl.replaceMember(at: i, with: .subscript(foldedSubscriptMember))
      default:
        break
      }
    }

    return true
  }

  func visit(_ decl: SubscriptDeclaration) throws -> Bool {
    for i in decl.parameterList.indices {
      let p = decl.parameterList[i]
      if let expr = p.defaultArgumentClause, expr is SequenceExpression {
        let foldedParam = foldFunctionSignatureParameter(p)
        decl.replaceParameter(at: i, with: foldedParam)
      }
    }

    return true
  }

  func visit(_ decl: VariableDeclaration) throws -> Bool {
    switch decl.body {
    case .initializerList(let inits):
      let foldedInits = inits.map { i -> PatternInitializer in
        if let seqExpr = i.initializerExpression as? SequenceExpression {
          let foldedExpr = foldSequenceExpression(seqExpr)
          return PatternInitializer(
            pattern: i.pattern,
            initializerExpression: foldedExpr)
        } else {
          return i
        }
      }
      decl.replaceBody(with: .initializerList(foldedInits))
    case let .willSetDidSetBlock(id, type, expr, block):
      if let seqExpr = expr as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        decl.replaceBody(with: .willSetDidSetBlock(id, type, foldedExpr, block))
      }
    default:
      break
    }

    return true
  }

  func visit(_ stmt: DoStatement) throws -> Bool {
    for i in stmt.catchClauses.indices {
      let catchClause = stmt.catchClauses[i]
      if let seqExpr = catchClause.whereExpression as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        let foldedCatchClause = DoStatement.CatchClause(
          pattern: catchClause.pattern,
          whereExpression: foldedExpr,
          codeBlock: catchClause.codeBlock)
        stmt.replaceCatchClause(at: i, with: foldedCatchClause)
      }
    }

    return true
  }

  func visit(_ stmt: ForInStatement) throws -> Bool {
    if let collSeqExpr = stmt.collection as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(collSeqExpr)
      stmt.replaceCollection(with: foldedExpr)
    }

    if let whereSeqExpr = stmt.item.whereClause as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(whereSeqExpr)
      stmt.replaceWhereClause(with: foldedExpr)
    }

    return true
  }

  private func foldCondition(_ condition: Condition) -> Condition {
    switch condition {
    case .expression(let expr):
      return .expression(foldExpression(expr))
    case let .case(pttrn, expr):
      return .case(pttrn, foldExpression(expr))
    case let .let(pttrn, expr):
      return .let(pttrn, foldExpression(expr))
    case let .var(pttrn, expr):
      return .var(pttrn, foldExpression(expr))
    default:
      return condition
    }
  }

  func visit(_ stmt: GuardStatement) throws -> Bool {
    for i in stmt.conditionList.indices {
      let condition = stmt.conditionList[i]
      let foldedCondition = foldCondition(condition)
      stmt.replaceCondition(at: i, with: foldedCondition)
    }

    return true
  }

  func visit(_ stmt: IfStatement) throws -> Bool {
    for i in stmt.conditionList.indices {
      let condition = stmt.conditionList[i]
      let foldedCondition = foldCondition(condition)
      stmt.replaceCondition(at: i, with: foldedCondition)
    }

    return true
  }

  func visit(_ stmt: RepeatWhileStatement) throws -> Bool {
    if let seqExpr = stmt.conditionExpression as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(seqExpr)
      stmt.replaceCondition(with: foldedExpr)
    }

    return true
  }

  func visit(_ stmt: ReturnStatement) throws -> Bool {
    if let seqExpr = stmt.expression as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(seqExpr)
      stmt.replaceExpression(with: foldedExpr)
    }

    return true
  }

  private func foldStatements(_ stmts: Statements) -> Statements {
    return stmts.map { stmt -> Statement in
      if let defaultStmtSeqExpr = stmt as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(defaultStmtSeqExpr)
        return foldedExpr
      } else {
        return stmt
      }
    }
  }

  private func foldSwitchCaseItem(_ item: SwitchStatement.Case.Item) -> SwitchStatement.Case.Item {
    var foldedWhereExpression: ASTExpression? = item.whereExpression
    if let whereSeqExpr = item.whereExpression as? SequenceExpression {
      foldedWhereExpression = foldSequenceExpression(whereSeqExpr)
    }

    var foldedPattern = item.pattern
    if let exprPattern = item.pattern as? ExpressionPattern {
      let foldedPatternExpr = foldExpression(exprPattern.expression)
      foldedPattern = ExpressionPattern(expression: foldedPatternExpr)
    }

    return SwitchStatement.Case.Item(
      pattern: foldedPattern, whereExpression: foldedWhereExpression)
  }

  private func foldSwitchCases(_ cases: [SwitchStatement.Case]) -> [SwitchStatement.Case] {
    return cases.map { switchCase in
      switch switchCase {
      case let .case(items, statements):
        let foldedItems = items.map(foldSwitchCaseItem)
        let foldedStatements = foldStatements(statements)
        return .case(foldedItems, foldedStatements)
      case .default(let statements):
        let foldedStatements = foldStatements(statements)
        return .default(foldedStatements)
      case .compilerControl:
        return switchCase
      }
    }
  }

  func visit(_ stmt: SwitchStatement) throws -> Bool {
    if let seqExpr = stmt.expression as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(seqExpr)
      stmt.replaceExpression(with: foldedExpr)
    }

    let foldedCases = foldSwitchCases(stmt.cases)
    for i in foldedCases.indices {
      stmt.replaceCase(at: i, with: foldedCases[i])
    }

    return true
  }

  func visit(_ stmt: ThrowStatement) throws -> Bool {
    if let seqExpr = stmt.expression as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(seqExpr)
      stmt.replaceExpression(with: foldedExpr)
    }

    return true
  }

  func visit(_ stmt: WhileStatement) throws -> Bool {
    for i in stmt.conditionList.indices {
      let condition = stmt.conditionList[i]
      let foldedCondition = foldCondition(condition)
      stmt.replaceCondition(at: i, with: foldedCondition)
    }

    return true
  }

  func visit(_ expr: ClosureExpression) throws -> Bool {

    /*
    if let captureList = expr.signature?.captureList {
      for captureItem in captureList {
        captureItem.expression
        // NOTE: this should never be SequenceExpression, so leave a note, and move on
      }
    }
    */

    if let stmts = expr.statements {
      for i in stmts.indices {
        if let seqExpr = stmts[i] as? SequenceExpression {
          let foldedExpr = foldSequenceExpression(seqExpr)
          expr.replaceStatement(at: i, with: foldedExpr)
        }
      }
    }

    return true
  }

  func visit(_ expr: FunctionCallExpression) throws -> Bool {
    if let argumentList = expr.argumentClause {
      for i in argumentList.indices {
        let argument = argumentList[i]
        switch argument {
        case .expression(let argExpr):
          let foldedExpr = foldExpression(argExpr)
          expr.replaceArgument(at: i, with: .expression(foldedExpr))
        case let .namedExpression(name, argExpr):
          let foldedExpr = foldExpression(argExpr)
          expr.replaceArgument(at: i, with: .namedExpression(name, foldedExpr))
        /*
        // NOTE: should never happen
        case .memoryReference(let argExpr):
          continue
        case .namedMemoryReference(_, let argExpr):
          continue
        */
        default:
          continue
        }
      }
    }

    return true
  }

  func visit(_ expr: MacroExpansionExpression) throws -> Bool {
    if let argumentList = expr.argumentClause {
      for i in argumentList.indices {
        let argument = argumentList[i]
        switch argument {
        case .expression(let argExpr):
          let foldedExpr = foldExpression(argExpr)
          expr.replaceArgument(at: i, with: .expression(foldedExpr))
        case let .namedExpression(name, argExpr):
          let foldedExpr = foldExpression(argExpr)
          expr.replaceArgument(at: i, with: .namedExpression(name, foldedExpr))
        case .memoryReference(let argExpr):
          let foldedExpr = foldExpression(argExpr)
          expr.replaceArgument(at: i, with: .memoryReference(foldedExpr))
        case let .namedMemoryReference(name, argExpr):
          let foldedExpr = foldExpression(argExpr)
          expr.replaceArgument(at: i, with: .namedMemoryReference(name, foldedExpr))
        default:
          continue
        }
      }
    }

    return true
  }

  func visit(_ expr: IfExpression) throws -> Bool {
    for i in expr.conditionList.indices {
      let condition = expr.conditionList[i]
      let foldedCondition = foldCondition(condition)
      expr.replaceCondition(at: i, with: foldedCondition)
    }

    return true
  }

  func visit(_ expr: LiteralExpression) throws -> Bool {
    switch expr.kind {
    case let .interpolatedString(segments, str):
      let foldedSegments: [InterpolationSegment] = segments.map { segment in
        guard case .interpolation(let args) = segment else { return segment }
        let foldedArgs: FunctionCallExpression.ArgumentList = args.map { arg in
          switch arg {
          case .expression(let argExpr):
            return .expression(foldExpression(argExpr))
          case let .namedExpression(name, argExpr):
            return .namedExpression(name, foldExpression(argExpr))
          case .memoryReference(let argExpr):
            return .memoryReference(foldExpression(argExpr))
          case let .namedMemoryReference(name, argExpr):
            return .namedMemoryReference(name, foldExpression(argExpr))
          case .operator, .namedOperator:
            return arg
          }
        }
        return .interpolation(foldedArgs)
      }
      expr.reset(with: .interpolatedString(foldedSegments, str))
    case .array(let exprs):
      let foldedExprs = exprs.map(foldExpression)
      expr.reset(with: .array(foldedExprs))
    case .dictionary(let dictEntries):
      let foldedEntries = dictEntries.map { e -> DictionaryEntry in
        let foldedKey = foldExpression(e.key)
        let foldedValue = foldExpression(e.value)
        return DictionaryEntry(key: foldedKey, value: foldedValue)
      }
      expr.reset(with: .dictionary(foldedEntries))
    default:
      break
    }

    return true
  }

  func visit(_ expr: ParenthesizedExpression) throws -> Bool {
    let foldedExpr = foldExpression(expr.expression)
    expr.reset(with: foldedExpr)

    return true
  }

  func visit(_ expr: SelfExpression) throws -> Bool {
    if case .subscript(let arguments) = expr.kind {
      let foldedArguments = arguments.map { a -> SubscriptArgument in
        let foldedExpr = foldExpression(a.expression)
        return SubscriptArgument(identifier: a.identifier, expression: foldedExpr)
      }
      expr.reset(with: .subscript(foldedArguments))
    }

    return true
  }

  func visit(_ expr: SuperclassExpression) throws -> Bool {
    if case .subscript(let arguments) = expr.kind {
      let foldedArguments = arguments.map { a -> SubscriptArgument in
        let foldedExpr = foldExpression(a.expression)
        return SubscriptArgument(identifier: a.identifier, expression: foldedExpr)
      }
      expr.reset(with: .subscript(foldedArguments))
    }

    return true
  }

  func visit(_ expr: SwitchExpression) throws -> Bool {
    if let seqExpr = expr.expression as? SequenceExpression {
      let foldedExpr = foldSequenceExpression(seqExpr)
      expr.replaceExpression(with: foldedExpr)
    }

    let foldedCases = foldSwitchCases(expr.cases)
    for i in foldedCases.indices {
      expr.replaceCase(at: i, with: foldedCases[i])
    }

    return true
  }

  func visit(_ expr: SubscriptExpression) throws -> Bool {
    for i in expr.arguments.indices {
      let arg = expr.arguments[i]
      let foldedExpr = foldExpression(arg.expression)
      let foldedArg = SubscriptArgument(identifier: arg.identifier, expression: foldedExpr)
      expr.replaceArgument(at: i, with: foldedArg)
    }

    return true
  }

  func visit(_ expr: AwaitExpression) throws -> Bool {
    let foldedExpr = foldExpression(expr.expression)
    expr.replaceExpression(with: foldedExpr)
    return true
  }

  func visit(_ expr: TryOperatorExpression) throws -> Bool {
    switch expr.kind {
    case .try(let expression):
      let foldedExpr = foldExpression(expression)
      expr.reset(with: .try(foldedExpr))
    case .forced(let expression):
      let foldedExpr = foldExpression(expression)
      expr.reset(with: .forced(foldedExpr))
    case .optional(let expression):
      let foldedExpr = foldExpression(expression)
      expr.reset(with: .optional(foldedExpr))
    }

    return true
  }

  func visit(_ expr: TupleExpression) throws -> Bool {
    for i in expr.elementList.indices {
      let element = expr.elementList[i]
      let foldedExpr = foldExpression(element.expression)
      let foldedElement = TupleExpression.Element(
        identifier: element.identifier, expression: foldedExpr)
      expr.replaceElement(at: i, with: foldedElement)
    }

    return true
  }

  func visit(_ seqExpr: SequenceExpression) throws -> Bool {
    debugPrint("Shouldn't see SequenceExpression in SequenceExpressionFolding.FoldVisitor")
    if let lexicalParentDescription = seqExpr.lexicalParent?.textDescription {
      debugPrint(lexicalParentDescription)
    }

    return true
  }
}

private func foldElements(
  _ elements: [SequenceExpression.Element],
  forBinaryOperators biOps: [String]
) -> [SequenceExpression.Element] {
  guard elements.count >= 3 else {
    return elements
  }

  var resultElements: [SequenceExpression.Element] = []

  var i = 0
  while i < elements.count {
    let e = elements[i]
    if case .binaryOperator(let op) = e,
      biOps.contains(op),
      case .expression(let lhs)? = resultElements.last,
      case .expression(let rhs) = elements[i+1]
    {
      resultElements.removeLast()
      let biOpExpr = BinaryOperatorExpression(
        binaryOperator: op,
        leftExpression: lhs,
        rightExpression: rhs)
      biOpExpr.setSourceRange(lhs.sourceRange.start, rhs.sourceRange.end)
      resultElements.append(.expression(biOpExpr))
      i += 1
    } else {
      resultElements.append(e)
    }
    i += 1
  }

  return resultElements
}

private func foldElementsForTypeCasting(
  _ elements: [SequenceExpression.Element]
) -> [SequenceExpression.Element] {
  guard elements.count >= 2 else {
    return elements
  }

  var resultElements: [SequenceExpression.Element] = []

  var i = 0
  while i < elements.count {
    let e = elements[i]
    if case .expression(let expr)? = resultElements.last {
      switch e {
      case .typeCheck(let t):
        resultElements.removeLast()
        let typeCastingOpExpr = TypeCastingOperatorExpression(kind: .check(expr, t))
        typeCastingOpExpr.setSourceRange(expr.sourceRange.start, t.sourceRange.end)
        resultElements.append(.expression(typeCastingOpExpr))
      case .typeCast(let t):
        resultElements.removeLast()
        let typeCastingOpExpr = TypeCastingOperatorExpression(kind: .cast(expr, t))
        typeCastingOpExpr.setSourceRange(expr.sourceRange.start, t.sourceRange.end)
        resultElements.append(.expression(typeCastingOpExpr))
      case .typeConditionalCast(let t):
        resultElements.removeLast()
        let typeCastingOpExpr = TypeCastingOperatorExpression(kind: .conditionalCast(expr, t))
        typeCastingOpExpr.setSourceRange(expr.sourceRange.start, t.sourceRange.end)
        resultElements.append(.expression(typeCastingOpExpr))
      case .typeForcedCast(let t):
        resultElements.removeLast()
        let typeCastingOpExpr = TypeCastingOperatorExpression(kind: .forcedCast(expr, t))
        typeCastingOpExpr.setSourceRange(expr.sourceRange.start, t.sourceRange.end)
        resultElements.append(.expression(typeCastingOpExpr))
      default:
        resultElements.append(e)
      }
    } else {
      resultElements.append(e)
    }

    i += 1
  }

  return resultElements
}

private func foldElementsForTernary(
  _ elements: [SequenceExpression.Element]
) -> [SequenceExpression.Element] {
  guard elements.count >= 3 else {
    return elements
  }

  var resultElements: [SequenceExpression.Element] = []

  var i = 0
  while i < elements.count {
    let e = elements[i]
    if case .ternaryConditionalOperator(let trueExpr) = e,
      case .expression(let condExpr)? = resultElements.last,
      case .expression(let falseExpr) = elements[i+1]
    {
      resultElements.removeLast()
      let assignOpExpr = TernaryConditionalOperatorExpression(
        conditionExpression: condExpr,
        trueExpression: trueExpr,
        falseExpression: falseExpr)
      assignOpExpr.setSourceRange(
        condExpr.sourceRange.start, falseExpr.sourceRange.end)
      resultElements.append(.expression(assignOpExpr))
      i += 1
    } else {
      resultElements.append(e)
    }

    i += 1
  }

  return resultElements
}

private func foldElementsForAssignment(
  _ elements: [SequenceExpression.Element]
) -> [SequenceExpression.Element] {
  guard elements.count >= 3 else {
    return elements
  }

  var resultElements: [SequenceExpression.Element] = []

  var i = 0
  while i < elements.count {
    let e = elements[i]
    if case .assignmentOperator = e,
      case .expression(let lhs)? = resultElements.last,
      case .expression(let rhs) = elements[i+1]
    {
      resultElements.removeLast()
      let assignOpExpr = AssignmentOperatorExpression(
        leftExpression: lhs,
        rightExpression: rhs)
      assignOpExpr.setSourceRange(lhs.sourceRange.start, rhs.sourceRange.end)
      resultElements.append(.expression(assignOpExpr))
      i += 1
    } else {
      resultElements.append(e)
    }

    i += 1
  }

  return resultElements
}


private func foldElementsForDefault(
  _ elements: [SequenceExpression.Element]
) -> [SequenceExpression.Element] {
  guard elements.count >= 3 else {
    return elements
  }

  let assignOps = ["*=", "/=", "%=", "+=", "-=", "<<=", ">>=", "&=", "^=", "|="]

  var resultElements: [SequenceExpression.Element] = []

  var i = 0
  while i < elements.count {
    let e = elements[i]
    if case .binaryOperator(let op) = e,
      !assignOps.contains(op),
      case .expression(let lhs)? = resultElements.last,
      case .expression(let rhs) = elements[i+1]
    {
      resultElements.removeLast()
      let biOpExpr = BinaryOperatorExpression(
        binaryOperator: op,
        leftExpression: lhs,
        rightExpression: rhs)
      biOpExpr.setSourceRange(lhs.sourceRange.start, rhs.sourceRange.end)
      resultElements.append(.expression(biOpExpr))
      i += 1
    } else {
      resultElements.append(e)
    }
    i += 1
  }

  return resultElements
}

private func foldElementsContainSeqExpr(
  _ elements: [SequenceExpression.Element]
) -> [SequenceExpression.Element] {
  return elements.map { e in
    switch e {
    case .expression(let expr):
      if let seqExpr = expr as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        return .expression(foldedExpr)
      } else {
        return e
      }
    case .ternaryConditionalOperator(let expr):
      if let seqExpr = expr as? SequenceExpression {
        let foldedExpr = foldSequenceExpression(seqExpr)
        return .ternaryConditionalOperator(foldedExpr)
      } else {
        return e
      }
    default:
      return e
    }
  }
}

private func foldSequenceExpression(_ seqExpr: SequenceExpression) -> ASTExpression {
  // Start with brutal hardcoding approach

  var resultElements = foldElementsContainSeqExpr(seqExpr.elements)
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["<<", ">>"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["*", "&*", "/", "%", "&"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["+", "&+", "-", "&-", "|", "^"])
  resultElements = foldElements(resultElements, forBinaryOperators: ["...", "..<"])
  resultElements = foldElementsForTypeCasting(resultElements)
  resultElements = foldElements(resultElements, forBinaryOperators: ["??"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["<", "<=", ">", ">=", "==", "!=", "===", "!==", "~=",])
  resultElements = foldElements(resultElements, forBinaryOperators: ["&&"])
  resultElements = foldElements(resultElements, forBinaryOperators: ["||"])
  resultElements = foldElementsForDefault(resultElements)
  resultElements = foldElementsForTernary(resultElements)
  resultElements = foldElementsForAssignment(resultElements)
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["*=", "/=", "%=", "+=", "-=", "<<=", ">>=", "&=", "^=", "|=",])

  guard resultElements.count == 1,
    case .expression(let resultExpr) = resultElements[0]
  else {
    fatalError("Failed in folding sequence expression `\(seqExpr)`.")
  }

  return resultExpr
}

private func foldExpression(_ expr: ASTExpression) -> ASTExpression {
  guard let seqExpr = expr as? SequenceExpression else {
    return expr
  }
  return foldSequenceExpression(seqExpr)
}
