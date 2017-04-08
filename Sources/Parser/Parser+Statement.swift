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

import AST
import Lexer

extension Parser {
  func parseStatements() throws -> Statements {
    var stmts = [Statement]()
    while true {
      switch _lexer.look().kind {
      case .eof, .rightBrace, .default, .case:
        return stmts
      default:
        stmts.append(try parseStatement())
      }
    }
  }

  func parseStatement() throws -> Statement {
    let stmt: Statement
    switch _lexer.read([
      .for, .while, .repeat, // loop
      .if, .guard, .switch, // branch
      // identifier as labelel statement
      .defer, // defer
      .do, // do
      .break, .continue, .fallthrough, .return, .throw, // control transfer
      // compiler control
      .hash,
      // declaration statement
      // expression statement
    ]) {
    case .for:
      stmt = try parseForInStatement()
    case .while:
      stmt = try parseWhileStatement()
    case .repeat:
      stmt = try parseRepeatWhileStatement()
    case .if:
      stmt = try parseIfStatement()
    case .guard:
      stmt = try parseGuardStatement()
    case .switch:
      stmt = try parseSwitchStatement()
    case .break:
      if case .identifier(let name) = _lexer.read(.dummyIdentifier) {
        stmt = BreakStatement(labelName: name)
      } else {
        stmt = BreakStatement()
      }
    case .continue:
      if case .identifier(let name) = _lexer.read(.dummyIdentifier) {
        stmt = ContinueStatement(labelName: name)
      } else {
        stmt = ContinueStatement()
      }
    case .fallthrough:
      stmt = FallthroughStatement()
    case .return:
      switch _lexer.look(skipLineFeed: false).kind {
      case .semicolon, .lineFeed, .eof, .rightBrace:
        stmt = ReturnStatement()
      default:
        let expr = try parseExpression()
        stmt = ReturnStatement(expression: expr)
      }
    case .throw:
      let expr = try parseExpression()
      stmt = ThrowStatement(expression: expr)
    case .defer:
      let codeBlock = try parseCodeBlock()
      stmt = DeferStatement(codeBlock: codeBlock)
    case .do:
      stmt = try parseDoStatement()
    case let .identifier(name):
      if _lexer.look(ahead: 1).kind == .colon &&
        (
          _lexer.look(ahead: 2).kind == .for ||
          _lexer.look(ahead: 2).kind == .while ||
          _lexer.look(ahead: 2).kind == .repeat ||
          _lexer.look(ahead: 2).kind == .if ||
          _lexer.look(ahead: 2).kind == .switch ||
          _lexer.look(ahead: 2).kind == .do
        )
      {
        _lexer.advance(by: 2)
        stmt = try parseLabeledStatement(withLabelName: name)
      } else if name == "precedencegroup" {
        stmt = try parseDeclaration()
      } else {
        // if identifier is not immediately followed by a colon
        // and then one of the statement prefix keywords,
        // then we try to parase an expression that starts with this identifier
        stmt = try parseExpression()
      }
    case .hash:
      stmt = try parseCompilerControlStatement()
    case .import, .let, .var, .typealias, .func, .enum, .indirect,
      .struct, .init, .deinit, .extension, .subscript, .operator, .protocol:
      stmt = try parseDeclaration()
    case .at:
      stmt = try parseDeclaration()
    default:
      if _lexer.look().kind.isModifier {
        stmt = try parseDeclaration()
      } else {
        stmt = try parseExpression()
      }
    }
    if !_lexer.match([.semicolon, .lineFeed, .eof]) &&
      _lexer.look().kind != .rightBrace
    {
      try _raiseError(.dummy)
    }
    return stmt
  }

  func parseCompilerControlStatement() throws -> CompilerControlStatement {
    var kind: CompilerControlStatement.Kind
    switch _lexer.read([.if, .dummyIdentifier, .else]) {
    case .if:
      let condition = _lexer.readUntilEOL()
      kind = .if(condition)
    case .identifier(let id):
      switch id {
      case "elseif":
        let condition = _lexer.readUntilEOL()
        kind = .elseif(condition)
      case "endif":
        kind = .endif
      case "sourceLocation":
        guard _lexer.match(.leftParen) else { throw _raiseFatal(.dummy) }
        if _lexer.match(.rightParen) {
          _lexer.readUntilEOL()
          kind = .sourceLocation(nil, nil)
        }
        var fileName: String? = nil
        var lineNumber: Int? = nil
        if _lexer.read(.dummyIdentifier) == .identifier("file"),
          _lexer.match(.colon),
          case let .staticStringLiteral(name, _) =
            _lexer.read(.dummyStaticStringLiteral),
          _lexer.match(.comma),
          _lexer.read(.dummyIdentifier) == .identifier("line"),
          _lexer.match(.colon),
          case let .integerLiteral(line, _, true) =
            _lexer.read(.dummyIntegerLiteral),
          _lexer.match(.rightParen) // TODO: very crazy conditions
        {
          fileName = name
          lineNumber = Int(line)
        }
        _lexer.readUntilEOL()
        kind = .sourceLocation(fileName, lineNumber)
      default:
        throw _raiseFatal(.dummy)
      }
    case .else:
      kind = .else
    default:
      throw _raiseFatal(.dummy)
    }
    return CompilerControlStatement(kind: kind)
  }

