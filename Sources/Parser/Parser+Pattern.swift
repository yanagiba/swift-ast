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
import Source

struct ParserPatternConfig {
  var fromForInOrVarDecl: Bool
  var forPatternMatching: Bool
  var fromTuplePattern: Bool
  var parseTrailingClosure: Bool

  init(
    fromForInOrVarDecl: Bool = false,
    forPatternMatching: Bool = false,
    fromTuplePattern: Bool = false,
    parseTrailingClosure: Bool = true
  ) {
    self.fromForInOrVarDecl = fromForInOrVarDecl
    self.forPatternMatching = forPatternMatching
    self.fromTuplePattern = fromTuplePattern
    self.parseTrailingClosure = parseTrailingClosure
  }

  fileprivate var onlyIdWildCardOptional: Bool {
    return fromForInOrVarDecl && fromTuplePattern
  }

  fileprivate var parseTypeAnnotation: Bool {
    return !onlyIdWildCardOptional && !forPatternMatching
  }

  fileprivate func shouldParseTypeIdentifier(tokenKind: Token.Kind) -> Bool {
    switch tokenKind {
    case .dot, .leftChevron:
      return true
    case .binaryOperator("<"):
      return true
    default:
      return false
    }
  }

  fileprivate var tokenKinds: [Token.Kind] {
    var tokenKinds: [Token.Kind] = [
      .underscore,
      .dummyIdentifier,
      .Any,
      .Self,
      .get,
      .set,
      .left,
      .right,
      .open,
      .leftParen,
    ]
    if !onlyIdWildCardOptional {
      tokenKinds += [
        .var,
        .let,
        .dot,
      ]
      if forPatternMatching {
        tokenKinds.append(.is)
      }
    }
    return tokenKinds
  }
}

extension Parser {
  func parsePattern(
    config: ParserPatternConfig = ParserPatternConfig()
  ) throws -> Pattern {
    var resultPattern = try parsePatternCore(config: config)
    if !config.onlyIdWildCardOptional && _lexer.match(.as) {
      let type = try parseType()
      resultPattern = TypeCastingPattern(kind: .as(resultPattern, type))
    }
    return resultPattern
  }

  private func parsePatternCore(config: ParserPatternConfig) throws -> Pattern {
    let lookedRange = getLookedRange()
    switch _lexer.read(config.tokenKinds) {
    case .var where !config.onlyIdWildCardOptional:
      let pattern = try parsePattern(config: config)
      return ValueBindingPattern(kind: .var(pattern))
    case .let where !config.onlyIdWildCardOptional:
      let pattern = try parsePattern(config: config)
      return ValueBindingPattern(kind: .let(pattern))
    case .dot where !config.onlyIdWildCardOptional:
      return try parseDotHeadedEnumCasePattern(config: config)
    case .is where !config.onlyIdWildCardOptional && config.forPatternMatching:
      let type = try parseType()
      return TypeCastingPattern(kind: .is(type))
    case .underscore:
      return try parseUnderscoreHeadedPattern(
        config: config, startRange: lookedRange)
    case .identifier(let id):
      return try parseIdentifierHeadedPattern(
        id, config: config, startRange: lookedRange)
    case .Any:
      return try parseIdentifierHeadedPattern(
        "Any", config: config, startRange: lookedRange)
    case .Self:
      return try parseIdentifierHeadedPattern(
        "Self", config: config, startRange: lookedRange)
    case .get:
      return try parseIdentifierHeadedPattern(
        "get", config: config, startRange: lookedRange)
    case .set:
      return try parseIdentifierHeadedPattern(
        "set", config: config, startRange: lookedRange)
    case .left:
      return try parseIdentifierHeadedPattern(
        "left", config: config, startRange: lookedRange)
    case .right:
      return try parseIdentifierHeadedPattern(
        "right", config: config, startRange: lookedRange)
    case .open:
      return try parseIdentifierHeadedPattern(
        "open", config: config, startRange: lookedRange)
    case .leftParen:
      let tuplePattern = try parseTuplePattern(config: config)
      if config.parseTypeAnnotation,
        let typeAnnotation = try parseTypeAnnotation()
      {
        return TuplePattern(
          elementList: tuplePattern.elementList, typeAnnotation: typeAnnotation)
      }
      return tuplePattern
    default:
      if config.forPatternMatching {
        let updatedConfig = ParserExpressionConfig(
          parseTrailingClosure: config.parseTrailingClosure)
        let expr = try parseExpression(config: updatedConfig)
        return ExpressionPattern(expression: expr)
      }
      throw _raiseFatal(.dummy)
    }
  }

