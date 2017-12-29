/*
   Copyright 2016-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import Foundation
import AST
import Lexer
import Source

public struct ParserExpressionConfig {
  var parseTrailingClosure: Bool

  public init(parseTrailingClosure: Bool = true) {
    self.parseTrailingClosure = parseTrailingClosure
  }
}

extension Parser {
  private func parseExpressionList(
    config: ParserExpressionConfig = ParserExpressionConfig()
  ) throws -> ExpressionList {
    var exprs: [Expression] = []
    repeat {
      let expr = try parseExpression(config: config)
      exprs.append(expr)
    } while _lexer.match(.comma)
    return exprs
  }

  func parseExpression(
    config: ParserExpressionConfig = ParserExpressionConfig()
  ) throws -> Expression {
    let tryKind = parseTryKind()
    let prefixExpr = try parsePrefixExpression(config: config)
    let expr = try parseBinaryExpressions(
      leftExpression: prefixExpr, config: config)
    return tryKind.wrap(expr: expr)
  }

  private enum TryKind {
    case `try`(SourceLocation)
    case forcedTry(SourceLocation)
    case optionalTry(SourceLocation)
    case noTry

    fileprivate func wrap(expr: Expression) -> Expression {
      switch self {
      case .try(let startLocation):
        let tryOpExpr = TryOperatorExpression(kind: .try(expr))
        tryOpExpr.setSourceRange(startLocation, expr.sourceRange.end)
        return tryOpExpr
      case .forcedTry(let startLocation):
        let tryOpExpr = TryOperatorExpression(kind: .forced(expr))
        tryOpExpr.setSourceRange(startLocation, expr.sourceRange.end)
        return tryOpExpr
      case .optionalTry(let startLocation):
        let tryOpExpr = TryOperatorExpression(kind: .optional(expr))
        tryOpExpr.setSourceRange(startLocation, expr.sourceRange.end)
        return tryOpExpr
      default:
        return expr
      }
    }
  }

  private func parseTryKind() -> TryKind {
    let startLocation = getStartLocation()
    guard _lexer.match(.try) else {
      return .noTry
    }
    if _lexer.match(.postfixExclaim) {
      return .forcedTry(startLocation)
    } else if _lexer.match(.postfixQuestion) {
      return .optionalTry(startLocation)
    } else {
      return .try(startLocation)
    }
  }

  private func parseBinaryExpressions( // swift-lint:suppress(high_ncss,high_cyclomatic_complexity)
    leftExpression: Expression, config: ParserExpressionConfig
  ) throws -> Expression {
    var resultExpr: Expression = leftExpression

    func examine() -> (Bool, Token.Kind) {
      let potentialBinaryTokens: [Token.Kind] = [
        .dummyBinaryOperator,
        .assignmentOperator,
        .binaryQuestion,
        .is,
        .as,
      ]
      return self._lexer.examine(potentialBinaryTokens)
    }

    func append(_ biExpr: BinaryExpression) { /*
      swift-lint:suppress(high_ncss,high_cyclomatic_complexity,high_npath_complexity)
      */
      var elements = [SequenceExpression.Element]()
      var startLocation: SourceLocation?
      var endLocation: SourceLocation?

      switch resultExpr {
      case let biOp as BinaryOperatorExpression:
        elements.append(.expression(biOp.leftExpression))
        elements.append(.binaryOperator(biOp.binaryOperator))
        elements.append(.expression(biOp.rightExpression))
        startLocation = biOp.sourceRange.start
      case let assignOp as AssignmentOperatorExpression:
        elements.append(.expression(assignOp.leftExpression))
        elements.append(.assignmentOperator)
        elements.append(.expression(assignOp.rightExpression))
        startLocation = assignOp.sourceRange.start
      case let condOp as TernaryConditionalOperatorExpression:
        elements.append(.expression(condOp.conditionExpression))
        elements.append(.ternaryConditionalOperator(condOp.trueExpression))
        elements.append(.expression(condOp.falseExpression))
        startLocation = condOp.sourceRange.start
      case let castingOp as TypeCastingOperatorExpression:
        switch castingOp.kind {
        case let .check(expr, type):
          elements.append(.expression(expr))
          elements.append(.typeCheck(type))
        case let .cast(expr, type):
          elements.append(.expression(expr))
          elements.append(.typeCast(type))
        case let .conditionalCast(expr, type):
          elements.append(.expression(expr))
          elements.append(.typeConditionalCast(type))
        case let .forcedCast(expr, type):
          elements.append(.expression(expr))
          elements.append(.typeForcedCast(type))
        }
        startLocation = castingOp.sourceRange.start
      case let seqExpr as SequenceExpression:
        elements = seqExpr.elements
        startLocation = seqExpr.sourceRange.start
      default:
        break
      }

      switch biExpr {
      case let biOp as BinaryOperatorExpression:
        elements.append(.binaryOperator(biOp.binaryOperator))
        elements.append(.expression(biOp.rightExpression))
        endLocation = biOp.sourceRange.end
      case let assignOp as AssignmentOperatorExpression:
        elements.append(.assignmentOperator)
        elements.append(.expression(assignOp.rightExpression))
        endLocation = assignOp.sourceRange.end
      case let condOp as TernaryConditionalOperatorExpression:
        elements.append(.ternaryConditionalOperator(condOp.trueExpression))
        elements.append(.expression(condOp.falseExpression))
        endLocation = condOp.sourceRange.end
      case let castingOp as TypeCastingOperatorExpression:
        switch castingOp.kind {
        case .check(_, let type):
          elements.append(.typeCheck(type))
        case .cast(_, let type):
          elements.append(.typeCast(type))
        case .conditionalCast(_, let type):
          elements.append(.typeConditionalCast(type))
        case .forcedCast(_, let type):
          elements.append(.typeForcedCast(type))
        }
        endLocation = castingOp.sourceRange.end
      default:
        break
      }

      if resultExpr is BinaryOperatorExpression && biExpr is AssignmentOperatorExpression {
        // Note: directly take the assignment-operator-expr form for cases such as `case a..<b = foo`
        resultExpr = biExpr
      } else if !elements.isEmpty, let start = startLocation, let end = endLocation {
        let seqExpr = SequenceExpression(elements: elements)
        seqExpr.setSourceRange(start, end)
        resultExpr = seqExpr
      } else {
        resultExpr = biExpr
      }
    }

    var examined = examine()
    while examined.0 {
      switch examined.1 {
      case .binaryOperator(let op):
        let rhs = try parsePrefixExpression(config: config)
        let biOpExpr = BinaryOperatorExpression(
          binaryOperator: op, leftExpression: resultExpr, rightExpression: rhs)
        biOpExpr.setSourceRange(resultExpr.sourceRange.start, rhs.sourceRange.end)
        append(biOpExpr)
      case .assignmentOperator:
        let tryKind = parseTryKind()
        let prefixExpr = try parsePrefixExpression(config: config)
        let rhs = tryKind.wrap(expr: prefixExpr)
        let assignOpExpr = AssignmentOperatorExpression(
          leftExpression: resultExpr, rightExpression: rhs)
        assignOpExpr.setSourceRange(resultExpr.sourceRange.start, prefixExpr.sourceRange.end)
        append(assignOpExpr)
      case .binaryQuestion:
        let trueTryKind = parseTryKind()
        var trueExpr = try parseExpression(config: config)
        trueExpr = trueTryKind.wrap(expr: trueExpr)
        guard _lexer.match(.colon) else {
          throw _raiseFatal(.expectedColonAfterTrueExpr)
        }
        let falseTryKind = parseTryKind()
        var falseExpr: Expression = try parsePrefixExpression(config: config)
        falseExpr = falseTryKind.wrap(expr: falseExpr)
        let ternaryOpExpr = TernaryConditionalOperatorExpression(
          conditionExpression: resultExpr,
          trueExpression: trueExpr,
          falseExpression: falseExpr)
        ternaryOpExpr.setSourceRange(resultExpr.sourceRange.start, falseExpr.sourceRange.end)
        append(ternaryOpExpr)
      case .is:
        let type = try parseType()
        let typeCastingOpExpr =
          TypeCastingOperatorExpression(kind: .check(resultExpr, type))
        typeCastingOpExpr.setSourceRange(resultExpr.sourceRange.start, type.sourceRange.end)
        append(typeCastingOpExpr)
      case .as:
        switch _lexer.read([.postfixQuestion, .postfixExclaim]) {
        case .postfixQuestion:
          let type = try parseType()
          let typeCastingOpExpr = TypeCastingOperatorExpression(
            kind: .conditionalCast(resultExpr, type))
          typeCastingOpExpr.setSourceRange(resultExpr.sourceRange.start, type.sourceRange.end)
          append(typeCastingOpExpr)
        case .postfixExclaim:
          let type = try parseType()
          let typeCastingOpExpr =
            TypeCastingOperatorExpression(kind: .forcedCast(resultExpr, type))
          typeCastingOpExpr.setSourceRange(resultExpr.sourceRange.start, type.sourceRange.end)
          append(typeCastingOpExpr)
        default:
          let type = try parseType()
          let typeCastingOpExpr =
            TypeCastingOperatorExpression(kind: .cast(resultExpr, type))
          typeCastingOpExpr.setSourceRange(resultExpr.sourceRange.start, type.sourceRange.end)
          append(typeCastingOpExpr)
        }
      default:
        break
      }

      examined = examine()
    }

    return resultExpr
  }

  private func parsePrefixExpression(
    config: ParserExpressionConfig
  ) throws -> Expression {
    let startLocation = getStartLocation()
    switch _lexer.read([.dummyPrefixOperator, .prefixAmp]) {
    case let .prefixOperator(op):
      let postfixExpr = try parsePostfixExpression(config: config)
      let prefixOpExpr = PrefixOperatorExpression(
        prefixOperator: op, postfixExpression: postfixExpr)
      prefixOpExpr.setSourceRange(startLocation, postfixExpr.sourceRange.end)
      return prefixOpExpr
    case .prefixAmp:
      let endLocation = getEndLocation()
      guard case let .identifier(name) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.expectedIdentifierForInOutExpr)
      }
      let inoutExpr = InOutExpression(identifier: name)
      inoutExpr.setSourceRange(startLocation, endLocation)
      return inoutExpr
    default:
      return try parsePostfixExpression(config: config)
    }
  }

  private func parsePostfixExpression( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    config: ParserExpressionConfig
  ) throws -> PostfixExpression {
    var resultExpr: PostfixExpression = try parsePrimaryExpression()

    let examine: () -> (Bool, Token.Kind) = {
      let allQnE = self.splitTrailingExclaimsAndQuestions()
      if !allQnE.isEmpty {
        for p in allQnE {
          if p == "!" {
            let vlExpr = ForcedValueExpression(postfixExpression: resultExpr)
            vlExpr.setSourceRange(
              resultExpr.sourceRange.start,
              resultExpr.sourceRange.end.nextColumn)
            resultExpr = vlExpr
          } else if p == "?" {
            let optExpr =
              OptionalChainingExpression(postfixExpression: resultExpr)
            optExpr.setSourceRange(
              resultExpr.sourceRange.start,
              resultExpr.sourceRange.end.nextColumn)
            resultExpr = optExpr
          }
        }
      }

      var tokens: [Token.Kind] = [
        .dummyPostfixOperator,
        .leftParen,
        .dot,
        .postfixExclaim,
        .postfixQuestion,
      ]

      let hasNewLineInBetween = self._lexer.lookLineFeed()

      if !hasNewLineInBetween {
        tokens.append(.leftSquare)
      }

      if !hasNewLineInBetween &&
        self._lexer.look().kind == .leftBrace &&
        config.parseTrailingClosure &&
        self.isPotentialTrailingClosure()
      {
        tokens.append(.leftBrace)
      }

      return self._lexer.examine(tokens)
    }

    var tokenRange = getLookedRange()
    var examined = examine()
    while examined.0 {
      switch examined.1 {
      case .postfixOperator(let op):
        let postfixOpExpr = PostfixOperatorExpression(
          postfixOperator: op, postfixExpression: resultExpr)
        postfixOpExpr.setSourceRange(resultExpr.sourceRange.start, tokenRange.end)
        resultExpr = postfixOpExpr
      case .leftParen:
        resultExpr = try parseFunctionCallExpression(
          postfixExpression: resultExpr, config: config)
      case .dot:
        resultExpr =
          try parsePostfixMemberExpression(postfixExpression: resultExpr)
      case .leftSquare:
        let subscriptArguments = try parseSubscriptArguments()
        let endLocation = getEndLocation()
        if !_lexer.match(.rightSquare) {
          throw _raiseFatal(.expectedCloseSquareExprList)
        }
        let subscriptExpr = SubscriptExpression(
        postfixExpression: resultExpr, arguments: subscriptArguments)
        subscriptExpr.setSourceRange(resultExpr.sourceRange.start, endLocation)
        resultExpr = subscriptExpr
      case .postfixExclaim:
        let vlExpr = ForcedValueExpression(postfixExpression: resultExpr)
        vlExpr.setSourceRange(resultExpr.sourceRange.start, tokenRange.end)
        resultExpr = vlExpr
      case .postfixQuestion:
        let optExpr =
          OptionalChainingExpression(postfixExpression: resultExpr)
        optExpr.setSourceRange(resultExpr.sourceRange.start, tokenRange.end)
        resultExpr = optExpr
      case .leftBrace:
        let trailingClosure = try parseClosureExpression(startLocation: tokenRange.start)
        let funcCallExpr = FunctionCallExpression(
          postfixExpression: resultExpr, trailingClosure: trailingClosure)
        funcCallExpr.setSourceRange(
          resultExpr.sourceRange.start, trailingClosure.sourceRange.end)
        resultExpr = funcCallExpr
      default:
        break
      }

      tokenRange = getLookedRange()
      examined = examine()
    }

    return resultExpr
  }

  private func parseFunctionCallExpression( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    postfixExpression expr: PostfixExpression, config: ParserExpressionConfig
  ) throws -> PostfixExpression { // swift-lint:suppress(nested_code_block_depth)
    func parseArgumentExpr(op: Operator) -> Expression? {
      let exprLexerCp = _lexer.checkPoint()
      let exprDiagnosticCp = _diagnosticPool.checkPoint()
      do {
        return try parseExpression()
      } catch {
        _lexer.restore(fromCheckpoint: exprLexerCp)
        _diagnosticPool.restore(fromCheckpoint: exprDiagnosticCp)
        return nil
      }
    }

    func parseArgumentList() throws -> FunctionCallExpression.ArgumentList {
      var arguments: FunctionCallExpression.ArgumentList = []
      let appendArgument = { (op: Operator, id: Identifier?) -> Void in
        switch (parseArgumentExpr(op: op), id) {
        case (let argExpr?, let s?):
          arguments.append(FunctionCallExpression.Argument.namedExpression(s, argExpr))
        case (nil, let s?):
          arguments.append(FunctionCallExpression.Argument.namedOperator(s, op))
          self._lexer.advance()
        case (let argExpr?, nil):
          arguments.append(FunctionCallExpression.Argument.expression(argExpr))
        case (nil, nil):
          arguments.append(FunctionCallExpression.Argument.operator(op))
          self._lexer.advance()
        }
      }

      repeat {
        if _lexer.look(ahead: 1).kind == .colon && _lexer.look().kind != .leftSquare {
          guard let id = _lexer.readNamedIdentifier() else {
            throw _raiseFatal(.expectedParameterNameFuncCall)
          }
          _lexer.advance()
          switch _lexer.read(.prefixAmp) {
          case .prefixAmp:
            let argExpr = try parseExpression(config: config)
            let argument: FunctionCallExpression.Argument =
              .namedMemoryReference(id, argExpr)
            arguments.append(argument)
          case .prefixOperator(let op),
            .binaryOperator(let op),
            .postfixOperator(let op):
            appendArgument(op, id)
          default:
            let argExpr = try parseExpression()
            let argument: FunctionCallExpression.Argument =
              .namedExpression(id, argExpr)
            arguments.append(argument)
          }
        } else {
          switch _lexer.read(.prefixAmp) {
          case .prefixAmp:
            let argExpr = try parseExpression(config: config)
            let argument: FunctionCallExpression.Argument =
              .memoryReference(argExpr)
            arguments.append(argument)
          case .prefixOperator(let op),
            .binaryOperator(let op),
            .postfixOperator(let op):
            appendArgument(op, nil)
          default:
            let argExpr = try parseExpression()
            let argument = FunctionCallExpression.Argument.expression(argExpr)
            arguments.append(argument)
          }
        }
      } while _lexer.match(.comma)
      return arguments
    }

    var endLocation = getEndLocation()
    if _lexer.match(.rightParen) {
      let funcCallExpr: FunctionCallExpression
      if config.parseTrailingClosure &&
        _lexer.look().kind == .leftBrace &&
        isPotentialTrailingClosure()
      {
        let closureStartLocation = getStartLocation()
        _lexer.advance()
        let trailingClosure =
          try parseClosureExpression(startLocation: closureStartLocation)
        endLocation = trailingClosure.sourceRange.end
        funcCallExpr = FunctionCallExpression(
          postfixExpression: expr,
          argumentClause: [],
          trailingClosure: trailingClosure)
      } else {
        funcCallExpr = FunctionCallExpression(
          postfixExpression: expr, argumentClause: [])
      }
      funcCallExpr.setSourceRange(expr.sourceRange.start, endLocation)
      return funcCallExpr
    }

    let argumentList = try parseArgumentList()

    endLocation = getEndLocation()
    if !_lexer.match(.rightParen) {
        throw _raiseFatal(.expectedCloseParenFuncCall)
    }

    let funcCallExpr: FunctionCallExpression
    if config.parseTrailingClosure &&
      _lexer.look().kind == .leftBrace &&
      isPotentialTrailingClosure()
    {
      let closureStartLocation = getStartLocation()
      _lexer.advance()
      let trailingClosure =
        try parseClosureExpression(startLocation: closureStartLocation)
      endLocation = trailingClosure.sourceRange.end
      funcCallExpr = FunctionCallExpression(
        postfixExpression: expr,
        argumentClause: argumentList,
        trailingClosure: trailingClosure)
    } else {
      funcCallExpr = FunctionCallExpression(
        postfixExpression: expr, argumentClause: argumentList)
    }
    funcCallExpr.setSourceRange(expr.sourceRange.start, endLocation)
    return funcCallExpr
  }

  private func isArgumentNames() -> Bool {
    guard _lexer.look().kind == .leftParen else {
      return false
    }
    if _lexer.look(ahead: 1).kind == .rightParen {
      return false
    }
    var lookAhead = 1
    while true {
      let aheadToken = _lexer.look(ahead: lookAhead).kind
      if aheadToken == .rightParen {
        return true
      } else if aheadToken.namedIdentifierOrWildcard != nil &&
        _lexer.look(ahead: lookAhead + 1).kind == .colon
      {
        lookAhead += 2
      } else {
        return false
      }
    }
  }

  private func parseArgumentNames() throws -> ([String], SourceRange)? {
    guard isArgumentNames() else {
      return nil
    }
    let startLocation = getStartLocation()
    guard _lexer.match(.leftParen) else {
      return nil
    }
    var endLocation: SourceLocation
    var argumentNames = [String]()
    repeat {
      guard let argumentName = _lexer.readNamedIdentifierOrWildcard() else {
        throw _raiseFatal(.expectedArgumentLabel)
      }
      guard _lexer.match(.colon) else {
        throw _raiseFatal(.expectedColonAfterArgumentLabel)
      }
      argumentNames.append(argumentName)
      endLocation = getEndLocation()
    } while !_lexer.match(.rightParen)
    return (argumentNames, SourceRange(start: startLocation, end: endLocation))
  }

  private func parsePostfixMemberExpression( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    postfixExpression expr: PostfixExpression
  ) throws -> PostfixExpression {
    func getTupleIndex() -> (Int, Int)? {
      let digitCp = _lexer.checkPoint()
      var digitStr = ""
      while let look = _lexer.lookUnicodeScalar() {
        switch look {
        case "0"..."9":
          digitStr += String(look)
          _lexer.advanceChar()
        case ".":
          if let index = Int(digitStr) {
            return (index, digitStr.count)
          } else {
            _lexer.restore(fromCheckpoint: digitCp)
            return nil
          }
        default:
          _lexer.restore(fromCheckpoint: digitCp)
          return nil
        }
      }

      _lexer.restore(fromCheckpoint: digitCp)
      return nil
    }

    let startLocation = expr.sourceRange.start
    var endLocation = expr.sourceRange.end

    if let (index, advancedBy) = getTupleIndex() {
      for _ in 0...advancedBy {
        endLocation = endLocation.nextColumn
      }
      let memberExpr = ExplicitMemberExpression(kind: .tuple(expr, index))
      memberExpr.setSourceRange(startLocation, endLocation)
      return memberExpr
    }

    endLocation = getEndLocation()
    switch _lexer.read([
      .init,
      .self,
      .dummyIntegerLiteral,
      .dummyFloatingPointLiteral,
    ]) {
    case .init:
      var argumentNames: [String] = []
      if let (argNames, argSrcRange) = try parseArgumentNames() {
        argumentNames = argNames
        endLocation = argSrcRange.end
      }
      let initExpr = InitializerExpression(
        postfixExpression: expr, argumentNames: argumentNames)
      initExpr.setSourceRange(expr.sourceRange.start, endLocation)
      return initExpr
    case let .integerLiteral(index, raw) where raw.containOnlyPositiveDecimals:
      let memberExpr = ExplicitMemberExpression(kind: .tuple(expr, index))
      memberExpr.setSourceRange(startLocation, endLocation)
      return memberExpr
    case .floatingPointLiteral(_, let raw):
      guard let (first, second) = splitDoubleRawToTwoIntegers(raw) else {
        throw _raiseFatal(.expectedTupleIndexExplicitMemberExpr)
      }
      let firstExplitMemberExpr =
        ExplicitMemberExpression(kind: .tuple(expr, first))
      return ExplicitMemberExpression(
        kind: .tuple(firstExplitMemberExpr, second))
    case .self:
      let postfixSelfExpr = PostfixSelfExpression(postfixExpression: expr)
      postfixSelfExpr.setSourceRange(expr.sourceRange.start, endLocation)
      return postfixSelfExpr
    default:
      endLocation = getEndLocation()
      guard let id = _lexer.readNamedIdentifier() else {
        throw _raiseFatal(.expectedMemberNameExplicitMemberExpr)
      }

      let memberExpr: ExplicitMemberExpression
      if let genericArgumentClause = parseGenericArgumentClause() {
        endLocation = genericArgumentClause.sourceRange.end
        memberExpr = ExplicitMemberExpression(
          kind: .generic(expr, id, genericArgumentClause))
      } else if let (argumentNames, argRange) = try parseArgumentNames() {
        endLocation = argRange.end
        memberExpr = ExplicitMemberExpression(
          kind: .argument(expr, id, argumentNames))
      } else {
        memberExpr = ExplicitMemberExpression(kind: .namedType(expr, id))
      }
      memberExpr.setSourceRange(startLocation, endLocation)
      return memberExpr
    }
  }

  private func parsePrimaryExpression() throws -> PrimaryExpression { /*
    swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    */
    let lookedRange = getLookedRange()
    let matched = _lexer.read([
      .dummyImplicitParameterName,
      .dummyIntegerLiteral,
      .dummyFloatingPointLiteral,
      .dummyStaticStringLiteral,
      .dummyInterpolatedStringLiteralHead,
      .dummyBooleanLiteral,
      .nil, .leftSquare, .hash, .backslash,
      .self, .super, .leftBrace,
      .leftParen, .dot, .underscore,
    ])
    switch matched {
    ////// literal expression, selector expression, and key path string expression
    case .nil:
      let nilExpr = LiteralExpression(kind: .nil)
      nilExpr.setSourceRange(lookedRange)
      return nilExpr
    case let .booleanLiteral(b):
      let boolExpr = LiteralExpression(kind: .boolean(b))
      boolExpr.setSourceRange(lookedRange)
      return boolExpr
    case let .integerLiteral(i, r):
      let intExpr = LiteralExpression(kind: .integer(i, r))
      intExpr.setSourceRange(lookedRange)
      return intExpr
    case let .floatingPointLiteral(d, r):
      let floatExpr = LiteralExpression(kind: .floatingPoint(d, r))
      floatExpr.setSourceRange(lookedRange)
      return floatExpr
    case let .staticStringLiteral(s, r):
      let strExpr = LiteralExpression(kind: .staticString(s, r))
      strExpr.setSourceRange(lookedRange)
      return strExpr
    case let .interpolatedStringLiteralHead(s, r):
      return try parseInterpolatedStringLiteral(
        head: s, raw: r, startLocation: lookedRange.start)
    case .leftSquare:
      return try parseCollectionLiteral(startLocation: lookedRange.start)
    case .hash:
      return try parseHashExpression(startLocation: lookedRange.start)
    case .backslash:
      return try parseKeyPathExpression(startLocation: lookedRange.start)
    ////// self expression
    case .self:
      return try parseSelfExpression(startRange: lookedRange)
    ////// superclass expression
    case .super:
      return try parseSuperclassExpression(startRange: lookedRange)
    ////// closure expression
    case .leftBrace:
      return try parseClosureExpression(startLocation: lookedRange.start)
    ////// implicit member expression
    case .dot:
      let endLocation = getEndLocation()
      guard let id = _lexer.readNamedIdentifier() else {
          throw _raiseFatal(.expectedIdentifierAfterDot)
      }
      let implicitNameExpr = ImplicitMemberExpression(identifier: id)
      implicitNameExpr.setSourceRange(lookedRange.start, endLocation)
      return implicitNameExpr
    ////// parenthesized expression and tuple expression
    case .leftParen:
      return try parseParenthesizedExpression(startLocation: lookedRange.start)
    ////// wildcard expression
    case .underscore:
      let wildcardExpr = WildcardExpression()
      wildcardExpr.setSourceRange(lookedRange)
      return wildcardExpr
    ////// identifier expression
    case let .implicitParameterName(implicitName):
      let generic = parseGenericArgumentClause()
      let idExpr = IdentifierExpression(
        kind: .implicitParameterName(implicitName, generic))
      idExpr.setSourceRange(lookedRange)
      if let gnrc = generic {
        idExpr.setSourceRange(lookedRange.start, gnrc.sourceRange.end)
      }
      return idExpr
    default:
      // keyword used as identifier
      if let id = matched.namedIdentifier {
        _lexer.advance()
        let generic = parseGenericArgumentClause()
        let idExpr = IdentifierExpression(kind: .identifier(id, generic))
        idExpr.setSourceRange(lookedRange)
        if let gnrc = generic {
          idExpr.setSourceRange(lookedRange.start, gnrc.sourceRange.end)
        }
        return idExpr
      }
      throw _raiseFatal(.expectedExpr)
    }
  }

  /**
   This, for the majority of the cases, returns a `TupleExpression` actually.
   However, Swift language reference makes one-single-no-identifier-expression
   a special case, and call it `ParenthesizedExpression`.
   So when the condition meets,
   this returns a `ParenthesizedExpression` accordingly.
   */
  private func parseParenthesizedExpression(
    startLocation: SourceLocation
  ) throws -> PrimaryExpression {
    var endLocation = getEndLocation()
    if _lexer.match(.rightParen) {
      let tupleExpr = TupleExpression()
      tupleExpr.setSourceRange(startLocation, endLocation)
      return tupleExpr
    }

    var elements: [TupleExpression.Element] = []
    repeat {
      if _lexer.look(ahead: 1).kind == .colon {
        guard let name = _lexer.readNamedIdentifierOrWildcard() else {
          throw _raiseFatal(.expectedTupleArgumentLabel)
        }
        _lexer.advance()
        let expr = try parseExpression()
        elements.append(
          TupleExpression.Element(identifier: name, expression: expr))
      } else {
        let expr = try parseExpression()
        elements.append(TupleExpression.Element(expression: expr))
      }
    } while _lexer.match(.comma)

    endLocation = getEndLocation()
    if !_lexer.match(.rightParen) {
        throw _raiseFatal(.expectedCloseParenTuple)
    }

    // handle parenthesized expression
    if elements.count == 1 {
      let elem = elements[0]
      if elem.identifier == nil {
        let parenExpr = ParenthesizedExpression(expression: elem.expression)
        parenExpr.setSourceRange(startLocation, endLocation)
        return parenExpr
      }
    }

    let tupleExpr = TupleExpression(elementList: elements)
    tupleExpr.setSourceRange(startLocation, endLocation)
    return tupleExpr
  }

  private func parseSubscriptArguments() throws -> [SubscriptArgument] {
    var arguments: [SubscriptArgument] = []

    repeat {
      var identifier: Identifier?
      if _lexer.look(ahead: 1).kind == .colon && _lexer.look().kind != .leftSquare {
        guard let id = _lexer.readNamedIdentifier() else {
          throw _raiseFatal(.expectedParameterNameFuncCall)
        }
        _lexer.advance()
        identifier = id
      }

      let argExpr = try parseExpression()
      let argument = SubscriptArgument(identifier: identifier, expression: argExpr)
      arguments.append(argument)
    } while _lexer.match(.comma)

    return arguments
  }

  private func parseSuperclassExpression(
    startRange: SourceRange
  ) throws -> SuperclassExpression {
    var endLocation = startRange.end
    let hasNewLineInBetween = _lexer.lookLineFeed()
    let kind: SuperclassExpression.Kind
    switch _lexer.look().kind {
    case .dot:
      _lexer.advance()
      endLocation = getEndLocation()
      if _lexer.match(.init) {
        kind = .initializer
      } else if let id = _lexer.readNamedIdentifier() {
        kind = .method(id)
      } else {
        throw _raiseFatal(.expectedIdentifierAfterSuperDotExpr)
      }
    case .leftSquare where !hasNewLineInBetween:
      _lexer.advance()
      let subscriptArguments = try parseSubscriptArguments()
      endLocation = getEndLocation()
      if !_lexer.match(.rightSquare) {
        throw _raiseFatal(.expectedCloseSquareExprList)
      }
      kind = .subscript(subscriptArguments)
    default:
      throw _raiseFatal(.expectedDotOrSubscriptAfterSuper)
    }
    let superExpr = SuperclassExpression(kind: kind)
    superExpr.setSourceRange(startRange.start, endLocation)
    return superExpr
  }

  private func parseSelfExpression(
    startRange: SourceRange
  ) throws -> SelfExpression {
    var endLocation = startRange.end
    let hasNewLineInBetween = _lexer.lookLineFeed()
    let kind: SelfExpression.Kind
    switch _lexer.look().kind {
    case .dot:
      _lexer.advance()
      endLocation = getEndLocation()
      if _lexer.match(.init) {
        kind = .initializer
      } else if let id = _lexer.readNamedIdentifier() {
        kind = .method(id)
      } else {
        throw _raiseFatal(.expectedIdentifierAfterSelfDotExpr)
      }
    case .leftSquare where !hasNewLineInBetween:
      _lexer.advance()
      let subscriptArguments = try parseSubscriptArguments()
      endLocation = getEndLocation()
      if !_lexer.match(.rightSquare) {
        throw _raiseFatal(.expectedCloseSquareExprList)
      }
      kind = .subscript(subscriptArguments)
    default:
      kind = .self
    }
    let selfExpr = SelfExpression(kind: kind)
    selfExpr.setSourceRange(startRange.start, endLocation)
    return selfExpr
  }

  private func parseKeyPathExpression(
    startLocation: SourceLocation
  ) throws -> KeyPathExpression {
    func parsePostfixes() throws -> [KeyPathExpression.Postfix] {
      var postfixes: [KeyPathExpression.Postfix] = []

      let allQnE = self.splitNextExclaimsAndQuestions()
      for p in allQnE {
        if p == "!" {
          postfixes.append(.exclaim)
        } else if p == "?" {
          postfixes.append(.question)
        }
      }
      switch _lexer.read([.postfixQuestion, .postfixExclaim, .leftSquare]) {
      case .postfixQuestion:
        postfixes.append(.question)
      case .postfixExclaim:
        postfixes.append(.exclaim)
      case .leftSquare:
        let subscriptArguments = try parseSubscriptArguments()
        if !_lexer.match(.rightSquare) {
          throw _raiseFatal(.expectedCloseSquareExprList)
        }
        postfixes.append(.subscript(subscriptArguments))
      default:
        break
      }

      if postfixes.isEmpty {
        return postfixes
      }
      let nextPostfixes = try parsePostfixes()
      return postfixes + nextPostfixes
    }

    var endLocation = getEndLocation()

    var type: Type?
    if case let .identifier(typeName) = _lexer.read(.dummyIdentifier) {
      type = TypeIdentifier(names: [TypeIdentifier.TypeName(name: typeName)])
    }

    var components: [KeyPathExpression.Component] = []
    while _lexer.match(.dot) {
      endLocation = getEndLocation()

      var componentIdentifier: Identifier?
      if case let .identifier(componentId) = _lexer.read(.dummyIdentifier) {
        componentIdentifier = componentId
      }
      let postfixes = try parsePostfixes()

      guard componentIdentifier != nil || !postfixes.isEmpty else {
        throw _raiseFatal(.expectedKeyPathComponentIdentifierOrPostfix)
      }
      components.append((componentIdentifier, postfixes))
    }

    if components.isEmpty {
      throw _raiseFatal(.expectedKeyPathComponent)
    }

    let keyPathExpr = KeyPathExpression(type: type, components: components)
    keyPathExpr.setSourceRange(startLocation, endLocation)
    return keyPathExpr
  }

  private func parseHashExpression(
    startLocation: SourceLocation
  ) throws -> PrimaryExpression {
    let endLocation = getEndLocation()
    guard case let .identifier(magicWord) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.expectedObjectLiteralIdentifier)
    }
    switch magicWord {
    case "file":
      let magicExpr = LiteralExpression(kind: .staticString(startLocation.identifier, "#file"))
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "line":
      let magicExpr = LiteralExpression(kind: .integer(startLocation.line, "#line"))
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "column":
      let magicExpr = LiteralExpression(kind: .integer(startLocation.column, "#column"))
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "function":
      let magicExpr = LiteralExpression(kind: .staticString("TODO", "#function")) // TODO: assign correct value
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "selector":
      return try parseSelectorExpression(startLocation: startLocation)
    case "keyPath":
      return try parseKeyPathStringExpression(startLocation: startLocation)
    case "colorLiteral", "fileLiteral", "imageLiteral":
      return try parsePlaygroundLiteral(magicWord, startLocation)
    default:
      throw _raiseFatal(.expectedObjectLiteralIdentifier)
    }
  }

  private func parseKeyPathStringExpression(
    startLocation: SourceLocation
  ) throws -> KeyPathStringExpression {
    guard _lexer.match(.leftParen) else {
      throw _raiseFatal(.expectedOpenParenKeyPathStringExpr)
    }
    let expr = try parseExpression() // TODO: can wrap this in a do-catch, and throw a better diagnostic message
    let endLocation = getEndLocation()
    guard _lexer.match(.rightParen) else {
      throw _raiseFatal(.expectedCloseParenKeyPathStringExpr)
    }
    let keyPathStringExpression = KeyPathStringExpression(expression: expr)
    keyPathStringExpression.setSourceRange(startLocation, endLocation)
    return keyPathStringExpression
  }

  private func parsePlaygroundLiteral( // swift-lint:suppress(high_ncss)
    _ magicWord: String, _ startLocation: SourceLocation
  ) throws -> LiteralExpression {
    func parseComponent(_ cond: Bool, _ err: ParserErrorKind) throws {
      guard cond else { throw _raiseFatal(err) }
    }
    switch magicWord {
    case "colorLiteral":
      try parseComponent(_lexer.match(.leftParen), .expectedOpenParenPlaygroundLiteral("colorLiteral"))
      try parseComponent(_lexer.read(.dummyIdentifier) == .identifier("red"),
        .expectedKeywordPlaygroundLiteral("colorLiteral", "red"))
      try parseComponent(_lexer.match(.colon), .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "red"))
      guard let red = try? parseExpression() else {
        throw _raiseFatal(.expectedExpressionPlaygroundLiteral("colorLiteral", "red"))
      }
      try parseComponent(_lexer.match(.comma), .expectedCommaBeforeKeywordPlaygroundLiteral("colorLiteral", "green"))
      try parseComponent(_lexer.read(.dummyIdentifier) == .identifier("green"),
        .expectedKeywordPlaygroundLiteral("colorLiteral", "green"))
      try parseComponent(_lexer.match(.colon), .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "green"))
      guard let green = try? parseExpression() else {
        throw _raiseFatal(.expectedExpressionPlaygroundLiteral("colorLiteral", "green"))
      }
      try parseComponent(_lexer.match(.comma), .expectedCommaBeforeKeywordPlaygroundLiteral("colorLiteral", "blue"))
      try parseComponent(_lexer.read(.dummyIdentifier) == .identifier("blue"),
        .expectedKeywordPlaygroundLiteral("colorLiteral", "blue"))
      try parseComponent(_lexer.match(.colon), .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "blue"))
      guard let blue = try? parseExpression() else {
        throw _raiseFatal(.expectedExpressionPlaygroundLiteral("colorLiteral", "blue"))
      }
      try parseComponent(_lexer.match(.comma), .expectedCommaBeforeKeywordPlaygroundLiteral("colorLiteral", "alpha"))
      try parseComponent(_lexer.read(.dummyIdentifier) == .identifier("alpha"),
        .expectedKeywordPlaygroundLiteral("colorLiteral", "alpha"))
      try parseComponent(_lexer.match(.colon), .expectedColonAfterKeywordPlaygroundLiteral("colorLiteral", "alpha"))
      guard let alpha = try? parseExpression() else {
        throw _raiseFatal(.expectedExpressionPlaygroundLiteral("colorLiteral", "alpha"))
      }
      let endLocation = getEndLocation()
      try parseComponent(_lexer.match(.rightParen), .expectedCloseParenPlaygroundLiteral("colorLiteral"))
      let literalExpr = LiteralExpression(kind: .playground(.color(red, green, blue, alpha)))
      literalExpr.setSourceRange(startLocation, endLocation)
      return literalExpr
    case "fileLiteral":
      try parseComponent(_lexer.match(.leftParen), .expectedOpenParenPlaygroundLiteral("fileLiteral"))
      try parseComponent(_lexer.read(.dummyIdentifier) == .identifier("resourceName"),
        .expectedKeywordPlaygroundLiteral("fileLiteral", "resourceName"))
      try parseComponent(_lexer.match(.colon),
        .expectedColonAfterKeywordPlaygroundLiteral("fileLiteral", "resourceName"))
      guard let expr = try? parseExpression() else {
        throw _raiseFatal(.expectedExpressionPlaygroundLiteral("fileLiteral", "resourceName"))
      }
      let endLocation = getEndLocation()
      try parseComponent(_lexer.match(.rightParen), .expectedCloseParenPlaygroundLiteral("fileLiteral"))
      let literalExpr = LiteralExpression(kind: .playground(.file(expr)))
      literalExpr.setSourceRange(startLocation, endLocation)
      return literalExpr
    case "imageLiteral":
      try parseComponent(_lexer.match(.leftParen), .expectedOpenParenPlaygroundLiteral("imageLiteral"))
      try parseComponent(_lexer.read(.dummyIdentifier) == .identifier("resourceName"),
        .expectedKeywordPlaygroundLiteral("imageLiteral", "resourceName"))
      try parseComponent(_lexer.match(.colon),
        .expectedColonAfterKeywordPlaygroundLiteral("imageLiteral", "resourceName"))
      guard let expr = try? parseExpression() else {
        throw _raiseFatal(.expectedExpressionPlaygroundLiteral("imageLiteral", "resourceName"))
      }
      let endLocation = getEndLocation()
      try parseComponent(_lexer.match(.rightParen), .expectedCloseParenPlaygroundLiteral("imageLiteral"))
      let literalExpr = LiteralExpression(kind: .playground(.image(expr)))
      literalExpr.setSourceRange(startLocation, endLocation)
      return literalExpr
    default:
      throw _raiseFatal(.expectedObjectLiteralIdentifier)
    }
  }

  private func parseSelectorExpression( /*
    swift-lint:suppress(high_cyclomatic_complexity,high_npath_complexity,high_ncss)
    */
    startLocation: SourceLocation
  ) throws -> SelectorExpression {
    func parseArgumentNamesAndRightParen() -> ([String], SourceLocation)? {
      do {
        if let (argNames, _) = try parseArgumentNames(), !argNames.isEmpty {
          let endLocation = getEndLocation()
          if _lexer.match(.rightParen) {
            return (argNames, endLocation)
          }
        }

        return nil
      } catch {
        return nil
      }
    }

    guard _lexer.match(.leftParen) else {
      throw _raiseFatal(.expectedOpenParenSelectorExpr)
    }

    var key = ""
    if case let .identifier(keyword) = _lexer.look().kind,
      (keyword == "getter" || keyword == "setter")
    {
      key = keyword
      _lexer.advance()
      guard _lexer.match(.colon) else {
        throw _raiseFatal(.expectedColonAfterPropertyKeywordSelectorExpr(keyword))
      }
    }

    let memberIdCp = _lexer.checkPoint()
    let memberIdDiagnosticCp = _diagnosticPool.checkPoint()
    switch _lexer.read([.dummyIdentifier, .self]) {
    case .identifier(let selfMemberId):
      if let (argNames, endLocation) = parseArgumentNamesAndRightParen() {
        let selExpr = SelectorExpression(
          kind: .selfMember(selfMemberId, argNames))
        selExpr.setSourceRange(startLocation, endLocation)
        return selExpr
      }

      _lexer.restore(fromCheckpoint: memberIdCp)
      _diagnosticPool.restore(fromCheckpoint: memberIdDiagnosticCp)
    case .self:
      do {
        let selfExpr = try parseSelfExpression(startRange: .EMPTY)
        if case .method(let methodName) = selfExpr.kind,
          let (argNames, endLocation) = parseArgumentNamesAndRightParen()
        {
          let selExpr = SelectorExpression(
            kind: .selfMember("self.\(methodName)", argNames))
          selExpr.setSourceRange(startLocation, endLocation)
          return selExpr
        }

        _lexer.restore(fromCheckpoint: memberIdCp)
        _diagnosticPool.restore(fromCheckpoint: memberIdDiagnosticCp)
      } catch {
        _lexer.restore(fromCheckpoint: memberIdCp)
        _diagnosticPool.restore(fromCheckpoint: memberIdDiagnosticCp)
      }
    default:
      break
    }

    let expr = try parseExpression()

    let endLocation = getEndLocation()
    guard _lexer.match(.rightParen) else {
      throw _raiseFatal(.expectedCloseParenSelectorExpr)
    }

    let kind: SelectorExpression.Kind
    switch key {
    case "getter":
      kind = .getter(expr)
    case "setter":
      kind = .setter(expr)
    default:
      kind = .selector(expr)
    }

    let selExpr = SelectorExpression(kind: kind)
    selExpr.setSourceRange(startLocation, endLocation)
    return selExpr
  }

  private func parseCollectionLiteral(
    startLocation: SourceLocation
  ) throws -> LiteralExpression {
    // empty array
    var endLocation = getEndLocation()
    if _lexer.match(.rightSquare) {
      let arrayExpr = LiteralExpression(kind: .array([]))
      arrayExpr.setSourceRange(startLocation, endLocation)
      return arrayExpr
    }
    // empty dictionary
    if _lexer.match(.colon) {
      endLocation = getEndLocation()
      if !_lexer.match(.rightSquare) {
        throw _raiseFatal(.expectedCloseSquareDictionaryLiteral)
      }
      let dictExpr = LiteralExpression(kind: .dictionary([]))
      dictExpr.setSourceRange(startLocation, endLocation)
      return dictExpr
    }
    let headExpr = try parseExpression()
    if _lexer.match(.colon) {
      return try parseDictionaryLiteral(
        head: headExpr, startLocation: startLocation)
    } else {
      return try parseArrayLiteral(head: headExpr, startLocation: startLocation)
    }
  }

  private func parseDictionaryLiteral(
    head: Expression, startLocation: SourceLocation
  ) throws -> LiteralExpression {
    var entries: [DictionaryEntry] = []
    // complete first entry
    let headValueExpr = try parseExpression()
    entries.append(DictionaryEntry(key: head, value: headValueExpr))
    // parse the rest of the dict
    while _lexer.match(.comma) && _lexer.look().kind != .rightSquare {
      let key = try parseExpression()
      if !_lexer.match(.colon) {
        throw _raiseFatal(.expectedColonDictionaryLiteral)
      }
      let value = try parseExpression()
      entries.append(DictionaryEntry(key: key, value: value))
    }
    let endLocation = getEndLocation()
    if !_lexer.match(.rightSquare) {
      throw _raiseFatal(.expectedCloseSquareDictionaryLiteral)
    }
    let dictExpr = LiteralExpression(kind: .dictionary(entries))
    dictExpr.setSourceRange(startLocation, endLocation)
    return dictExpr
  }

  private func parseArrayLiteral(
    head: Expression, startLocation: SourceLocation
  ) throws -> LiteralExpression {
    var exprs: [Expression] = [head]
    // parse the rest of the array
    while _lexer.match(.comma) && _lexer.look().kind != .rightSquare {
      let expr = try parseExpression()
      exprs.append(expr)
    }
    let endLocation = getEndLocation()
    if !_lexer.match(.rightSquare) {
      throw _raiseFatal(.expectedCloseSquareArrayLiteral)
    }
    let arrayExpr = LiteralExpression(kind: .array(exprs))
    arrayExpr.setSourceRange(startLocation, endLocation)
    return arrayExpr
  }

  private func parseInterpolatedStringLiteral( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    head: String, raw: String, startLocation: SourceLocation
  ) throws -> LiteralExpression { // swift-lint:suppress(nested_code_block_depth)
    func caliberateExpressions(_ exprs: [Expression]) throws -> [Expression] { // swift-lint:suppress(nested_code_block_depth,long_line)
      let exprCount = exprs.count
      var indentationPrefix = ""
      var caliberatedExprs: [Expression] = []

      for (offset, expr) in exprs.reversed().enumerated() {
        if let literalExpr = expr as? LiteralExpression,
          case let .staticString(blockStr, blockRawText) = literalExpr.kind,
          blockRawText.isEmpty
        {
          var blockLines = blockStr.components(separatedBy: .newlines)
          if offset == 0 { // let's first of all figure out the indentation prefix
            indentationPrefix = blockLines.removeLast()
            guard indentationPrefix.filter({ $0 != " " && $0 != "\t"}).isEmpty else {
              throw _raiseFatal(.newLineExpectedAtTheClosingOfMultilineStringLiteral)
            }
          }

          let identationLength = indentationPrefix.count
          var caliberatedLines: [String] = []
          for (origLineOffset, origLine) in blockLines.enumerated() {
            if origLineOffset == 0 && offset != exprCount-1 {
              caliberatedLines.append(origLine)
            } else if origLine.isEmpty {
              caliberatedLines.append(origLine)
            } else {
              guard origLine.hasPrefix(indentationPrefix) else {
                throw _raiseFatal(.insufficientIndentationOfLineInMultilineStringLiteral)
              }
              let startIndex = origLine.index(origLine.startIndex, offsetBy: identationLength)
              let caliberatedLine = String(origLine[startIndex...])
              caliberatedLines.append(caliberatedLine)
            }
          }
          let caliberatedLiteral = caliberatedLines.joined(separator: "\n")
          if !caliberatedLiteral.isEmpty {
            let caliberatedLiteralExpr =
              LiteralExpression(kind: .staticString(caliberatedLiteral, blockRawText))
            caliberatedExprs.append(caliberatedLiteralExpr)
          }
        } else {
          caliberatedExprs.append(expr)
        }
      }

      return caliberatedExprs.reversed()
    }

    var exprs: [Expression] = []
    var rawText = raw
    let multilineDelimiter = "\"\"\""
    let isMultiline = raw.hasPrefix(multilineDelimiter)
    let isInterpolatedHead = startLocation != .DUMMY

    func appendRawText(withRawText ir: String) {
      let startIndexOffset = ir.hasPrefix(multilineDelimiter) ? 3 : 1
      let endIndexOffset = ir.hasSuffix(multilineDelimiter) ? -3 : -1
      let startIndex = ir.index(ir.startIndex, offsetBy: startIndexOffset)
      let endIndex = ir.index(ir.endIndex, offsetBy: endIndexOffset)
      rawText += String(ir[startIndex..<endIndex])
    }

    if !head.isEmpty {
      // Note: static strings inside the interpolated string literals do not need to preserve raw representation,
      // because they are what they are
      exprs.append(LiteralExpression(kind: .staticString(head, "")))
    }

    let expr = try parseExpression()
    exprs.append(expr)
    rawText += expr.textDescription

    if _lexer.matchUnicodeScalar(")") {
      rawText += ")"
    } else {
      throw _raiseFatal(.extraTokenStringInterpolation)
    }

    var endLocation: SourceLocation
    let tailString = _lexer.lexStringLiteral(
      isMultiline: isMultiline, postponeCaliberation: true)
    switch tailString {
    case let .staticStringLiteral(str, raw):
      if !str.isEmpty {
        // Note: static strings inside the interpolated string literals do not need to preserve raw representation,
        // because they are what they are
        exprs.append(LiteralExpression(kind: .staticString(str, "")))
        appendRawText(withRawText: raw)
      }
      endLocation = _lexer._getCurrentLocation() // TODO: need to find a better to do it
    case let .interpolatedStringLiteralHead(headStr, rawStr):
      let nested = try parseInterpolatedStringLiteral(
        head: headStr, raw: rawStr, startLocation: .DUMMY)
      guard case let .interpolatedString(es, ir) = nested.kind else {
        throw _raiseFatal(.expectedStringInterpolation)
      }
      exprs.append(contentsOf: es)
      appendRawText(withRawText: ir)
      endLocation = nested.sourceRange.end
    default:
      throw _raiseFatal(.expectedStringInterpolation)
    }

    if isMultiline && isInterpolatedHead {
      exprs = try caliberateExpressions(exprs)
    }

    rawText += isMultiline ? multilineDelimiter : "\""

    let strExpr = LiteralExpression(kind: .interpolatedString(exprs, rawText))
    strExpr.setSourceRange(startLocation, endLocation)
    return strExpr
  }

  private func parseClosureExpression( /*
    swift-lint:suppress(high_cyclomatic_complexity,high_npath_complexity,high_ncss)
    */
    startLocation: SourceLocation
  ) throws -> ClosureExpression {
    func parseCaptureList() -> [ClosureExpression.Signature.CaptureItem]?
    {
      var captureList: [ClosureExpression.Signature.CaptureItem] = []
      repeat {
        var specifier: ClosureExpression.Signature.CaptureItem.Specifier?
        switch _lexer.read([.weak, .unowned]) {
        case .weak:
          specifier = .weak
        case .unowned:
          if _lexer.look().kind == .leftParen {
            switch _lexer.readNext([.safe, .unsafe]) {
            case .safe:
              specifier = .unownedSafe
            case .unsafe:
              specifier = .unownedUnsafe
            default:
              return nil
            }
            guard _lexer.match(.rightParen) else {
              return nil
            }
          } else {
            specifier = .unowned
          }
        default:
          break
        }
        guard let expr = try? parseExpression() else {
          return nil
        }
        let item = ClosureExpression.Signature.CaptureItem(
          specifier: specifier, expression: expr)
        captureList.append(item)
      } while _lexer.match(.comma)
      guard _lexer.match(.rightSquare) else {
        return nil
      }
      return captureList
    }

    func parseParameterList()
      -> [ClosureExpression.Signature.ParameterClause.Parameter]?
    {
      if _lexer.match(.rightParen) {
        return []
      }

      var params: [ClosureExpression.Signature.ParameterClause.Parameter] = []
      repeat {
        guard let name = _lexer.readNamedIdentifierOrWildcard() else {
          return nil
        }
        guard let typeAnnotation = try? parseTypeAnnotation() else {
          return nil
        }
        var isVarargs = false
        if typeAnnotation != nil,
          case .postfixOperator("...") = _lexer.look().kind
        {
          _lexer.advance()
          isVarargs = true
        }
        let param = ClosureExpression.Signature.ParameterClause.Parameter(
          name: name, typeAnnotation: typeAnnotation, isVarargs: isVarargs)
        params.append(param)
      } while _lexer.match(.comma)
      guard _lexer.match(.rightParen) else {
        return nil
      }
      return params
    }

    func parseParameterName() -> String? {
      guard let id = _lexer.look().kind.namedIdentifierOrWildcard,
        id != "in",
        id != "throws"
      else {
        return nil
      }
      return id
    }

    var endLocation = getEndLocation()
    if _lexer.match(.rightBrace) {
      // no signature nor statements, returns a closure expression directly
      let closureExpr = ClosureExpression()
      closureExpr.setSourceRange(startLocation, endLocation)
      return closureExpr
    }

    let signatureOpeningCp = _lexer.checkPoint()
    let signatureOpeningDiagnosticCp = _diagnosticPool.checkPoint()
    var signature: ClosureExpression.Signature?
    if _lexer.match(.leftSquare) {
      if let captureList = parseCaptureList() {
        signature = ClosureExpression.Signature(captureList: captureList)
      } else {
        _lexer.restore(fromCheckpoint: signatureOpeningCp)
        _diagnosticPool.restore(fromCheckpoint: signatureOpeningDiagnosticCp)
      }
    }

    var parameterClause: ClosureExpression.Signature.ParameterClause?
    if _lexer.match(.leftParen) {
      if let params = parseParameterList() {
        parameterClause =
          ClosureExpression.Signature.ParameterClause.parameterList(params)
      } else {
        _lexer.restore(fromCheckpoint: signatureOpeningCp)
        _diagnosticPool.restore(fromCheckpoint: signatureOpeningDiagnosticCp)
      }
    }

    if let headId = parseParameterName(),
      [Token.Kind.comma, .throws, .arrow, .in].contains(_lexer.look(ahead: 1).kind)
    {
      _lexer.advance()
      var ids = [headId]
      while _lexer.match(.comma) {
        guard let id = parseParameterName() else {
          throw _raiseFatal(.expectedClosureParameterName)
        }
        _lexer.advance()
        ids.append(id)
      }
      parameterClause =
        ClosureExpression.Signature.ParameterClause.identifierList(ids)
    }

    if let parameterClause = parameterClause {
      let captureList = signature?.captureList
      let canThrow = _lexer.match(.throws)
      let funcResult = try parseFunctionResult()
      signature = ClosureExpression.Signature(
        captureList: captureList,
        parameterClause: parameterClause,
        canThrow: canThrow,
        functionResult: funcResult)
    }

    if signature != nil, !_lexer.match(.in) {
      _lexer.restore(fromCheckpoint: signatureOpeningCp)
      _diagnosticPool.restore(fromCheckpoint: signatureOpeningDiagnosticCp)
      signature = nil
    }

    endLocation = getEndLocation()
    if _lexer.match(.rightBrace) {
      // has only signature, simply return
      let closureExpr = ClosureExpression(signature: signature)
      closureExpr.setSourceRange(startLocation, endLocation)
      return closureExpr
    }

    let stmts = try parseStatements()

    endLocation = getEndLocation()
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.rightBraceExpected("closure expression"))
    }
    let closureExpr = ClosureExpression(signature: signature, statements: stmts)
    closureExpr.setSourceRange(startLocation, endLocation)
    return closureExpr
  }
}