  private func parseLabeledStatement(
    withLabelName name: String
  ) throws -> LabeledStatement {
    let stmt: Statement
    switch _lexer.read([.for, .while, .repeat, .if, .switch, .do]) {
    case .for:
      stmt = try parseForInStatement()
    case .while:
      stmt = try parseWhileStatement()
    case .repeat:
      stmt = try parseRepeatWhileStatement()
    case .if:
      stmt = try parseIfStatement()
    case .switch:
      stmt = try parseSwitchStatement()
    case .do:
      stmt = try parseDoStatement()
    default:
      throw _raiseFatal(.dummy)
    }
    return LabeledStatement(labelName: name, statement: stmt)
  }

  private func parseDoStatement() throws -> DoStatement {
    let codeBlock = try parseCodeBlock()
    var catchClauses: [DoStatement.CatchClause] = []
    while _lexer.match(.catch) {
      var catchPattern: Pattern? = nil
      var catchWhere: Expression? = nil
      if _lexer.look().kind != .leftBrace {
        if _lexer.look().kind != .where {
          catchPattern = try parsePattern()
        }
        if _lexer.match(.where) {
          catchWhere = try parseExpression(config: noTrailingConfig)
        }
      }
      let catchCodeBlock = try parseCodeBlock()
      let catchClause = DoStatement.CatchClause(
        pattern: catchPattern,
        whereExpression: catchWhere,
        codeBlock: catchCodeBlock)
      catchClauses.append(catchClause)
    }
    return DoStatement(codeBlock: codeBlock, catchClauses: catchClauses)
  }

