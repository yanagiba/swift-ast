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

extension Parser {
  func parseTypeAnnotation() throws -> TypeAnnotation? {
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
    return TypeAnnotation(
      type: type, attributes: attrs, isInOutParameter: isInOutParameter)
  }

  func parseType() throws -> Type {
    let attrs = try parseAttributes()
    let atomicType = try parseAtomicType()
    return try parseContainerType(atomicType, attributes: attrs)
  }

  private func parseAtomicType() throws -> Type {
    let matched = _lexer.read([
      .leftSquare,
      .leftParen,
      .protocol,
      .Any,
      .Self,
    ])
    switch matched {
    case .leftSquare:
      return try parseCollectionType()
    case .leftParen:
      return try parseParenthesizedType()
    case .protocol:
      return try parseOldSyntaxProtocolCompositionType()
    case .Any:
      return AnyType()
    case .Self:
      return SelfType()
    default:
      if let idHead = _lexer.readNamedIdentifier() {
        return try parseIdentifierType(idHead)
      } else {
        throw _raiseFatal(.dummy)
      }
    }
  }

  func parseIdentifierType(_ headName: String) throws -> TypeIdentifier {
    let headGenericArgumentClause = parseGenericArgumentClause()
    var names = [
      TypeIdentifier.TypeName(
        name: headName, genericArgumentClause: headGenericArgumentClause)
    ]

    while _lexer.look().kind == .dot,
    case let .identifier(name) = _lexer.readNext(.dummyIdentifier)
    {
      let genericArgumentClause = parseGenericArgumentClause()
      let typeIdentifierName = TypeIdentifier.TypeName(
        name: name, genericArgumentClause: genericArgumentClause)
        names.append(typeIdentifierName)
    }

    return TypeIdentifier(names: names)
  }

  private func parseCollectionType() throws -> Type {
    let type = try parseType()
    switch _lexer.read([.rightSquare, .colon]) {
    case .rightSquare:
      return ArrayType(elementType: type)
    case .colon:
      let valueType = try parseType()
      guard _lexer.match(.rightSquare) else {
        throw _raiseFatal(.dummy)
      }
      return DictionaryType(keyType: type, valueType: valueType)
    default:
      throw _raiseFatal(.dummy)
    }
  }

  private func parseParenthesizedType() throws -> ParenthesizedType {
    if _lexer.match(.rightParen) {
      return ParenthesizedType(elements: [])
    }
    var elements: [ParenthesizedType.Element] = []
    repeat {
      let element = try parseParenthesizedTypeElement()
      elements.append(element)
    } while _lexer.match(.comma)
    if !_lexer.match(.rightParen) {
      try _raiseError(.dummy)
    }
    return ParenthesizedType(elements: elements)
  }

  func parseTupleType() throws -> TupleType {
    let parenthesizedType = try parseParenthesizedType()
    guard let tupleType = parenthesizedType.toTupleType() else {
      throw _raiseFatal(.dummy)
    }
    return tupleType
  }

  private func parseParenthesizedTypeElement()
    throws -> ParenthesizedType.Element
  {
    var externalName: String? = nil
    var localName: String? = nil
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
      if let name = looked.kind.namedIdentifierOrWildcard {
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

  private func parseParenthesizedTypeElementBody(_ name: String)
    throws -> ParenthesizedType.Element
  {
    var externalName: String? = nil
    var internalName: String? = nil
    if let secondName = _lexer.look(ahead: 1).kind.namedIdentifier,
      _lexer.look(ahead: 2).kind == .colon
    {
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
      throw _raiseFatal(.dummy)
    }
    return ParenthesizedType.Element(
      type: typeAnnotation.type,
      externalName: externalName,
      localName: internalName,
      attributes: typeAnnotation.attributes,
      isInOutParameter: typeAnnotation.isInOutParameter)
  }

  func parseProtocolCompositionType(_ type: Type)
    throws -> ProtocolCompositionType
  {
    var protocolTypes = [type]
    repeat {
      guard case let .identifier(idHead) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.dummy)
      }
      let type = try parseIdentifierType(idHead)
      protocolTypes.append(type)
    } while testAmp()
    return ProtocolCompositionType(protocolTypes: protocolTypes)
  }

