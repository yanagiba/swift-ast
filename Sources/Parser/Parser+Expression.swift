/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
    case `try`
    case forcedTry
    case optionalTry
    case noTry

    fileprivate func wrap(expr: Expression) -> Expression {
      switch self {
      case .try:
        return TryOperatorExpression(kind: .try(expr))
      case .forcedTry:
        return TryOperatorExpression(kind: .forced(expr))
      case .optionalTry:
        return TryOperatorExpression(kind: .optional(expr))
      default:
        return expr
      }
    }
  }

  private func parseTryKind() -> TryKind {
    guard _lexer.match(.try) else {
      return .noTry
    }
    if _lexer.match(.postfixExclaim) {
      return .forcedTry
    } else if _lexer.match(.postfixQuestion) {
      return .optionalTry
    } else {
      return .try
    }
  }

  private func parseBinaryExpressions(
    leftExpression: Expression, config: ParserExpressionConfig
  ) throws -> Expression {
    var resultExpr: Expression = leftExpression

    let examine: () -> (Bool, Token.Kind) = {
      let potentialBinaryTokens: [Token.Kind] = [
        .dummyBinaryOperator,
        .assignmentOperator,
        .binaryQuestion,
        .is,
        .as,
      ]
      return self._lexer.examine(potentialBinaryTokens)
    }

    var examined = examine()
    while examined.0 {
      switch examined.1 {
      case .binaryOperator(let op):
        let rhs = try parsePrefixExpression(config: config)
        resultExpr = BinaryOperatorExpression(
          binaryOperator: op, leftExpression: resultExpr, rightExpression: rhs)
      case .assignmentOperator:
        let tryKind = parseTryKind()
        let prefixExpr = try parsePrefixExpression(config: config)
        let rhs = tryKind.wrap(expr: prefixExpr)
        resultExpr = AssignmentOperatorExpression(
          leftExpression: resultExpr, rightExpression: rhs)
      case .binaryQuestion:
        let trueTryKind = parseTryKind()
        var trueExpr = try parseExpression(config: config)
        trueExpr = trueTryKind.wrap(expr: trueExpr)
        guard _lexer.match(.colon) else {
          throw _raiseFatal(.dummy)
        }
        let falseTryKind = parseTryKind()
        var falseExpr: Expression = try parsePrefixExpression(config: config)
        falseExpr = falseTryKind.wrap(expr: falseExpr)
        resultExpr = TernaryConditionalOperatorExpression(
          conditionExpression: resultExpr,
          trueExpression: trueExpr,
          falseExpression: falseExpr)
      case .is:
        let type = try parseType()
        resultExpr =
          TypeCastingOperatorExpression(kind: .check(resultExpr, type))
      case .as:
        switch _lexer.read([.postfixQuestion, .postfixExclaim]) {
        case .postfixQuestion:
          let type = try parseType()
          resultExpr = TypeCastingOperatorExpression(
            kind: .conditionalCast(resultExpr, type))
        case .postfixExclaim:
          let type = try parseType()
          resultExpr =
            TypeCastingOperatorExpression(kind: .forcedCast(resultExpr, type))
        default:
          let type = try parseType()
          resultExpr =
            TypeCastingOperatorExpression(kind: .cast(resultExpr, type))
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
    switch _lexer.read([.dummyPrefixOperator, .prefixAmp]) {
    case let .prefixOperator(op):
      let postfixExpr = try parsePostfixExpression(config: config)
      return PrefixOperatorExpression(
        prefixOperator: op, postfixExpression: postfixExpr)
    case .prefixAmp:
      guard case let .identifier(name) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.dummy)
      }
      return InOutExpression(identifier: name)
    default:
      return try parsePostfixExpression(config: config)
    }
  }

  private func parsePostfixExpression(
    config: ParserExpressionConfig
  ) throws -> PostfixExpression {
    var resultExpr: PostfixExpression = try parsePrimaryExpression()

    let examine: () -> (Bool, Token.Kind) = {
      let allQnE = self.splitTrailingExlaimsAndQuestions()
      if !allQnE.isEmpty {
        for p in allQnE {
          if p == "!" {
            resultExpr = ForcedValueExpression(postfixExpression: resultExpr)
          } else if p == "?" {
            resultExpr =
              OptionalChainingExpression(postfixExpression: resultExpr)
          }
        }
      }

      var tokens: [Token.Kind] = [
        .dummyPostfixOperator,
        .leftParen,
        .dot,
        .leftSquare,
        .postfixExclaim,
        .postfixQuestion,
      ]

      if self._lexer.look().kind == .leftBrace &&
        config.parseTrailingClosure &&
        self.isPotentialTrailingClosure()
      {
        tokens.append(.leftBrace)
      }

      return self._lexer.examine(tokens)
    }

    var examined = examine()
    while examined.0 {
      switch examined.1 {
      case .postfixOperator(let op):
        resultExpr = PostfixOperatorExpression(
          postfixOperator: op, postfixExpression: resultExpr)
      case .leftParen:
        resultExpr = try parseFunctionCallExpression(
          postfixExpression: resultExpr, config: config)
      case .dot:
        resultExpr =
          try parsePostfixMemberExpression(postfixExpression: resultExpr)
      case .leftSquare:
        let exprList = try parseExpressionList()
        if !_lexer.match(.rightSquare) {
            try _raiseError(.dummy)
        }
        resultExpr = SubscriptExpression(
          postfixExpression: resultExpr, expressionList: exprList)
      case .postfixExclaim:
        resultExpr = ForcedValueExpression(postfixExpression: resultExpr)
      case .postfixQuestion:
        resultExpr = OptionalChainingExpression(postfixExpression: resultExpr)
      case .leftBrace:
        let trailingClosure = try parseClosureExpression()
        resultExpr = FunctionCallExpression(
          postfixExpression: resultExpr, trailingClosure: trailingClosure)
      default:
        break
      }

      examined = examine()
    }

    return resultExpr
  }

  /**
   This parses a `FunctionCallExpression`.
   And if it is ended in the format of `type(of: expression)`,
   we convert it into a dynamic type expression.
   */
  private func parseFunctionCallExpression(
    postfixExpression expr: PostfixExpression, config: ParserExpressionConfig
  ) throws -> PostfixExpression {
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
            throw _raiseFatal(.dummy)
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
      if !_lexer.match(.rightParen) {
          try _raiseError(.dummy)
      }
      return arguments
    }

    // unit
    if _lexer.match(.rightParen) {
      if config.parseTrailingClosure &&
        _lexer.look().kind == .leftBrace &&
        isPotentialTrailingClosure()
      {
        _lexer.advance()
        let trailingClosure = try parseClosureExpression()
        return FunctionCallExpression(
          postfixExpression: expr,
          argumentClause: [],
          trailingClosure: trailingClosure)
      } else {
        return FunctionCallExpression(
          postfixExpression: expr, argumentClause: [])
      }
    }

    let argumentList = try parseArgumentList()

    // handle dynamic type expression
    if let idExpr = expr as? IdentifierExpression,
      case .identifier("type", _) = idExpr.kind,
      argumentList.count == 1,
      case let .namedExpression("of", argExpr) = argumentList[0]
    {
      return DynamicTypeExpression(expression: argExpr)
    }

    if config.parseTrailingClosure &&
      _lexer.look().kind == .leftBrace &&
      isPotentialTrailingClosure()
    {
      _lexer.advance()
      let trailingClosure = try parseClosureExpression()
      return FunctionCallExpression(
        postfixExpression: expr,
        argumentClause: argumentList,
        trailingClosure: trailingClosure)
    } else {
      return FunctionCallExpression(
        postfixExpression: expr, argumentClause: argumentList)
    }
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

  private func parseArgumentNames() throws -> [String]? {
    guard isArgumentNames(), _lexer.match(.leftParen) else {
      return nil
    }
    var argumentNames = [String]()
    repeat {
      guard let argumentName = _lexer.readNamedIdentifierOrWildcard() else {
        throw _raiseFatal(.dummy)
      }
      guard _lexer.match(.colon) else {
        throw _raiseFatal(.dummy)
      }
      argumentNames.append(argumentName)
    } while !_lexer.match(.rightParen)
    return argumentNames
  }

  private func parsePostfixMemberExpression(
    postfixExpression expr: PostfixExpression
  ) throws -> PostfixExpression {
    func getTupleIndex() -> Int? {
      let digitCp = _lexer.checkPoint()
      var digitStr = ""
      while let look = _lexer.lookUnicodeScalar() {
        switch look {
        case "0"..."9":
          digitStr += String(look)
          _lexer.advanceChar()
        case ".":
          if let index = Int(digitStr) {
            return index
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

    if let index = getTupleIndex() {
      return ExplicitMemberExpression(kind: .tuple(expr, index))
    }

    switch _lexer.read([
      .init,
      .self,
      .dynamicType,
      .dummyIntegerLiteral,
      .dummyFloatingPointLiteral,
    ]) {
    case .init:
      let argumentNames = (try parseArgumentNames()) ?? []
      return InitializerExpression(
        postfixExpression: expr, argumentNames: argumentNames)
    case .integerLiteral(let index, _, true):
      return ExplicitMemberExpression(kind: .tuple(expr, index))
    case .floatingPointLiteral(_, let raw):
      guard let (first, second) = splitDoubleRawToTwoIntegers(raw) else {
        throw _raiseFatal(.dummy)
      }
      let firstExplitMemberExpr =
        ExplicitMemberExpression(kind: .tuple(expr, first))
      return ExplicitMemberExpression(
        kind: .tuple(firstExplitMemberExpr, second))
    case .self:
      return PostfixSelfExpression(postfixExpression: expr)
    case .dynamicType:
      return DynamicTypeExpression(expression: expr)
    default:
      guard let id = _lexer.readNamedIdentifier() else {
        throw _raiseFatal(.dummy)
      }

      if let genericArgumentClause = parseGenericArgumentClause() {
        let memberExpr = ExplicitMemberExpression(
          kind: .generic(expr, id, genericArgumentClause))
        return memberExpr
      } else if let argumentNames = try parseArgumentNames() {
        return ExplicitMemberExpression(
          kind: .argument(expr, id, argumentNames))
      } else {
        return ExplicitMemberExpression(kind: .namedType(expr, id))
      }
    }
  }

  private func parsePrimaryExpression() throws -> PrimaryExpression {
    let lookedRange = getLookedRange()
    let matched = _lexer.read([
      .dummyImplicitParameterName,
      .dummyIntegerLiteral,
      .dummyFloatingPointLiteral,
      .dummyStaticStringLiteral,
      .dummyInterpolatedStringLiteralHead,
      .dummyBooleanLiteral,
      .nil, .leftSquare, .hash,
      .self, .super, .leftBrace,
      .leftParen, .dot, .underscore,
    ])
    switch matched {
    ////// literal expression, selector expression, and key path expression
    case .nil:
      let nilExpr = LiteralExpression(kind: .nil)
      nilExpr.setSourceRange(lookedRange)
      return nilExpr
    case let .booleanLiteral(b):
      let boolExpr = LiteralExpression(kind: .boolean(b))
      boolExpr.setSourceRange(lookedRange)
      return boolExpr
    case let .integerLiteral(i, r, _):
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
    ////// self expression
    case .self:
      return try parseSelfExpression()
    ////// superclass expression
    case .super:
      return try parseSuperclassExpression()
    ////// closure expression
    case .leftBrace:
      return try parseClosureExpression()
    ////// implicit member expression
    case .dot:
      guard let id = _lexer.readNamedIdentifier() else {
          throw _raiseFatal(.dummy)
      }
      return ImplicitMemberExpression(identifier: id)
    ////// parenthesized expression and tuple expression
    case .leftParen:
      return try parseParenthesizedExpression()
    ////// wildcard expression
    case .underscore:
      return WildcardExpression()
    ////// identifier expression
    case let .implicitParameterName(implicitName):
      let generic = parseGenericArgumentClause()
      return IdentifierExpression(
        kind: .implicitParameterName(implicitName, generic))
    default:
      // keyword used as identifier
      if let id = matched.namedIdentifier {
        _lexer.advance()
        let generic = parseGenericArgumentClause()
        return IdentifierExpression(kind: .identifier(id, generic))
      }
      throw _raiseFatal(.dummy)
    }
  }

  /**
   This, for the majority of the cases, returns a `TupleExpression` actually.
   However, Swift language reference makes one-single-no-identifier-expression
   a special case, and call it `ParenthesizedExpression`.
   So when the condition meets,
   this returns a `ParenthesizedExpression` accordingly.
   */
  private func parseParenthesizedExpression() throws -> PrimaryExpression {
    // unit
    if _lexer.match(.rightParen) {
      return TupleExpression()
    }
    var elements: [TupleExpression.Element] = []
    repeat {
      if _lexer.look(ahead: 1).kind == .colon {
        guard let name = _lexer.readNamedIdentifierOrWildcard() else {
          throw _raiseFatal(.dummy)
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
    if !_lexer.match(.rightParen) {
        try _raiseError(.dummy)
    }

    // handle parenthesized expression
    if elements.count == 1 {
      let elem = elements[0]
      if elem.identifier == nil {
        return ParenthesizedExpression(expression: elem.expression)
      }
    }

    return TupleExpression(elementList: elements)
  }

  private func parseSuperclassExpression() throws -> SuperclassExpression {
    let kind: SuperclassExpression.Kind
    switch _lexer.read([.dot, .leftSquare]) {
    case .dot:
      if _lexer.match(.init) {
        kind = .initializer
      } else if let id = _lexer.readNamedIdentifier() {
        kind = .method(id)
      } else {
        throw _raiseFatal(.dummy)
      }
    case .leftSquare:
      let expressionList = try parseExpressionList()
      if !_lexer.match(.rightSquare) {
        try _raiseError(.dummy)
      }
      kind = .subscript(expressionList)
    default:
      throw _raiseFatal(.dummy)
    }
    return SuperclassExpression(kind: kind)
  }

  private func parseSelfExpression() throws -> SelfExpression {
    let kind: SelfExpression.Kind
    switch _lexer.read([.dot, .leftSquare]) {
    case .dot:
      if _lexer.match(.init) {
        kind = .initializer
      } else if let id = _lexer.readNamedIdentifier() {
        kind = .method(id)
      } else {
        throw _raiseFatal(.dummy)
      }
    case .leftSquare:
      let expressionList = try parseExpressionList()
      if !_lexer.match(.rightSquare) {
          try _raiseError(.dummy)
      }
      kind = .subscript(expressionList)
    default:
      kind = .self
    }
    return SelfExpression(kind: kind)
  }

  private func parseHashExpression(
    startLocation: SourceLocation
  ) throws -> PrimaryExpression {
    let endLocation = getEndLocation()
    guard case let .identifier(magicWord) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.dummy)
    }
    switch magicWord {
    case "file":
      let magicExpr = LiteralExpression(kind: .staticString("TODO", "#file")) // TODO: assign correct value
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "line":
      let magicExpr = LiteralExpression(kind: .integer(-1, "#line")) // TODO: assign correct value
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "column":
      let magicExpr = LiteralExpression(kind: .integer(-1, "#column")) // TODO: assign correct value
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "function":
      let magicExpr = LiteralExpression(kind: .staticString("TODO", "#function")) // TODO: assign correct value
      magicExpr.setSourceRange(startLocation, endLocation)
      return magicExpr
    case "selector":
      return try parseSelectorExpression()
    case "keyPath":
      guard _lexer.match(.leftParen) else {
        throw _raiseFatal(.dummy)
      }
      let expr = try parseExpression()
      guard _lexer.match(.rightParen) else {
        throw _raiseFatal(.dummy)
      }
      return KeyPathExpression(expression: expr)
    default:
      throw _raiseFatal(.dummy)
    }
  }

  private func parseSelectorExpression() throws -> SelectorExpression {
    func parseArgumentNamesAndRightParen() -> [String]? {
      do {
        if let argNames = try parseArgumentNames(),
          !argNames.isEmpty,
          _lexer.match(.rightParen)
        {
          return argNames
        }

        return nil
      } catch {
        return nil
      }
    }

    guard _lexer.match(.leftParen) else {
      throw _raiseFatal(.dummy)
    }

    var key = ""
    if case let .identifier(keyword) = _lexer.look().kind,
      (keyword == "getter" || keyword == "setter")
    {
      key = keyword
      _lexer.advance()
      guard _lexer.match(.colon) else {
        throw _raiseFatal(.dummy)
      }
    }

    let memberIdCp = _lexer.checkPoint()
    let memberIdDiagnosticCp = _diagnosticPool.checkPoint()
    switch _lexer.read([.dummyIdentifier, .self]) {
    case .identifier(let selfMemberId):
      if let argNames = parseArgumentNamesAndRightParen()
      {
        return SelectorExpression(kind: .selfMember(selfMemberId, argNames))
      }

      _lexer.restore(fromCheckpoint: memberIdCp)
      _diagnosticPool.restore(fromCheckpoint: memberIdDiagnosticCp)
    case .self:
      do {
        let selfExpr = try parseSelfExpression()
        if case .method(let methodName) = selfExpr.kind,
          let argNames = parseArgumentNamesAndRightParen()
        {
          return SelectorExpression(
            kind: .selfMember("self.\(methodName)", argNames))
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
    guard _lexer.match(.rightParen) else {
      throw _raiseFatal(.dummy)
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
    return SelectorExpression(kind: kind)
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
        try _raiseError(.dummy)
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
        try _raiseError(.dummy)
      }
      let value = try parseExpression()
      entries.append(DictionaryEntry(key: key, value: value))
    }
    let endLocation = getEndLocation()
    if !_lexer.match(.rightSquare) {
      try _raiseError(.dummy)
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
      try _raiseError(.dummy)
    }
    let arrayExpr = LiteralExpression(kind: .array(exprs))
    arrayExpr.setSourceRange(startLocation, endLocation)
    return arrayExpr
  }

  private func parseInterpolatedStringLiteral(
    head: String, raw: String, startLocation: SourceLocation
  ) throws -> LiteralExpression {
    var exprs: [Expression] = []
    var rawText = raw

    if !head.isEmpty {
      exprs.append(LiteralExpression(kind: .staticString(head, ""))) // static strings inside the interpolated string literals do not need to preserve raw representation, because they are what they are
    }

    let expr = try parseExpression()
    exprs.append(expr)
    rawText += expr.textDescription

    if _lexer.matchUnicodeScalar(")") {
      rawText += ")"
    } else {
      throw _raiseFatal(.dummy)
    }

    var endLocation: SourceLocation
    switch _lexer.lexStringLiteral() {
    case let .staticStringLiteral(str, _):
      if !str.isEmpty {
        exprs.append(LiteralExpression(kind: .staticString(str, ""))) // static strings inside the interpolated string literals do not need to preserve raw representation, because they are what they are
        rawText += str
      }
      endLocation = _lexer._getCurrentLocation() // TODO: need to find a better to do it
    case let .interpolatedStringLiteralHead(headStr, rawStr):
      let nested = try parseInterpolatedStringLiteral(
        head: headStr, raw: rawStr, startLocation: .DUMMY)
      guard case let .interpolatedString(es, ir) = nested.kind else {
        throw _raiseFatal(.dummy)
      }
      exprs.append(contentsOf: es)
      rawText += ir.substring(
        with: ir.index(after: ir.startIndex)..<ir.index(before: ir.endIndex))
      endLocation = nested.sourceRange.end
    default:
      throw _raiseFatal(.dummy)
    }

    rawText += "\""

    let strExpr = LiteralExpression(kind: .interpolatedString(exprs, rawText))
    strExpr.setSourceRange(startLocation, endLocation)
    return strExpr
  }

  private func parseClosureExpression() throws -> ClosureExpression {
    func parseCaptureList()
      throws -> [ClosureExpression.Signature.CaptureItem]
    {
      var captureList: [ClosureExpression.Signature.CaptureItem] = []
      repeat {
        var specifier: ClosureExpression.Signature.CaptureItem.Specifier? = nil
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
              throw _raiseFatal(.dummy)
            }
            guard _lexer.match(.rightParen) else {
              throw _raiseFatal(.dummy)
            }
          } else {
            specifier = .unowned
          }
        default:
          break
        }
        let expr = try parseExpression()
        let item = ClosureExpression.Signature.CaptureItem(
          specifier: specifier, expression: expr)
        captureList.append(item)
      } while _lexer.match(.comma)
      guard _lexer.match(.rightSquare) else {
        throw _raiseFatal(.dummy)
      }
      return captureList
    }

    func parseParameterList()
      throws -> [ClosureExpression.Signature.ParameterClause.Parameter]
    {
      if _lexer.match(.rightParen) {
        return []
      }

      var params: [ClosureExpression.Signature.ParameterClause.Parameter] = []
      repeat {
        guard let name = _lexer.readNamedIdentifierOrWildcard() else {
          throw _raiseFatal(.dummy)
        }
        let typeAnnotation = try parseTypeAnnotation()
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
        throw _raiseFatal(.dummy)
      }
      return params
    }

    if _lexer.match(.rightBrace) {
      // no signature nor statements, returns a closure expression directly
      return ClosureExpression()
    }

    let signatureOpeningCp = _lexer.checkPoint()
    let signatureOpeningDiagnosticCp = _diagnosticPool.checkPoint()
    var signature: ClosureExpression.Signature? = nil
    if _lexer.match(.leftSquare) {
      do {
        let captureList = try parseCaptureList()
        signature = ClosureExpression.Signature(captureList: captureList)
      } catch {
        _lexer.restore(fromCheckpoint: signatureOpeningCp)
        _diagnosticPool.restore(fromCheckpoint: signatureOpeningDiagnosticCp)
      }
    }

    var parameterClause: ClosureExpression.Signature.ParameterClause? = nil
    if _lexer.match(.leftParen) {
      do {
        let params = try parseParameterList()
        parameterClause =
          ClosureExpression.Signature.ParameterClause.parameterList(params)
      } catch {
        _lexer.restore(fromCheckpoint: signatureOpeningCp)
        _diagnosticPool.restore(fromCheckpoint: signatureOpeningDiagnosticCp)
      }
    }

    if let headId = _lexer.look().kind.namedIdentifierOrWildcard,
      headId != "in",
      headId != "throws",
      (
        _lexer.look(ahead: 1).kind == .comma ||
        _lexer.look(ahead: 1).kind == .throws ||
        _lexer.look(ahead: 1).kind == .arrow ||
        _lexer.look(ahead: 1).kind == .in
      )
    {
      _lexer.advance()
      var ids = [headId]
      while _lexer.match(.comma) {
        guard let id = _lexer.look().kind.namedIdentifierOrWildcard,
          id != "in",
          id != "throws" // TODO: need some cleanup
        else {
          throw _raiseFatal(.dummy)
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

    if _lexer.match(.rightBrace) {
      // has only signature, simply return
      return ClosureExpression(signature: signature)
    }

    let stmts = try parseStatements()
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.dummy)
    }
    return ClosureExpression(signature: signature, statements: stmts)
  }
}