  private func parseSwitchStatement() throws -> SwitchStatement {
    let expr = try parseExpression(config: noTrailingConfig)
    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.dummy)
    }
    var cases: [SwitchStatement.Case] = []
    var examined = _lexer.examine([.case, .default])
    while examined.0 {
      switch examined.1 {
      case .case:
        var itemList: [SwitchStatement.Case.Item] = []
        repeat {
          let pattern = try parsePattern(config: forPatternMatchingConfig)
          var whereExpr: Expression? = nil
          if _lexer.match(.where) {
            whereExpr = try parseExpression(config: noTrailingConfig)
          }
          let item = SwitchStatement.Case.Item(
            pattern: pattern, whereExpression: whereExpr)
          itemList.append(item)
        } while _lexer.match(.comma)
        guard _lexer.match(.colon) else {
          throw _raiseFatal(.dummy)
        }
        let stmts = try parseStatements()
        guard !stmts.isEmpty else {
          throw _raiseFatal(.dummy)
        }
        cases.append(.case(itemList, stmts))
      case .default:
        guard _lexer.match(.colon) else {
          throw _raiseFatal(.dummy)
        }
        let stmts = try parseStatements()
        guard !stmts.isEmpty else {
          throw _raiseFatal(.dummy)
        }
        cases.append(.default(stmts))
      default:
        break
      }
      examined = _lexer.examine([.case, .default])
    }
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.dummy)
    }
    return SwitchStatement(expression: expr, cases: cases)
  }

  private func parseGuardStatement() throws -> GuardStatement {
    let conditionList = try parseConditionList()
    guard _lexer.match(.else) else {
      throw _raiseFatal(.dummy)
    }
    let codeBlock = try parseCodeBlock()
    return GuardStatement(conditionList: conditionList, codeBlock: codeBlock)
  }

  private func parseIfStatement() throws -> IfStatement {
    let conditionList = try parseConditionList()
    let codeBlock = try parseCodeBlock()
    guard _lexer.match(.else) else {
      return IfStatement(conditionList: conditionList, codeBlock: codeBlock)
    }
    if _lexer.match(.if) {
      let elseIfStmt = try parseIfStatement()
      return IfStatement(
        conditionList: conditionList,
        codeBlock: codeBlock,
        elseClause: .elseif(elseIfStmt))
    }
    let elseCodeBlock = try parseCodeBlock()
    return IfStatement(
      conditionList: conditionList,
      codeBlock: codeBlock,
      elseClause: .else(elseCodeBlock))
  }

  private func parseRepeatWhileStatement() throws -> RepeatWhileStatement {
    let codeBlock = try parseCodeBlock()
    guard _lexer.match(.while) else {
      throw _raiseFatal(.dummy)
    }
    let expr = try parseExpression()
    return RepeatWhileStatement(conditionExpression: expr, codeBlock: codeBlock)
  }

  private func parseWhileStatement() throws -> WhileStatement {
    let conditionList = try parseConditionList()
    let codeBlock = try parseCodeBlock()
    return WhileStatement(conditionList: conditionList, codeBlock: codeBlock)
  }

  private func parseConditionList() throws -> ConditionList {
    var conditionList: ConditionList = []
    repeat {
      let condition = try parseCondition()
      conditionList.append(condition)
    } while _lexer.match(.comma)
    return conditionList
  }

  private func parseCondition() throws -> Condition {
    switch _lexer.read([.let, .var, .case, .hash]) {
    case .let:
      let cond = try parseCaseCondition()
      return .let(cond.pattern, cond.expression)
    case .var:
      let cond = try parseCaseCondition()
      return .var(cond.pattern, cond.expression)
    case .case:
      let cond = try parseCaseCondition(config: forPatternMatchingConfig)
      return .case(cond.pattern, cond.expression)
    case .hash:
      return try parseAvailabilityCondition()
    default:
      let expr = try parseExpression(config: noTrailingConfig)
      return .expression(expr)
    }
  }

  private func parseCaseCondition(
    config: ParserPatternConfig = ParserPatternConfig()
  ) throws -> (pattern: Pattern, expression: Expression) {
    var mutableConfig = config
    mutableConfig.parseTrailingClosure = false
    let pattern = try parsePattern(config: mutableConfig)
    if config.forPatternMatching,
      let exprPattern = pattern as? ExpressionPattern,
      let assignOpExpr = exprPattern.expression as? AssignmentOperatorExpression
    {
      let lhsPattern = ExpressionPattern(
        expression: assignOpExpr.leftExpression)
      let rhsExpr = assignOpExpr.rightExpression
      return (lhsPattern, rhsExpr)
    }
    guard _lexer.match(.assignmentOperator) else {
      throw _raiseFatal(.dummy)
    }
    let expr = try parseExpression(config: noTrailingConfig)
    return (pattern, expr)
  }

  private func parseAvailabilityCondition() throws -> Condition {
    guard case .identifier("available") = _lexer.look().kind else {
      throw _raiseFatal(.dummy)
    }
    _lexer.advance()
    guard _lexer.match(.leftParen) else {
      throw _raiseFatal(.dummy)
    }
    let supportedPlatforms = [
      "iOS", "iOSApplicationExtension",
      "macOS", "macOSApplicationExtension",
      "OSX", // TODO: remove this line at a later time
      "watchOS",
      "tvOS",
    ]
    var arguments: [AvailabilityCondition.Argument] = []
    repeat {
      switch _lexer.read([.dummyIdentifier, .dummyBinaryOperator]) {
      case .binaryOperator("*"):
        arguments.append(.all)
      case .identifier(let platformName)
        where supportedPlatforms.contains(platformName):
        // TODO: this entire switch stmt is very ugly, and the logic is poorly handled, need to rewrite
        switch _lexer.read([
          .dummyIntegerLiteral,
          .dummyFloatingPointLiteral,
        ]) {
        case .integerLiteral(let major, _, true):
          arguments.append(.major(platformName, Int(major)))
        case .floatingPointLiteral(_, let raw):
          guard let (major, minor) = splitDoubleRawToTwoIntegers(raw) else {
            throw _raiseFatal(.dummy)
          }
          if _lexer.match(.dot),
            case .integerLiteral(let patch, _, true) =
              _lexer.read(.dummyIntegerLiteral)
          {
            arguments.append(.patch(platformName, major, minor, Int(patch)))
          } else {
            arguments.append(.minor(platformName, major, minor))
          }
        default:
          throw _raiseFatal(.dummy)
        }
      default:
        throw _raiseFatal(.dummy)
      }
    } while _lexer.match(.comma)
    guard _lexer.match(.rightParen) else {
      throw _raiseFatal(.dummy)
    }
    return .availability(AvailabilityCondition(arguments: arguments))
  }

  private func parseForInStatement() throws -> ForInStatement {
    let isCaseMatching = _lexer.match(.case)
    let matchingPattern = try parsePattern()
    if !_lexer.match(.in) {
      try _raiseError(.dummy)
    }
    let collectionExpr = try parseExpression(config: noTrailingConfig)
    var whereClause: Expression? = nil
    if _lexer.match(.where) {
      whereClause = try parseExpression(config: noTrailingConfig)
    }
    let codeBlock = try parseCodeBlock()
    return ForInStatement(
      isCaseMatching: isCaseMatching,
      matchingPattern: matchingPattern,
      collection: collectionExpr,
      whereClause: whereClause,
      codeBlock: codeBlock)
  }

  // common used configurations
  private var noTrailingConfig: ParserExpressionConfig {
    return ParserExpressionConfig(parseTrailingClosure: false)
  }
  private var forPatternMatchingConfig: ParserPatternConfig {
    return ParserPatternConfig(forPatternMatching: true)
  }
}
