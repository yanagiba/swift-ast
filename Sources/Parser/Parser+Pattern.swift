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
      let typeCastingPttrn = TypeCastingPattern(kind: .as(resultPattern, type))
      typeCastingPttrn.setSourceRange(
        resultPattern.sourceLocation, type.sourceRange.end)
      resultPattern = typeCastingPttrn
    }
    return resultPattern
  }

  private func parsePatternCore(config: ParserPatternConfig) throws -> Pattern {
    let lookedRange = getLookedRange()
    switch _lexer.read(config.tokenKinds) {
    case .var where !config.onlyIdWildCardOptional:
      let pattern = try parsePattern(config: config)
      let valBindingPttrn = ValueBindingPattern(kind: .var(pattern))
      valBindingPttrn.setSourceRange(lookedRange.start, pattern.sourceRange.end)
      return valBindingPttrn
    case .let where !config.onlyIdWildCardOptional:
      let pattern = try parsePattern(config: config)
      let valBindingPttrn = ValueBindingPattern(kind: .let(pattern))
      valBindingPttrn.setSourceRange(lookedRange.start, pattern.sourceRange.end)
      return valBindingPttrn
    case .dot where !config.onlyIdWildCardOptional:
      return try parseDotHeadedEnumCasePattern(
        config: config, startLocation: lookedRange.start)
    case .is where !config.onlyIdWildCardOptional && config.forPatternMatching:
      let type = try parseType()
      let typeCastingPttrn = TypeCastingPattern(kind: .is(type))
      typeCastingPttrn.setSourceRange(lookedRange.start, type.sourceRange.end)
      return typeCastingPttrn
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
      let tuplePattern =
        try parseTuplePattern(config: config, startLocation: lookedRange.start)
      if config.parseTypeAnnotation,
        let typeAnnotation = try parseTypeAnnotation()
      {
        let tuplePttrn = TuplePattern(
          elementList: tuplePattern.elementList, typeAnnotation: typeAnnotation)
        tuplePttrn.setSourceRange(
          tuplePattern.sourceLocation, typeAnnotation.sourceRange.end)
        return tuplePttrn
      }
      return tuplePattern
    default:
      if config.forPatternMatching {
        let updatedConfig = ParserExpressionConfig(
          parseTrailingClosure: config.parseTrailingClosure)
        let expr = try parseExpression(config: updatedConfig)
        return ExpressionPattern(expression: expr)
      }
      throw _raiseFatal(.expectedPattern)
    }
  }

  private func parseUnderscoreHeadedPattern(
    config: ParserPatternConfig, startRange: SourceRange
  ) throws -> Pattern {
    var endLocation = startRange.end
    if config.forPatternMatching, _lexer.match(.postfixQuestion) {
      let optPttrn = OptionalPattern(identifier: "_")
      optPttrn.setSourceRange(startRange.start, endLocation.nextColumn)
      return optPttrn
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
    var endLocation = startRange.end
    if _lexer.match(.postfixQuestion) {
      let optPttrn = OptionalPattern(identifier: id)
      optPttrn.setSourceRange(startRange.start, endLocation.nextColumn)
      return optPttrn
    }
    let typeAnnotation =
      config.parseTypeAnnotation ? try parseTypeAnnotation() : nil
    if let explicitType = typeAnnotation {
      endLocation = explicitType.sourceRange.end
    }
    let idPttrn = IdentifierPattern(
      identifier: id, typeAnnotation: typeAnnotation)
    idPttrn.setSourceRange(startRange.start, endLocation)
    return idPttrn
  }

  private func parseDotHeadedEnumCasePattern(
    config: ParserPatternConfig, startLocation: SourceLocation
  ) throws -> EnumCasePattern {
    let endLocation = getEndLocation()
    guard let name = _lexer.readNamedIdentifier() else {
      throw _raiseFatal(.expectedCaseNamePattern)
    }

    let tupleStartLocation = getStartLocation()
    if _lexer.match(.leftParen) {
      let tuplePattern =
        try parseTuplePattern(config: config, startLocation: tupleStartLocation)
      let enumCasePttrn =
        EnumCasePattern(name: name, tuplePattern: tuplePattern)
      enumCasePttrn.setSourceRange(startLocation, tuplePattern.sourceRange.end)
      return enumCasePttrn
    }
    let enumCasePttrn = EnumCasePattern(name: name)
    enumCasePttrn.setSourceRange(startLocation, endLocation)
    return enumCasePttrn
  }

  private func parseIdentifierHeadedEnumCasePattern(
    _ id: Identifier, config: ParserPatternConfig, startRange: SourceRange
  ) throws -> EnumCasePattern {
    let typeIdentifier = try parseIdentifierType(id, startRange)
    var typeIds = typeIdentifier.names
    let lastId = typeIds.removeLast()
    let newName = lastId.name
    let updatedTypeIdentifier = TypeIdentifier(names: typeIds)
    let tupleStartLocation = getStartLocation()
    if _lexer.match(.leftParen) {
      let tuplePattern =
        try parseTuplePattern(config: config, startLocation: tupleStartLocation)
      let enumCasePttrn = EnumCasePattern(
        typeIdentifier: updatedTypeIdentifier,
        name: newName,
        tuplePattern: tuplePattern)
      enumCasePttrn.setSourceRange(
        startRange.start, tuplePattern.sourceRange.end)
      return enumCasePttrn
    }
    let enumCasePttrn =
      EnumCasePattern(typeIdentifier: updatedTypeIdentifier, name: newName)
    enumCasePttrn.setSourceRange(typeIdentifier.sourceRange)
    return enumCasePttrn
  }

  private func parseTuplePattern(
    config: ParserPatternConfig, startLocation: SourceLocation
  ) throws -> TuplePattern {
    var endLocation = getEndLocation()

    if _lexer.match(.rightParen) {
       let tuplePttrn = TuplePattern()
       tuplePttrn.setSourceRange(startLocation, endLocation)
       return tuplePttrn
    }

    var elements: [TuplePattern.Element] = []
    repeat {
      var fromTupleConfig = config
      fromTupleConfig.fromTuplePattern = true
      if _lexer.look(ahead: 1).kind == .colon {
        guard let id = _lexer.readNamedIdentifierOrWildcard() else {
          throw _raiseFatal(.expectedIdentifierTuplePattern)
        }
        _lexer.advance()
        let pattern = try parsePattern(config: fromTupleConfig)
        elements.append(.namedPattern(id, pattern))
      } else {
        let pattern = try parsePattern(config: fromTupleConfig)
        elements.append(.pattern(pattern))
      }
    } while _lexer.match(.comma)

    endLocation = getEndLocation()
    if !_lexer.match(.rightParen) {
      throw _raiseFatal(.expectedTuplePatternCloseParenthesis)
    }

    let tuplePttrn = TuplePattern(elementList: elements)
    tuplePttrn.setSourceRange(startLocation, endLocation)
    return tuplePttrn
  }
}