  private func parseUnderscoreHeadedPattern(
    config: ParserPatternConfig, startRange: SourceRange
  ) throws -> Pattern {
    var endLocation = startRange.end
    if config.forPatternMatching, _lexer.match(.postfixQuestion) {
      return OptionalPattern(identifier: "_")
    }
    let typeAnnotation =
      config.parseTypeAnnotation ? try parseTypeAnnotation() : nil
    if let explicitType = typeAnnotation {
      endLocation = explicitType.sourceRange.end
    }
    let wildcardPttrn = WildcardPattern(typeAnnotation: typeAnnotation)
    wildcardPttrn.setSourceRange(startRange.start, endLocation)
    return wildcardPttrn
  }

  private func parseIdentifierHeadedPattern(
    _ id: Identifier, config: ParserPatternConfig, startRange: SourceRange
  ) throws -> Pattern {
    if config.shouldParseTypeIdentifier(tokenKind: _lexer.look().kind) {
      return try parseIdentifierHeadedEnumCasePattern(
        id, config: config, startRange: startRange)
    }
    if _lexer.match(.postfixQuestion) {
      return OptionalPattern(identifier: id)
    }
    let typeAnnotation =
      config.parseTypeAnnotation ? try parseTypeAnnotation() : nil
    return IdentifierPattern(identifier: id, typeAnnotation: typeAnnotation)
  }

  private func parseDotHeadedEnumCasePattern(
    config: ParserPatternConfig
  ) throws -> EnumCasePattern {
    guard let name = _lexer.readNamedIdentifier() else {
      throw _raiseFatal(.dummy)
    }
    if _lexer.match(.leftParen) {
      let tuplePattern = try parseTuplePattern(config: config)
      return EnumCasePattern(name: name, tuplePattern: tuplePattern)
    }
    return EnumCasePattern(name: name)
  }

  private func parseIdentifierHeadedEnumCasePattern(
    _ id: Identifier, config: ParserPatternConfig, startRange: SourceRange
  ) throws -> EnumCasePattern {
    let typeIdentifier = try parseIdentifierType(id, startRange)
    var typeIds = typeIdentifier.names
    let lastId = typeIds.removeLast()
    let newName = lastId.name
    let updatedTypeIdentifier = TypeIdentifier(names: typeIds)
    if _lexer.match(.leftParen) {
      let tuplePattern = try parseTuplePattern(config: config)
      return EnumCasePattern(
        typeIdentifier: updatedTypeIdentifier,
        name: newName,
        tuplePattern: tuplePattern)
    }
    return EnumCasePattern(typeIdentifier: updatedTypeIdentifier, name: newName)
  }

  private func parseTuplePattern(
    config: ParserPatternConfig
  ) throws -> TuplePattern {
    if _lexer.match(.rightParen) {
      return TuplePattern()
    }
    var elements: [TuplePattern.Element] = []
    repeat {
      var fromTupleConfig = config
      fromTupleConfig.fromTuplePattern = true
      if _lexer.look(ahead: 1).kind == .colon {
        guard let id = _lexer.readNamedIdentifierOrWildcard() else {
          throw _raiseFatal(.dummy)
        }
        _lexer.advance()
        let pattern = try parsePattern(config: fromTupleConfig)
        elements.append(.namedPattern(id, pattern))
      } else {
        let pattern = try parsePattern(config: fromTupleConfig)
        elements.append(.pattern(pattern))
      }
    } while _lexer.match(.comma)
    if !_lexer.match(.rightParen) {
      try _raiseError(.dummy)
    }
    return TuplePattern(elementList: elements)
  }
}