  func parseOldSyntaxProtocolCompositionType() throws -> ProtocolCompositionType {
    if !_lexer.matchUnicodeScalar("<") {
      try _raiseError(.dummy)
    }

    if _lexer.matchUnicodeScalar(">") {
      return ProtocolCompositionType(protocolTypes: [])
    }

    var protocolTypes: [Type] = []
    repeat {
      guard case let .identifier(idHead) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.dummy)
      }
      protocolTypes.append(try parseIdentifierType(idHead))
    } while _lexer.match(.comma)

    if !_lexer.matchUnicodeScalar(">") {
      try _raiseError(.dummy)
    }

    return ProtocolCompositionType(protocolTypes: protocolTypes)
  }

  private func parseContainerType(
    _ type: Type, attributes attrs: Attributes = []
  ) throws -> Type {
    func getAtomicType() throws -> Type {
      guard let atomicType = type.toAtomic() else {
        throw _raiseFatal(.dummy)
      }
      return atomicType
    }

    if _lexer.matchUnicodeScalar("?", immediateFollow: true) {
      let atomicType = try getAtomicType()
      let containerType = OptionalType(wrappedType: atomicType)
      return try parseContainerType(containerType)
    }

    if _lexer.matchUnicodeScalar("!", immediateFollow: true) {
      let atomicType = try getAtomicType()
      let containerType =
        ImplicitlyUnwrappedOptionalType(wrappedType: atomicType)
      return try parseContainerType(containerType)
    }

    if testAmp() {
      let atomicType = try getAtomicType()
      let protocolCompositionType = try parseProtocolCompositionType(atomicType)
      return try parseContainerType(protocolCompositionType)
    }

    let examined = _lexer.examine([
      .throws, .rethrows, .arrow, .postfixQuestion, .postfixExclaim, .dot,
    ])
    guard examined.0 else {
      return try getAtomicType()
    }
    var parsedType: Type
    switch examined.1 {
    case .throws:
      guard _lexer.match(.arrow) else {
        throw _raiseFatal(.dummy)
      }
      parsedType = try parseFunctionType(
        attributes: attrs, type: type, throwKind: .throwing)
    case .rethrows:
      guard _lexer.match(.arrow) else {
        throw _raiseFatal(.dummy)
      }
      parsedType = try parseFunctionType(
        attributes: attrs, type: type, throwKind: .rethrowing)
    case .arrow:
      parsedType = try parseFunctionType(
        attributes: attrs, type: type, throwKind: .nothrowing)
    case .postfixQuestion:
      let atomicType = try getAtomicType()
      parsedType = OptionalType(wrappedType: atomicType)
    case .postfixExclaim:
      let atomicType = try getAtomicType()
      parsedType = ImplicitlyUnwrappedOptionalType(wrappedType: atomicType)
    case .dot:
      let atomicType = try getAtomicType()
      switch _lexer.read([.Type, .Protocol]) {
      case .Type:
        parsedType = MetatypeType(referenceType: atomicType, kind: .type)
      case .Protocol:
        parsedType = MetatypeType(referenceType: atomicType, kind: .protocol)
      default:
        throw _raiseFatal(.dummy)
      }
    default:
      return try getAtomicType()
    }
    return try parseContainerType(parsedType)
  }

  private func parseFunctionType(
    attributes attrs: Attributes, type: Type, throwKind: ThrowsKind
  ) throws -> Type {
    guard let parenthesizedType = type as? ParenthesizedType else {
      throw _raiseFatal(.dummy)
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
    return FunctionType(
      attributes: attrs,
      arguments: funcArguments,
      returnType: returnType,
      throwsKind: throwKind)
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
      if _lexer.match(.class) {
        try _raiseError(.dummy)
      } else if let idHead = _lexer.readNamedIdentifier() {
        let type = try parseIdentifierType(idHead)
        types.append(type)
      } else {
        try _raiseError(.dummy)
      }
    } while _lexer.match(.comma)
    return TypeInheritanceClause(
      classRequirement: classRequirement, typeInheritanceList: types)
  }
}

fileprivate class ParenthesizedType : Type {
  fileprivate class Element {
    fileprivate let externalName: String?
    fileprivate let localName: String?
    fileprivate let type: Type
    fileprivate let attributes: Attributes
    fileprivate let isInOutParameter: Bool
    fileprivate let isVariadic: Bool

    fileprivate init(type: Type,
      externalName: String? = nil,
      localName: String? = nil,
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

  fileprivate func toTupleType() -> TupleType? {
    var tupleElements: [TupleType.Element] = []
    for e in elements {
      if e.isVariadic || e.externalName != nil {
        return nil
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
    return TupleType(elements: tupleElements)
  }
}

fileprivate extension Type {
  fileprivate func toAtomic() -> Type? {
    switch self {
    case let parenthesizedType as ParenthesizedType:
      return parenthesizedType.toTupleType()
    default:
      return self
    }
  }
}
