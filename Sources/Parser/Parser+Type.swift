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

extension Parser {
  func parseTypeAnnotation() throws -> TypeAnnotation? {
    let startLocation = getStartLocation()
    guard _lexer.match(.colon) else {
      return nil
    }

    var isInOutParameter = false

    let attrs = try parseAttributes()

    if _lexer.look().kind == .inout {
      _lexer.advance()
      isInOutParameter = true
    }

    let type = try parseType()
    let typeAnnotation = TypeAnnotation(type: type, attributes: attrs, isInOutParameter: isInOutParameter)
    typeAnnotation.setSourceRange(startLocation, type.sourceRange.end)
    return typeAnnotation
  }

  func parseType() throws -> Type {
    let attrs = try parseAttributes()
    let atomicType = try parseAtomicType()
    return try parseContainerType(atomicType, attributes: attrs)
  }

  private func parseAtomicType() throws -> Type {
    let lookedRange = getLookedRange()
    let matched = _lexer.read([
      .leftSquare,
      .leftParen,
      .protocol,
      .Any,
      .Self,
    ])
    switch matched {
    case .leftSquare:
      return try parseCollectionType(lookedRange.start)
    case .leftParen:
      return try parseParenthesizedType(lookedRange.start)
    case .protocol:
      return try parseOldSyntaxProtocolCompositionType(lookedRange.start)
    case .Any:
      let anyType = AnyType()
      anyType.setSourceRange(lookedRange)
      return anyType
    case .Self:
      let selfType = SelfType()
      selfType.setSourceRange(lookedRange)
      return selfType
    default:
      if let idHead = readNamedIdentifier() {
        return try parseIdentifierType(idHead, lookedRange)
      } else {
        throw _raiseFatal(.expectedType)
      }
    }
  }

  func parseIdentifierType(_ headId: Identifier, _ startRange: SourceRange) throws -> TypeIdentifier {
    var endLocation = startRange.end
    let headGenericArgumentClause = parseGenericArgumentClause()
    if let headGenericArg = headGenericArgumentClause {
      endLocation = headGenericArg.sourceRange.end
    }
    var names = [
      TypeIdentifier.TypeName(name: headId, genericArgumentClause: headGenericArgumentClause)
    ]

    while _lexer.look().kind == .dot, case let .identifier(name, backticked) = _lexer.readNext(.dummyIdentifier) {
      endLocation = getStartLocation()
      let genericArgumentClause = parseGenericArgumentClause()
      if let genericArg = genericArgumentClause {
        endLocation = genericArg.sourceRange.end
      }
      let typeIdentifierName = TypeIdentifier.TypeName(
        name: backticked ? .backtickedName(name) : .name(name),
        genericArgumentClause: genericArgumentClause)
      names.append(typeIdentifierName)
    }

    let idType = TypeIdentifier(names: names)
    idType.setSourceRange(startRange.start, endLocation)
    return idType
  }

  private func parseCollectionType(_ startLocation: SourceLocation) throws -> Type {
    let type = try parseType()
    var endLocation = getEndLocation()
    switch _lexer.read([.rightSquare, .colon]) {
    case .rightSquare:
      let arrayType = ArrayType(elementType: type)
      arrayType.setSourceRange(startLocation, endLocation)
      return arrayType
    case .colon:
      let valueType = try parseType()
      endLocation = getEndLocation()
      try match(.rightSquare, orFatal: .expectedCloseSquareDictionaryType)
      let dictType = DictionaryType(keyType: type, valueType: valueType)
      dictType.setSourceRange(startLocation, endLocation)
      return dictType
    default:
      throw _raiseFatal(.expectedCloseSquareArrayType)
    }
  }

  private func parseParenthesizedType(_ startLocation: SourceLocation) throws -> ParenthesizedType {
    var endLocation = getEndLocation()
    if _lexer.match(.rightParen) {
      let parenType = ParenthesizedType(elements: [])
      parenType.sourceRange = SourceRange(start: startLocation, end: endLocation)
      return parenType
    }

    var elements: [ParenthesizedType.Element] = []
    repeat {
      let element = try parseParenthesizedTypeElement()
      elements.append(element)
    } while _lexer.match(.comma)

    endLocation = getEndLocation()
    try match(.rightParen, orFatal: .expectedCloseParenParenthesizedType)

    let parenType = ParenthesizedType(elements: elements)
    parenType.sourceRange = SourceRange(start: startLocation, end: endLocation)
    return parenType
  }

  func parseTupleType(_ startLocation: SourceLocation) throws -> TupleType {
    return try parseParenthesizedType(startLocation).toTupleType()
  }

