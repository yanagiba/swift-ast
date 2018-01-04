/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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
      .leftParen,
      // below are keywords also can be used as identifier pattern
      .Any,
      .Self,
      .get,
      .set,
      .left,
      .right,
      .open,
      .prefix,
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
      typeCastingPttrn.setSourceRange(resultPattern.sourceLocation, type.sourceRange.end)
      resultPattern = typeCastingPttrn
    }
    return resultPattern
  }

  private func parsePatternCore(config: ParserPatternConfig) throws -> Pattern {
    let lookedRange = getLookedRange()
    let patternHead = _lexer.read(config.tokenKinds)
    switch patternHead {
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
      let enumCasePttrn = try parseDotHeadedEnumCasePattern(config: config, startLocation: lookedRange.start)
      return wrapOptional(enumCasePattern: enumCasePttrn, config: config)
    case .is where !config.onlyIdWildCardOptional && config.forPatternMatching:
      let type = try parseType()
      let typeCastingPttrn = TypeCastingPattern(kind: .is(type))
      typeCastingPttrn.setSourceRange(lookedRange.start, type.sourceRange.end)
      return typeCastingPttrn
    case .underscore:
      return try parseUnderscoreHeadedPattern(config: config, startRange: lookedRange)
    case .identifier, .Any, .Self, .get, .set, .left, .right, .open, .prefix, .postfix:
      guard let idHead = patternHead.namedIdentifier?.id else {
        throw _raiseFatal(.expectedPattern)
      }
      return try parseIdentifierHeadedPattern(idHead, config: config, startRange: lookedRange)
    case .leftParen:
      return try parseTuplePattern(config: config, startLocation: lookedRange.start)
    default:
      if config.forPatternMatching {
        let updatedConfig = ParserExpressionConfig(parseTrailingClosure: config.parseTrailingClosure)
        let expr = try parseExpression(config: updatedConfig)
        return ExpressionPattern(expression: expr)
      }
      throw _raiseFatal(.expectedPattern)
    }
  }

  private func parseUnderscoreHeadedPattern(config: ParserPatternConfig, startRange: SourceRange) throws -> Pattern {
    var endLocation = startRange.end
    if config.forPatternMatching, _lexer.match(.postfixQuestion) {
      let optPttrn = OptionalPattern(kind: .wildcard)
      optPttrn.setSourceRange(startRange.start, endLocation.nextColumn)
      return optPttrn
    }
    let typeAnnotation = config.parseTypeAnnotation ? try parseTypeAnnotation() : nil
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
      let enumCasePttrn = try parseIdentifierHeadedEnumCasePattern(id, config: config, startRange: startRange)
      return wrapOptional(enumCasePattern: enumCasePttrn, config: config)
    }
    var endLocation = startRange.end
    if config.forPatternMatching, case .binaryOperator(let biOp) = _lexer.read(.dummyBinaryOperator) {
      let lhsExpr = IdentifierExpression(kind: .identifier(id, nil))
      let rhsExpr = try parseExpression()
      let biOpExpr = BinaryOperatorExpression(binaryOperator: biOp, leftExpression: lhsExpr, rightExpression: rhsExpr)
      return ExpressionPattern(expression: biOpExpr)
    }
    if _lexer.match(.postfixQuestion) {
      let idPttrnForOpt = IdentifierPattern(identifier: id)
      idPttrnForOpt.setSourceRange(startRange)
      let optPttrn = OptionalPattern(kind: .identifier(idPttrnForOpt))
      optPttrn.setSourceRange(startRange.start, endLocation.nextColumn)
      return optPttrn
    }
    let typeAnnotation = config.parseTypeAnnotation ? try parseTypeAnnotation() : nil
    if let explicitType = typeAnnotation {
      endLocation = explicitType.sourceRange.end
    }
    let idPttrn = IdentifierPattern(identifier: id, typeAnnotation: typeAnnotation)
    idPttrn.setSourceRange(startRange.start, endLocation)
    return idPttrn
  }

  private func parseDotHeadedEnumCasePattern(
    config: ParserPatternConfig, startLocation: SourceLocation
  ) throws -> EnumCasePattern {
    let endLocation = getEndLocation()
    guard let name = readNamedIdentifier() else {
      throw _raiseFatal(.expectedCaseNamePattern)
    }

    let tupleStartLocation = getStartLocation()
    if _lexer.match(.leftParen) {
      let tuplePattern = try parseTuplePatternCore(config: config, startLocation: tupleStartLocation)
      let enumCasePttrn = EnumCasePattern(name: name, tuplePattern: tuplePattern)
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
      let tuplePattern = try parseTuplePatternCore(config: config, startLocation: tupleStartLocation)
      let enumCasePttrn = EnumCasePattern(
        typeIdentifier: updatedTypeIdentifier,
        name: newName,
        tuplePattern: tuplePattern)
      enumCasePttrn.setSourceRange(startRange.start, tuplePattern.sourceRange.end)
      return enumCasePttrn
    }
    let enumCasePttrn = EnumCasePattern(typeIdentifier: updatedTypeIdentifier, name: newName)
    enumCasePttrn.setSourceRange(typeIdentifier.sourceRange)
    return enumCasePttrn
  }

  private func wrapOptional(enumCasePattern: EnumCasePattern, config: ParserPatternConfig) -> Pattern {
    guard config.forPatternMatching, _lexer.match(.postfixQuestion) else {
      return enumCasePattern
    }

    let optPttrn = OptionalPattern(kind: .enumCase(enumCasePattern))
    optPttrn.setSourceRange(enumCasePattern.sourceRange.start, enumCasePattern.sourceRange.end.nextColumn)
    return optPttrn
  }

  private func parseTuplePattern(config: ParserPatternConfig, startLocation: SourceLocation) throws -> Pattern {
    let tuplePattern = try parseTuplePatternCore(config: config, startLocation: startLocation)

    // wrap into optional if necessary
    if config.forPatternMatching, _lexer.match(.postfixQuestion) {
      let optPttrn = OptionalPattern(kind: .tuple(tuplePattern))
      optPttrn.setSourceRange(tuplePattern.sourceRange.start, tuplePattern.sourceRange.end.nextColumn)
      return optPttrn
    }

    // append type annotation if necessary
    if config.parseTypeAnnotation, let typeAnnotation = try parseTypeAnnotation() {
      let tuplePttrn = TuplePattern(elementList: tuplePattern.elementList, typeAnnotation: typeAnnotation)
      tuplePttrn.setSourceRange(tuplePattern.sourceLocation, typeAnnotation.sourceRange.end)
      return tuplePttrn
    }

    return tuplePattern
  }

  private func parseTuplePatternCore(
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
        guard let id = readNamedIdentifierOrWildcard() else {
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
    try match(.rightParen, orFatal: .expectedTuplePatternCloseParenthesis)

    let tuplePttrn = TuplePattern(elementList: elements)
    tuplePttrn.setSourceRange(startLocation, endLocation)
    return tuplePttrn
  }
}
