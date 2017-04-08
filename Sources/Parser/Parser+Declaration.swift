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
import Diagnostic

extension Parser {
  func parseTopLevelDeclaration() throws -> TopLevelDeclaration {
    let stmts = try parseStatements()
    return TopLevelDeclaration(statements: stmts)
  }

  func parseCodeBlock() throws -> CodeBlock {
    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpectedForCodeBlock)
    }
    let stmts = try parseStatements()
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.rightBraceExpectedForCodeBlock)
    }
    return CodeBlock(statements: stmts)
  }

  func parseDeclaration() throws -> Declaration {
    let attrs = try parseAttributes()
    let modifiers = parseModifiers()

    let declHeadTokens: [Token.Kind] = [
      .import, .let, .var, .typealias, .func, .enum, .indirect, .struct,
      .init, .deinit, .extension, .subscript, .operator, .protocol
    ]
    switch _lexer.read(declHeadTokens) {
    case .import:
      return try parseImportDeclaration(withAttributes: attrs)
    case .let:
      return try parseConstantDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .var:
      return try parseVariableDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .typealias:
      return try parseTypealiasDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .func:
      return try parseFunctionDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .enum:
      return try parseEnumDeclaration(
        withAttributes: attrs, modifiers: modifiers, isIndirect: false)
    case .indirect:
      guard _lexer.match(.enum) else {
        throw _raiseFatal(.enumExpectedAfterIndirect)
      }
      return try parseEnumDeclaration(
        withAttributes: attrs, modifiers: modifiers, isIndirect: true)
    case .struct:
      return try parseStructDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .init:
      return try parseInitializerDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .deinit where modifiers.isEmpty:
      return try parseDeinitializerDeclaration(withAttributes: attrs)
    case .extension:
      return try parseExtensionDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .subscript:
      return try parseSubscriptDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    case .operator where attrs.isEmpty:
      return try parseOperatorDeclaration(withModifiers: modifiers)
    case .protocol:
      return try parseProtocolDeclaration(
        withAttributes: attrs, modifiers: modifiers)
    default:
      // try parsing class declaration
      if let lastModifier = modifiers.last, lastModifier == .class {
        let otherModifiers = Array(modifiers.dropLast())
        return try parseClassDeclaration(
          withAttributes: attrs, modifiers: otherModifiers)
      }

      // try parsing precedence group declaration
      if attrs.isEmpty,
        modifiers.isEmpty,
        case .identifier(let keyword) = _lexer.look().kind,
        keyword == "precedencegroup"
      {
        _lexer.advance()
        return try parsePrecedenceGroupDeclaration()
      }

      // tried very hard and failed, throw exception
      throw _raiseFatal(.badDeclaration)
    }
  }

  private func parseProtocolDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> ProtocolDeclaration {
    func parsePropertyMember(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.missingPropertyMemberName)
      }
      guard let typeAnnotation = try parseTypeAnnotation() else {
        throw _raiseFatal(.dummy)
      }
      guard isGetterSetterBlockHead() else {
        throw _raiseFatal(.dummy)
      }
      let (getterSetterBlock, hasCodeBlock) = try parseGetterSetterBlock()
      guard !hasCodeBlock else {
        throw _raiseFatal(.dummy)
      }
      let getter = GetterSetterKeywordBlock.GetterKeywordClause(
        attributes: getterSetterBlock.getter.attributes,
        mutationModifier: getterSetterBlock.getter.mutationModifier)
      let setter = getterSetterBlock.setter.map {
          GetterSetterKeywordBlock.SetterKeywordClause(
            attributes: $0.attributes, mutationModifier: $0.mutationModifier)
        }
      let getterSetterKeywordBlock =
        GetterSetterKeywordBlock(getter: getter, setter: setter)

      let member = ProtocolDeclaration.PropertyMember(
        attributes: attrs,
        modifiers: modifiers,
        name: name,
        typeAnnotation: typeAnnotation,
        getterSetterKeywordBlock: getterSetterKeywordBlock)

      return .property(member)
    }

    func parseMethodMember(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      let funcDecl = try parseFunctionDeclaration(
        withAttributes: attrs, modifiers: modifiers)
      guard funcDecl.body == nil else {
        throw _raiseFatal(.dummy)
      }

      let member = ProtocolDeclaration.MethodMember(
        attributes: attrs,
        modifiers: modifiers,
        name: funcDecl.name,
        genericParameter: funcDecl.genericParameterClause,
        signature: funcDecl.signature,
        genericWhere: funcDecl.genericWhereClause)

      return .method(member)
    }

    func parseInitializerMember(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      let initDecl = try parseInitializerDeclaration(
        withAttributes: attrs, modifiers: modifiers, forProtocolMember: true)

      let member = ProtocolDeclaration.InitializerMember(
        attributes: attrs,
        modifiers: modifiers,
        kind: initDecl.kind,
        genericParameter: initDecl.genericParameterClause,
        parameterList: initDecl.parameterList,
        throwsKind: initDecl.throwsKind,
        genericWhere: initDecl.genericWhereClause)

      return .initializer(member)
    }

    func parseSubscriptMember(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      let subscriptDecl = try parseSubscriptDeclaration(
        withAttributes: attrs, modifiers: modifiers)
      guard case .getterSetterKeywordBlock(let getterSetterKeywordBlock) =
        subscriptDecl.body else
      {
        throw _raiseFatal(.dummy)
      }

      let member = ProtocolDeclaration.SubscriptMember(
        attributes: attrs,
        modifiers: modifiers,
        parameterList: subscriptDecl.parameterList,
        resultAttributes: subscriptDecl.resultAttributes,
        resultType: subscriptDecl.resultType,
        getterSetterKeywordBlock: getterSetterKeywordBlock)

      return .subscript(member)
    }

    func parseAssociatedType(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      var accessLevelModifier: AccessLevelModifier? = nil
      if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
        accessLevelModifier = modifier
      }

      guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.dummy)
      }

      let typeInheritanceClause = try parseTypeInheritanceClause()

      var assignmentType: Type? = nil
      if _lexer.match(.assignmentOperator) {
        assignmentType = try parseType()
      }

      let member = ProtocolDeclaration.AssociativityTypeMember(
        attributes: attrs,
        accessLevelModifier: accessLevelModifier,
        name: name,
        typeInheritance: typeInheritanceClause,
        assignmentType: assignmentType)

      return .associatedType(member)
    }

    func parseMember() throws -> ProtocolDeclaration.Member {
      let attrs = try parseAttributes()
      let modifiers = parseModifiers()
      switch _lexer.read([.var, .func, .init, .subscript, .hash]) {
      case .var:
        return try parsePropertyMember(
          withAttributes: attrs, modifiers: modifiers)
      case .func:
        return try parseMethodMember(
          withAttributes: attrs, modifiers: modifiers)
      case .init:
        return try parseInitializerMember(
          withAttributes: attrs, modifiers: modifiers)
      case .subscript:
        return try parseSubscriptMember(
          withAttributes: attrs, modifiers: modifiers)
      case .hash:
        let compCtrlStmt = try parseCompilerControlStatement()
        return .compilerControl(compCtrlStmt)
      default:
        if _lexer.look().kind == .identifier("associatedtype") {
          _lexer.advance()
          return try parseAssociatedType(
            withAttributes: attrs, modifiers: modifiers)
        }
        throw _raiseFatal(.dummy)
      }
    }

    var accessLevelModifier: AccessLevelModifier? = nil
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }

    guard let name = _lexer.look().kind.structName else {
      throw _raiseFatal(.dummy)
    }
    _lexer.advance()

    let typeInheritanceClause = try parseTypeInheritanceClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpectedForDeclarationBody)
    }

    var members: [ProtocolDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let member = try parseMember()
      members.append(member)
    }

    return ProtocolDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      name: name,
      typeInheritanceClause: typeInheritanceClause,
      members: members)
  }

  private func parsePrecedenceGroupDeclaration()
    throws -> PrecedenceGroupDeclaration
  {
    func parseAttribute() throws -> PrecedenceGroupDeclaration.Attribute {
      func consumeColon() throws {
        guard _lexer.match(.colon) else {
          throw _raiseFatal(.dummy)
        }
      }

      func getIdentifierList() throws -> IdentifierList {
        var ids: [Identifier] = []
        repeat {
          guard case .identifier(let id) = _lexer.read(.dummyIdentifier) else {
            throw _raiseFatal(.dummy)
          }
          ids.append(id)
        } while _lexer.match(.comma)
        return ids
      }

      switch _lexer.read([.dummyIdentifier, .associativity]) {
      case .identifier(let keyword):
        switch keyword {
        case "higherThan":
          try consumeColon()
          let ids = try getIdentifierList()
          return .higherThan(ids)
        case "lowerThan":
          try consumeColon()
          let ids = try getIdentifierList()
          return .lowerThan(ids)
        case "assignment":
          try consumeColon()
          guard case .booleanLiteral(let b) =
            _lexer.read(.dummyBooleanLiteral) else
          {
            throw _raiseFatal(.dummy)
          }
          return .assignment(b)
        default:
          throw _raiseFatal(.dummy)
        }
      case .associativity:
        try consumeColon()
        switch _lexer.read([.left, .right, .none]) {
        case .left:
          return .associativityLeft
        case .right:
          return .associativityRight
        case .none:
          return .associativityNone
        default:
          throw _raiseFatal(.dummy)
        }
      default:
        throw _raiseFatal(.dummy)
      }
    }

    guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.dummy)
    }

    var attrs: [PrecedenceGroupDeclaration.Attribute] = []
    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.dummy)
    }
    while !_lexer.match(.rightBrace) {
      let attr = try parseAttribute()
      attrs.append(attr)
    }

    return PrecedenceGroupDeclaration(name: name, attributes: attrs)
  }

  private func parseOperatorDeclaration(
    withModifiers modifiers: DeclarationModifiers
  ) throws -> OperatorDeclaration {
    func parseOperator(modifier kind: DeclarationModifier) throws -> Operator {
      guard let op = parseVerifiedOperator(againstModifier: kind) else {
        throw _raiseFatal(.dummy)
      }

      return op
    }

    guard modifiers.count == 1, let modifier = modifiers.first else {
      throw _raiseFatal(.dummy)
    }

    let kind: OperatorDeclaration.Kind
    switch modifier {
    case .prefix:
      let op = try parseOperator(modifier: .prefix)
      kind = .prefix(op)
    case .postfix:
      let op = try parseOperator(modifier: .postfix)
      kind = .postfix(op)
    case .infix:
      let op = try parseOperator(modifier: .infix)
      var id: Identifier? = nil
      if _lexer.match(.colon) {
        guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
          throw _raiseFatal(.dummy)
        }
        id = name
      }
      kind = .infix(op, id)
    default:
      throw _raiseFatal(.dummy)
    }
    return OperatorDeclaration(kind: kind)
  }

  private func parseSubscriptDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> SubscriptDeclaration {
    let params = try parseParameterClause()
    guard _lexer.match(.arrow) else {
      throw _raiseFatal(.dummy)
    }
    let resultAttributes = try parseAttributes()
    let type = try parseType()

    if isGetterSetterBlockHead() {
      let (getterSetterBlock, hasCodeBlock) = try parseGetterSetterBlock()
      if hasCodeBlock {
        return SubscriptDeclaration(
          attributes: attrs,
          modifiers: modifiers,
          parameterList: params,
          resultAttributes: resultAttributes,
          resultType: type,
          getterSetterBlock: getterSetterBlock)
      } else {
        let getter = GetterSetterKeywordBlock.GetterKeywordClause(
          attributes: getterSetterBlock.getter.attributes,
          mutationModifier: getterSetterBlock.getter.mutationModifier)
        let setter = getterSetterBlock.setter.map {
            GetterSetterKeywordBlock.SetterKeywordClause(
              attributes: $0.attributes, mutationModifier: $0.mutationModifier)
          }
        let getterSetterKeywordBlock =
          GetterSetterKeywordBlock(getter: getter, setter: setter)
        return SubscriptDeclaration(
          attributes: attrs,
          modifiers: modifiers,
          parameterList: params,
          resultAttributes: resultAttributes,
          resultType: type,
          getterSetterKeywordBlock: getterSetterKeywordBlock)
      }
    } else {
      let codeBlock = try parseCodeBlock()
      return SubscriptDeclaration(
        attributes: attrs,
        modifiers: modifiers,
        parameterList: params,
        resultAttributes: resultAttributes,
        resultType: type,
        codeBlock: codeBlock)
    }
  }

  private func parseExtensionDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> ExtensionDeclaration {
    var accessLevelModifier: AccessLevelModifier? = nil
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }

    guard let name = _lexer.look().kind.structName else {
      throw _raiseFatal(.missingExtensionName)
    }
    _lexer.advance()
    let type = try parseIdentifierType(name)

    let typeInheritanceClause = try parseTypeInheritanceClause()
    let genericWhereClause = try parseGenericWhereClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpectedForDeclarationBody)
    }

    var members: [ExtensionDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      if _lexer.match(.hash) {
        let compCtrlStmt = try parseCompilerControlStatement()
        members.append(.compilerControl(compCtrlStmt))
      } else {
        let decl = try parseDeclaration()
        members.append(.declaration(decl))
      }
    }

    if let whereClause = genericWhereClause {
      return ExtensionDeclaration(
        attributes: attrs,
        accessLevelModifier: accessLevelModifier,
        type: type,
        genericWhereClause: whereClause,
        members: members)
    } else {
      return ExtensionDeclaration(
        attributes: attrs,
        accessLevelModifier: accessLevelModifier,
        type: type,
        typeInheritanceClause: typeInheritanceClause,
        members: members)
    }
  }

  private func parseDeinitializerDeclaration(
    withAttributes attrs: Attributes
  ) throws -> DeinitializerDeclaration {
    let body = try parseCodeBlock()
    return DeinitializerDeclaration(attributes: attrs, body: body)
  }

  private func parseInitializerDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    forProtocolMember: Bool = false
  ) throws -> InitializerDeclaration {
    let initKind: InitializerDeclaration.InitKind
    if _lexer.matchUnicodeScalar("?", immediateFollow: true) {
      initKind = .optionalFailable
    } else if _lexer.matchUnicodeScalar("!", immediateFollow: true) {
      initKind = .implicitlyUnwrappedFailable
    } else {
      initKind = .nonfailable
    }

    let genericParameterClause = try parseGenericParameterClause()

    let params = try parseParameterClause()

    let throwsKind = parseThrowsKind()

    let genericWhereClause = try parseGenericWhereClause()
    let body = forProtocolMember ? CodeBlock() : try parseCodeBlock()

    return InitializerDeclaration(
      attributes: attrs,
      modifiers: modifiers,
      kind: initKind,
      genericParameterClause: genericParameterClause,
      parameterList: params,
      throwsKind: throwsKind,
      genericWhereClause: genericWhereClause,
      body: body)
  }

  private func parseClassDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> ClassDeclaration {
    var accessLevelModifier: AccessLevelModifier? = nil
    var isFinal = false
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    } else if modifiers.count == 1, modifiers[0] == .final {
      isFinal = true
    } else if modifiers.count == 2, modifiers[0] == .final,
      case .accessLevel(let modifier) = modifiers[1]
    {
      accessLevelModifier = modifier
      isFinal = true
    } else if modifiers.count == 2,
      case .accessLevel(let modifier) = modifiers[0],
      modifiers[1] == .final
    {
      accessLevelModifier = modifier
      isFinal = true
    }

    guard let name = _lexer.look().kind.structName else {
      throw _raiseFatal(.missingClassName)
    }
    _lexer.advance()

    let genericParameterClause = try parseGenericParameterClause()
    let typeInheritanceClause = try parseTypeInheritanceClause()
    let genericWhereClause = try parseGenericWhereClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpectedForDeclarationBody)
    }

    var members: [ClassDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      if _lexer.match(.hash) {
        let compCtrlStmt = try parseCompilerControlStatement()
        members.append(.compilerControl(compCtrlStmt))
      } else {
        let decl = try parseDeclaration()
        members.append(.declaration(decl))
      }
    }

    return ClassDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      isFinal: isFinal,
      name: name,
      genericParameterClause: genericParameterClause,
      typeInheritanceClause: typeInheritanceClause,
      genericWhereClause: genericWhereClause,
      members: members)
  }

  private func parseStructDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> StructDeclaration {
    var accessLevelModifier: AccessLevelModifier? = nil
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }

    guard let name = _lexer.look().kind.structName else {
      throw _raiseFatal(.missingStructName)
    }
    _lexer.advance()

    let genericParameterClause = try parseGenericParameterClause()
    let typeInheritanceClause = try parseTypeInheritanceClause()
    let genericWhereClause = try parseGenericWhereClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpectedForDeclarationBody)
    }

    var members: [StructDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      if _lexer.match(.hash) {
        let compCtrlStmt = try parseCompilerControlStatement()
        members.append(.compilerControl(compCtrlStmt))
      } else {
        let decl = try parseDeclaration()
        members.append(.declaration(decl))
      }
    }

    return StructDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      name: name,
      genericParameterClause: genericParameterClause,
      typeInheritanceClause: typeInheritanceClause,
      genericWhereClause: genericWhereClause,
      members: members)
  }

  private func parseEnumDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    isIndirect: Bool) throws -> EnumDeclaration
  {
    func isCaseMemberHead() -> Bool {
      var lookAhead = 0
      while true {
        let aheadToken = _lexer.look(ahead: lookAhead).kind
        switch aheadToken {
        case .indirect:
          return _lexer.look(ahead: lookAhead + 1).kind == .case
        case .case:
          return true
        case .at:
          if _lexer.look(ahead: lookAhead + 1).kind.isEqual(toKindOf: .dummyIdentifier) {
            lookAhead += 2
          } else {
            return false
          }
        default:
          return false
        }
      }
    }

    func polishMembers(
      isIndirect: Bool,
      hasTypeInheritance: Bool,
      members: [EnumDeclaration.Member]
    ) throws -> [EnumDeclaration.Member] {
      var isRawValueEnum = false
      for member in members {
        if case .rawValue = member {
          if isIndirect {
            throw _raiseFatal(.indirectWithRawValueStyle)
          }
          isRawValueEnum = true
          break
        }
      }

      guard isRawValueEnum else {
        return members
      }

      guard hasTypeInheritance else {
        throw _raiseFatal(.dummy)
      }
      var verifiedMembers: [EnumDeclaration.Member] = []
      for member in members {
        switch member {
        case .declaration, .rawValue:
          verifiedMembers.append(member)
        case .union(let union):
          if union.isIndirect {
            throw _raiseFatal(.indirectWithRawValueStyle)
          }
          var newCases: [EnumDeclaration.RawValueStyleEnumCase.Case] = []
          for c in union.cases {
            if c.tuple != nil {
              throw _raiseFatal(.dummy)
            }
            newCases.append(
              EnumDeclaration.RawValueStyleEnumCase.Case(name: c.name))
          }
          let newMember = EnumDeclaration.RawValueStyleEnumCase(
            attributes: union.attributes, cases: newCases)
          verifiedMembers.append(.rawValue(newMember))
        case .compilerControl:
          verifiedMembers.append(member)
        }
      }
      return verifiedMembers
    }

    func parseMember() throws -> EnumDeclaration.Member {
      if _lexer.match(.hash) {
        let compilerCtrlStmt = try parseCompilerControlStatement()
        return .compilerControl(compilerCtrlStmt)
      }

      let isCaseMember = isCaseMemberHead()
      guard isCaseMember else {
        let memberDecl = try parseDeclaration()
        return .declaration(memberDecl)
      }

      let attributes = try parseAttributes()
      let isIndirect = _lexer.match(.indirect)

      guard _lexer.match(.case) else {
        throw _raiseFatal(.dummy)
      }

      typealias CaseComponent = (
        Identifier,
        TupleType?,
        EnumDeclaration.RawValueStyleEnumCase.Case.RawValueLiteral?
      )
      var caseComponents: [CaseComponent] = []
      repeat {
        guard let s = _lexer.readNamedIdentifier() else {
          throw _raiseFatal(.dummy)
        }
        switch _lexer.read([.leftParen, .assignmentOperator]) {
        case .leftParen:
          let tupleType = try parseTupleType()
          caseComponents.append((s, tupleType, nil))
        case .assignmentOperator:
          let literalTokens: [Token.Kind] = [
            .dummyIntegerLiteral,
            .dummyFloatingPointLiteral,
            .dummyStaticStringLiteral,
            .dummyBooleanLiteral,
          ]
          switch _lexer.read(literalTokens) {
          case let .integerLiteral(i, _, _):
            caseComponents.append((s, nil, .integer(i)))
          case let .floatingPointLiteral(f, _):
            caseComponents.append((s, nil, .floatingPoint(f)))
          case let .staticStringLiteral(ss, _):
            caseComponents.append((s, nil, .string(ss)))
          default:
            throw _raiseFatal(.dummy)
          }
        default:
          caseComponents.append((s, nil, nil))
        }
      } while _lexer.match(.comma)

      let unionCases = caseComponents.map {
          EnumDeclaration.UnionStyleEnumCase.Case(name: $0.0, tuple: $0.1)
        }
      let rawValueCases = caseComponents.map {
          EnumDeclaration.RawValueStyleEnumCase.Case(
            name: $0.0, assignment: $0.2)
        }
      guard rawValueCases.flatMap({ $0.assignment }).isEmpty else {
        if isIndirect {
          throw _raiseFatal(.indirectWithRawValueStyle)
        }
        guard unionCases.flatMap({ $0.tuple }).isEmpty else {
          throw _raiseFatal(.dummy)
        }
        let rawValueCaseMember = EnumDeclaration.RawValueStyleEnumCase(
          attributes: attributes, cases: rawValueCases)
        return .rawValue(rawValueCaseMember)
      }
      let unionCaseMember = EnumDeclaration.UnionStyleEnumCase(
        attributes: attributes, isIndirect: isIndirect, cases: unionCases)
      return .union(unionCaseMember)
    }

    var accessLevelModifier: AccessLevelModifier? = nil
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }

    guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.missingEnumName)
    }

    let genericParameterClause = try parseGenericParameterClause()
    let typeInheritanceClause = try parseTypeInheritanceClause()
    let genericWhereClause = try parseGenericWhereClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpectedForEnumCase)
    }

    var rawMembers: [EnumDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let member = try parseMember()
      rawMembers.append(member)
    }
    let members = try polishMembers(isIndirect: isIndirect,
      hasTypeInheritance: (typeInheritanceClause != nil), members: rawMembers)

    return EnumDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      isIndirect: isIndirect,
      name: name,
      genericParameterClause: genericParameterClause,
      typeInheritanceClause: typeInheritanceClause,
      genericWhereClause: genericWhereClause,
      members: members)
  }

  private func parseParameterClause() throws -> [FunctionSignature.Parameter] {
    func parseParameter() throws -> FunctionSignature.Parameter {
      var externalName: Identifier? = nil
      var internalName: Identifier? = nil
      if _lexer.match(.underscore) {
        if let name = _lexer.readNamedIdentifier() {
          externalName = "_"
          internalName = name
        } else {
          externalName = "_"
          internalName = ""
        }
      } else if let firstName = _lexer.readNamedIdentifier() {
        if let secondName = _lexer.readNamedIdentifierOrWildcard() {
          externalName = firstName
          internalName = secondName
        } else {
          internalName = firstName
        }
      }
      guard let localName = internalName else {
        throw _raiseFatal(.dummy)
      }

      guard let typeAnnotation = try parseTypeAnnotation() else {
        throw _raiseFatal(.dummy)
      }

      switch _lexer.look().kind {
      case .assignmentOperator:
        _lexer.advance()
        let defaultExpr = try parseExpression()
        return FunctionSignature.Parameter(
          externalName: externalName,
          localName: localName,
          typeAnnotation: typeAnnotation,
          defaultArgumentClause: defaultExpr)
      case .postfixOperator("..."):
        _lexer.advance()
        return FunctionSignature.Parameter(
          externalName: externalName,
          localName: localName,
          typeAnnotation: typeAnnotation,
          isVarargs: true)
      default:
        return FunctionSignature.Parameter(
          externalName: externalName,
          localName: localName,
          typeAnnotation: typeAnnotation)
      }
    }

    guard _lexer.match(.leftParen) else {
      throw _raiseFatal(.dummy)
    }
    if _lexer.match(.rightParen) {
      return []
    }
    var params: [FunctionSignature.Parameter] = []
    repeat {
      let param = try parseParameter()
      params.append(param)
    } while _lexer.match(.comma)
    guard _lexer.match(.rightParen) else {
      throw _raiseFatal(.dummy)
    }
    return params
  }

  private func parseFunctionDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> FunctionDeclaration {
    func parseName() throws -> Identifier {
      var kind: DeclarationModifier? = nil
      for m in modifiers {
        switch m {
        case .prefix:
          kind == nil ?
            kind = .prefix :
            try _raiseError(.dummy)
        case .postfix:
          kind == nil ?
            kind = .postfix :
            try _raiseError(.dummy)
        case .infix:
          kind == nil ?
            kind = .infix :
            try _raiseError(.dummy)
        default:
          break
        }
      }

      if let op = parseVerifiedOperator(againstModifier: kind) {
        return op
      }

      guard let name = _lexer.readNamedIdentifier() else {
        throw _raiseFatal(.dummy)
      }
      return name
    }

    func parseSignature() throws -> FunctionSignature {
      let params = try parseParameterClause()
      let throwsKind = parseThrowsKind()
      let result = try parseFunctionResult()

      return FunctionSignature(parameterList: params, throwsKind: throwsKind, result: result)
    }

    let name = try parseName()
    let genericParameterClause = try parseGenericParameterClause()
    let signature = try parseSignature()
    let genericWhereClause = try parseGenericWhereClause()
    var body: CodeBlock? = nil
    if _lexer.look().kind == .leftBrace {
      body = try parseCodeBlock()
    }

    return FunctionDeclaration(
      attributes: attrs,
      modifiers: modifiers,
      name: name,
      genericParameterClause: genericParameterClause,
      signature: signature,
      genericWhereClause: genericWhereClause,
      body: body)
  }

  private func parseTypealiasDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> TypealiasDeclaration {
    var accessLevelModifier: AccessLevelModifier? = nil
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }
    guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.missingTypealiasName)
    }
    let genericParameterClause = try parseGenericParameterClause()
    guard _lexer.match(.assignmentOperator) else {
      throw _raiseFatal(.dummy)
    }
    let assignment = try parseType()
    return TypealiasDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      name: name,
      generic: genericParameterClause,
      assignment: assignment)
  }

  private func parseVariableDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> VariableDeclaration {
    let inits = try parsePatternInitializerList()
    if _lexer.look().kind == .leftBrace, inits.count == 1,
      let idPattern = inits[0].pattern as? IdentifierPattern
    {
      switch (idPattern.typeAnnotation, inits[0].initializerExpression) {
      case (let typeAnnotation?, nil):
        if isGetterSetterBlockHead() {
          let (getterSetterBlock, hasCodeBlock) = try parseGetterSetterBlock()
          if hasCodeBlock {
            return VariableDeclaration(
              attributes: attrs,
              modifiers: modifiers,
              variableName: idPattern.identifier,
              typeAnnotation: typeAnnotation,
              getterSetterBlock: getterSetterBlock)
          } else {
            let getter = GetterSetterKeywordBlock.GetterKeywordClause(
              attributes: getterSetterBlock.getter.attributes,
              mutationModifier: getterSetterBlock.getter.mutationModifier)
            let setter = getterSetterBlock.setter.map {
                GetterSetterKeywordBlock.SetterKeywordClause(
                  attributes: $0.attributes,
                  mutationModifier: $0.mutationModifier)
              }
            let getterSetterKeywordBlock =
              GetterSetterKeywordBlock(getter: getter, setter: setter)
              // TODO: duplication alert: I think this pattern also shows up a lot
            return VariableDeclaration(
              attributes: attrs,
              modifiers: modifiers,
              variableName: idPattern.identifier,
              typeAnnotation: typeAnnotation,
              getterSetterKeywordBlock: getterSetterKeywordBlock)
          }
        } else if isWillSetDidSetBlockHead() {
          let willSetDidSetBlock = try parseWillSetDidSetBlock()
          return VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            typeAnnotation: typeAnnotation,
            willSetDidSetBlock: willSetDidSetBlock)
        } else {
          let codeBlock = try parseCodeBlock()
          return VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            typeAnnotation: typeAnnotation,
            codeBlock: codeBlock)
        }
      case (nil, let initExpr?):
        if isWillSetDidSetBlockHead() {
          let willSetDidSetBlock = try parseWillSetDidSetBlock()
          return VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            initializer: initExpr,
            willSetDidSetBlock: willSetDidSetBlock)
        }
      case let (typeAnnotation?, initExpr):
        if isWillSetDidSetBlockHead() {
          let willSetDidSetBlock = try parseWillSetDidSetBlock()
          return VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            typeAnnotation: typeAnnotation,
            initializer: initExpr,
            willSetDidSetBlock: willSetDidSetBlock)
        }
      default:
        break
      }
    }
    return VariableDeclaration(
      attributes: attrs, modifiers: modifiers, initializerList: inits)
  }

  private func parseWillSetDidSetBlock() throws -> WillSetDidSetBlock {
    func parseSet() throws -> (Identifier?, CodeBlock) {
      var setterName: String? = nil
      if _lexer.match(.leftParen) {
        guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
          throw _raiseFatal(.dummy)
        }
        guard _lexer.match(.rightParen) else {
           throw _raiseFatal(.dummy)
        }
        setterName = name
      }
      let codeBlock = try parseCodeBlock()
      return (setterName, codeBlock)
    }

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.dummy)
    }

    let attrs = try parseAttributes()

    var willSetClause: WillSetDidSetBlock.WillSetClause? = nil
    var didSetClause: WillSetDidSetBlock.DidSetClause? = nil

    if _lexer.match(.willSet) {
      let (setterName, codeBlock) = try parseSet()
      willSetClause = WillSetDidSetBlock.WillSetClause(
        attributes: attrs, name: setterName, codeBlock: codeBlock)

      let didSetAttrs = try parseAttributes()
      if _lexer.match(.didSet) {
        let (didSetSetterName, didSetCodeBlock) = try parseSet()
        didSetClause = WillSetDidSetBlock.DidSetClause(
          attributes: didSetAttrs,
          name: didSetSetterName,
          codeBlock: didSetCodeBlock)
      }
    } else if _lexer.match(.didSet) {
      let (setterName, codeBlock) = try parseSet()
      didSetClause = WillSetDidSetBlock.DidSetClause(
        attributes: attrs, name: setterName, codeBlock: codeBlock)

      let willSetAttrs = try parseAttributes()
      if _lexer.match(.willSet) {
        let (willSetSetterName, willSetCodeBlock) = try parseSet()
        willSetClause = WillSetDidSetBlock.WillSetClause(
          attributes: willSetAttrs,
          name: willSetSetterName,
          codeBlock: willSetCodeBlock)
      }
    }

    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.dummy)
    }

    switch (willSetClause, didSetClause) {
    case let (wS?, dS):
      return WillSetDidSetBlock(willSetClause: wS, didSetClause: dS)
    case let (wS, dS?):
      return WillSetDidSetBlock(didSetClause: dS, willSetClause: wS)
    default:
      throw _raiseFatal(.dummy)
    }
  }

  private func parseGetterSetterBlock() throws -> (GetterSetterBlock, Bool) {
    var hasCodeBlock = false

    func parseGetter(
      attrs: Attributes, modifier: MutationModifier?
    ) throws -> GetterSetterBlock.GetterClause {
      hasCodeBlock = hasCodeBlock || _lexer.look().kind == .leftBrace
      let codeBlock = hasCodeBlock ? try parseCodeBlock() : CodeBlock()
      return GetterSetterBlock.GetterClause(
        attributes: attrs, mutationModifier: modifier, codeBlock: codeBlock)
    }

    func parseSetter(
      attrs: Attributes, modifier: MutationModifier?
    ) throws -> GetterSetterBlock.SetterClause {
      var setterName: String? = nil
      if _lexer.match(.leftParen) {
        guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
          throw _raiseFatal(.dummy)
        }
        guard _lexer.match(.rightParen) else {
           throw _raiseFatal(.dummy)
        }
        setterName = name
      }
      hasCodeBlock = hasCodeBlock || _lexer.look().kind == .leftBrace
      let codeBlock = hasCodeBlock ? try parseCodeBlock() : CodeBlock()
      return GetterSetterBlock.SetterClause(
        attributes: attrs,
        mutationModifier: modifier,
        name: setterName,
        codeBlock: codeBlock)
    }

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.dummy)
    }

    let attrs = try parseAttributes()
    let modifier = parseMutationModifier()

    var getterClause: GetterSetterBlock.GetterClause? = nil
    var setterClause: GetterSetterBlock.SetterClause? = nil

    if _lexer.match(.get) {
      getterClause = try parseGetter(attrs: attrs, modifier: modifier)

      let setterAttrs = try parseAttributes()
      let setterModifier = parseMutationModifier()
      if _lexer.match(.set) {
        setterClause = try parseSetter(
          attrs: setterAttrs, modifier: setterModifier)
      }
    } else if _lexer.match(.set) {
      setterClause = try parseSetter(attrs: attrs, modifier: modifier)

      let getterAttrs = try parseAttributes()
      let getterModifier = parseMutationModifier()
      if _lexer.match(.get) {
        getterClause = try parseGetter(
          attrs: getterAttrs, modifier: getterModifier)
      }
    }

    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.dummy)
    }

    guard let getter = getterClause else {
      throw _raiseFatal(.dummy)
    }

    return (GetterSetterBlock(
      getter: getter, setter: setterClause), hasCodeBlock)
  }

  private func parseConstantDeclaration(
    withAttributes attrs: Attributes, modifiers: DeclarationModifiers
  ) throws -> ConstantDeclaration {
    let inits = try parsePatternInitializerList()
    return ConstantDeclaration(
      attributes: attrs, modifiers: modifiers, initializerList: inits)
  }

  private func parsePatternInitializerList() throws -> [PatternInitializer] {
    var inits: [PatternInitializer] = []
    repeat {
      let initializer = try parsePatternInitializer()
      inits.append(initializer)
    } while _lexer.match(.comma)
    return inits
  }

  private func parsePatternInitializer() throws -> PatternInitializer {
    let pttrn = try parsePattern()
    var initExpr: Expression? = nil
    if _lexer.match(.assignmentOperator) {
      initExpr = try parseExpression()
    }
    return PatternInitializer(pattern: pttrn, initializerExpression: initExpr)
  }

  private func parseImportDeclaration(
    withAttributes attrs: Attributes
  ) throws -> ImportDeclaration {
    var kind: ImportDeclaration.Kind? = nil
    let importTypeTokens: [Token.Kind] = [
      .typealias,
      .struct,
      .class,
      .enum,
      .protocol,
      .var,
      .func,
    ]
    switch _lexer.read(importTypeTokens) {
    case .typealias:
      kind = .typealias
    case .struct:
      kind = .struct
    case .class:
      kind = .class
    case .enum:
      kind = .enum
    case .protocol:
      kind = .protocol
    case .var:
      kind = .var
    case .func:
      kind = .func
    default:
      break
    }

    var path: [ImportDeclaration.PathIdentifier] = []
    let pathIdentifierTokens: [Token.Kind] = [
      .dummyIdentifier,
      .dummyPrefixOperator,
      .dummyBinaryOperator,
      .dummyPostfixOperator,
    ]
    repeat {
      switch _lexer.read(pathIdentifierTokens) {
      case .identifier(let name):
        path.append(name)
      case .prefixOperator(let op),
        .binaryOperator(let op),
        .postfixOperator(let op):
        path.append(op)
      default:
        throw _raiseFatal(.dummy)
      }
    } while _lexer.match(.dot)

    return ImportDeclaration(attributes: attrs, kind: kind, path: path)
  }
}