  private func parseParenthesizedTypeElement() throws -> ParenthesizedType.Element {
    var externalName: Identifier?
    var localName: Identifier?
    let type: Type
    var attributes: [Attribute] = []
    var isInOutParameter = false

    let looked = _lexer.look()
    switch looked.kind {
    case .at:
      attributes = try parseAttributes()
      isInOutParameter = _lexer.match(.inout)
      type = try parseType()
    case .inout:
      isInOutParameter = true
      _lexer.advance()
      type = try parseType()
    default:
      if let name = looked.kind.namedIdentifierOrWildcard?.id {
        let elementBody = try parseParenthesizedTypeElementBody(name)
        type = elementBody.type
        externalName = elementBody.externalName
        localName = elementBody.localName
        attributes = elementBody.attributes
        isInOutParameter = elementBody.isInOutParameter
      } else {
        type = try parseType()
      }
    }

    let isVariadic = _lexer.match([
      .prefixOperator("..."),
      .binaryOperator("..."),
      .postfixOperator("..."),
    ], exactMatch: true)

    return ParenthesizedType.Element(
      type: type,
      externalName: externalName,
      localName: localName,
      attributes: attributes,
      isInOutParameter: isInOutParameter,
      isVariadic: isVariadic)
  }

  private func parseParenthesizedTypeElementBody(_ name: Identifier) throws -> ParenthesizedType.Element {
    var externalName: Identifier?
    var internalName: Identifier?
    if let secondName = _lexer.look(ahead: 1).kind.namedIdentifier?.id, _lexer.look(ahead: 2).kind == .colon {
      externalName = name
      internalName = secondName
      _lexer.advance(by: 2)
    } else if _lexer.look(ahead: 1).kind == .colon {
      internalName = name
      _lexer.advance()
    } else {
      let nonLabeledType = try parseType()
      return ParenthesizedType.Element(type: nonLabeledType)
    }
    guard let typeAnnotation = try parseTypeAnnotation() else {
      throw _raiseFatal(.expectedTypeInTuple)
    }
    return ParenthesizedType.Element(
      type: typeAnnotation.type,
      externalName: externalName,
      localName: internalName,
      attributes: typeAnnotation.attributes,
      isInOutParameter: typeAnnotation.isInOutParameter)
  }

  func parseProtocolCompositionType(_ type: Type) throws -> ProtocolCompositionType {
    var endLocation = type.sourceRange.end
    var protocolTypes = [type]

    repeat {
      let idTypeRange = getLookedRange()
      guard let idHead = readNamedIdentifier() else {
        throw _raiseFatal(.expectedIdentifierTypeForProtocolComposition)
      }
      let idType = try parseIdentifierType(idHead, idTypeRange)
      protocolTypes.append(idType)
      endLocation = idType.sourceRange.end
    } while testAmp()

    let protoType = ProtocolCompositionType(protocolTypes: protocolTypes)
    protoType.setSourceRange(type.sourceLocation, endLocation)
    return protoType
  }

  func parseOldSyntaxProtocolCompositionType(_ startLocation: SourceLocation) throws -> ProtocolCompositionType {
    try assert(_lexer.matchUnicodeScalar("<"), orFatal: .expectedLeftChevronProtocolComposition)

    if _lexer.matchUnicodeScalar(">") {
      return ProtocolCompositionType(protocolTypes: [])
    }

    var protocolTypes: [Type] = []
    repeat {
      let nestedRange = getLookedRange()
      guard let idHead = readNamedIdentifier() else {
        throw _raiseFatal(.expectedIdentifierTypeForProtocolComposition)
      }
      protocolTypes.append(try parseIdentifierType(idHead, nestedRange))
    } while _lexer.match(.comma)

    let endLocation = getEndLocation()
    try assert(_lexer.matchUnicodeScalar(">"), orFatal: .expectedRightChevronProtocolComposition)

    let protoType = ProtocolCompositionType(protocolTypes: protocolTypes)
    protoType.setSourceRange(startLocation, endLocation)
    return protoType
  }

  private func parseContainerType( /*
    swift-lint:rule_configure(CYCLOMATIC_COMPLEXITY=16)
    swift-lint:suppress(high_ncss)
    */
    _ type: Type, attributes attrs: Attributes = []
  ) throws -> Type {
    func getAtomicType() throws -> Type {
      do {
        if let parenthesizedType = type as? ParenthesizedType {
          return try parenthesizedType.toTupleType()
        }
        return type
      } catch ParenthesizedType.TupleConversionError.isVariadic {
        throw _raiseFatal(.tupleTypeVariadicElement)
      } catch ParenthesizedType.TupleConversionError.multipleLabels {
        throw _raiseFatal(.tupleTypeMultipleLabels)
      }
    }

    if _lexer.matchUnicodeScalar("?", immediateFollow: true) {
      let atomicType = try getAtomicType()
      let containerType = OptionalType(wrappedType: atomicType)
      containerType.setSourceRange(atomicType.sourceLocation, atomicType.sourceRange.end.nextColumn)
      return try parseContainerType(containerType)
    }

    if _lexer.matchUnicodeScalar("!", immediateFollow: true) {
      let atomicType = try getAtomicType()
      let containerType = ImplicitlyUnwrappedOptionalType(wrappedType: atomicType)
      containerType.setSourceRange(atomicType.sourceLocation, atomicType.sourceRange.end.nextColumn)
      return try parseContainerType(containerType)
    }

    if testAmp() {
      let atomicType = try getAtomicType()
      let protocolCompositionType = try parseProtocolCompositionType(atomicType)
      return try parseContainerType(protocolCompositionType)
    }

    let examined = _lexer.examine([
      .throws, .rethrows, .arrow, .dot,
    ])
    guard examined.0 else {
      return try getAtomicType()
    }
    var parsedType: Type
    switch examined.1 {
    case .throws:
      try match(.arrow, orFatal: .throwsInWrongPosition("throws"))
      parsedType = try parseFunctionType(attributes: attrs, type: type, throwKind: .throwing)
    case .rethrows:
      try match(.arrow, orFatal: .throwsInWrongPosition("rethrows"))
      parsedType = try parseFunctionType(attributes: attrs, type: type, throwKind: .rethrowing)
    case .arrow:
      parsedType = try parseFunctionType(attributes: attrs, type: type, throwKind: .nothrowing)
    case .dot:
      let atomicType = try getAtomicType()
      let metatypeEndLocation = getEndLocation()
      let metatypeType: MetatypeType
      switch _lexer.read([.Type, .Protocol]) {
      case .Type:
        metatypeType = MetatypeType(referenceType: atomicType, kind: .type)
      case .Protocol:
        metatypeType = MetatypeType(referenceType: atomicType, kind: .protocol)
      default:
        throw _raiseFatal(.wrongIdentifierForMetatypeType)
      }
      metatypeType.setSourceRange(type.sourceLocation, metatypeEndLocation)
      parsedType = metatypeType
    default:
      return try getAtomicType()
    }
    return try parseContainerType(parsedType)
  }

  private func parseFunctionType(attributes attrs: Attributes, type: Type, throwKind: ThrowsKind) throws -> Type {
    guard let parenthesizedType = type as? ParenthesizedType else {
      throw _raiseFatal(.expectedFunctionTypeArguments)
    }
    let funcArguments = parenthesizedType.elements.map {
      FunctionType.Argument(type: $0.type,
        externalName: $0.externalName,
        localName: $0.localName,
        attributes: $0.attributes,
        isInOutParameter: $0.isInOutParameter,
        isVariadic: $0.isVariadic)
    }
    let returnType = try parseType()
    let funcType = FunctionType(
      attributes: attrs,
      arguments: funcArguments,
      returnType: returnType,
      throwsKind: throwKind)
    funcType.setSourceRange(type.sourceLocation, returnType.sourceRange.end)
    return funcType
  }

  func parseTypeInheritanceClause() throws -> TypeInheritanceClause? {
    guard _lexer.match(.colon) else {
      return nil
    }
    var classRequirement = false
    if _lexer.match(.class) {
      classRequirement = true
      guard _lexer.match(.comma) else {
        return TypeInheritanceClause(classRequirement: classRequirement)
      }
    }
    var types = [TypeIdentifier]()
    repeat {
      let typeSourceRange = getLookedRange()
      if _lexer.match(.class) {
        throw _raiseFatal(.lateClassRequirement)
      } else if let idHead = readNamedIdentifier() {
        let type = try parseIdentifierType(idHead, typeSourceRange)
        types.append(type)
      } else {
        throw _raiseFatal(.expectedTypeRestriction)
      }
    } while _lexer.match(.comma)
    return TypeInheritanceClause( classRequirement: classRequirement, typeInheritanceList: types)
  }
}

fileprivate class ParenthesizedType : Type {
  fileprivate enum TupleConversionError : Error {
    case isVariadic
    case multipleLabels
  }

  fileprivate class Element {
    fileprivate let externalName: Identifier?
    fileprivate let localName: Identifier?
    fileprivate let type: Type
    fileprivate let attributes: Attributes
    fileprivate let isInOutParameter: Bool
    fileprivate let isVariadic: Bool

    fileprivate init(type: Type,
      externalName: Identifier? = nil,
      localName: Identifier? = nil,
      attributes: Attributes = [],
      isInOutParameter: Bool = false,
      isVariadic: Bool = false)
    {
      self.externalName = externalName
      self.localName = localName
      self.type = type
      self.attributes = attributes
      self.isInOutParameter = isInOutParameter
      self.isVariadic = isVariadic
    }
  }

  fileprivate let elements: [Element]

  fileprivate init(elements: [Element]) {
    self.elements = elements
  }

  fileprivate var textDescription: String {
    return ""
  }

  fileprivate var sourceRange: SourceRange = .EMPTY

  fileprivate func toTupleType() throws -> TupleType {
    var tupleElements: [TupleType.Element] = []
    for e in elements {
      if e.externalName != nil {
        throw TupleConversionError.multipleLabels
      } else if e.isVariadic {
        throw TupleConversionError.isVariadic
      } else if let name = e.localName {
        let tupleElement = TupleType.Element(
          type: e.type,
          name: name,
          attributes: e.attributes,
          isInOutParameter: e.isInOutParameter)
        tupleElements.append(tupleElement)
      } else {
        let tupleElement = TupleType.Element(type: e.type)
        tupleElements.append(tupleElement)
      }
    }
    let tupleType = TupleType(elements: tupleElements)
    tupleType.setSourceRange(sourceRange)
    return tupleType
  }
}
