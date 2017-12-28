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

import AST
import Lexer
import Source
import Diagnostic

extension Parser {
  func parseTopLevelDeclaration() throws -> TopLevelDeclaration {
    let shebang = parseShebang()
    let stmts = try parseStatements()
    return TopLevelDeclaration(statements: stmts, comments: _lexer.comments, shebang: shebang)
  }

  func parseCodeBlock() throws -> CodeBlock {
    let startLocation = getStartLocation()
    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpected("code block"))
    }
    let stmts = try parseStatements()
    let endLocation = getEndLocation()
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.rightBraceExpected("code block"))
    }
    let codeBlock = CodeBlock(statements: stmts)
    codeBlock.setSourceRange(startLocation, endLocation)
    return codeBlock
  }

  func parseDeclaration() throws -> Declaration { /*
    swift-lint:suppress(high_cyclomatic_complexity)
    */
    let startLocation = getStartLocation()

    let attrs = try parseAttributes()
    let modifiers = parseModifiers()

    let declHeadTokens: [Token.Kind] = [
      .import, .let, .var, .typealias, .func, .enum, .indirect, .struct,
      .init, .deinit, .extension, .subscript, .operator, .protocol
    ]
    switch _lexer.read(declHeadTokens) {
    case .import:
      return try parseImportDeclaration(
        withAttributes: attrs, startLocation: startLocation)
    case .let:
      return try parseConstantDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .var:
      return try parseVariableDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .typealias:
      return try parseTypealiasDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .func:
      return try parseFunctionDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .enum:
      return try parseEnumDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        isIndirect: false,
        startLocation: startLocation)
    case .indirect:
      guard _lexer.match(.enum) else {
        throw _raiseFatal(.enumExpectedAfterIndirect)
      }
      return try parseEnumDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        isIndirect: true,
        startLocation: startLocation)
    case .struct:
      return try parseStructDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .init:
      return try parseInitializerDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .deinit where modifiers.isEmpty:
      return try parseDeinitializerDeclaration(
        withAttributes: attrs, startLocation: startLocation)
    case .extension:
      return try parseExtensionDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .subscript:
      return try parseSubscriptDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    case .operator where attrs.isEmpty:
      return try parseOperatorDeclaration(
        withModifiers: modifiers, startLocation: startLocation)
    case .protocol:
      return try parseProtocolDeclaration(
        withAttributes: attrs,
        modifiers: modifiers,
        startLocation: startLocation)
    default:
      // try parsing class declaration
      if let lastModifier = modifiers.last, lastModifier == .class {
        let otherModifiers = Array(modifiers.dropLast())
        return try parseClassDeclaration(
          withAttributes: attrs,
          modifiers: otherModifiers,
          startLocation: startLocation)
      }

      // try parsing precedence group declaration
      if attrs.isEmpty,
        modifiers.isEmpty,
        case .identifier(let keyword) = _lexer.look().kind,
        keyword == "precedencegroup"
      {
        _lexer.advance()
        return try parsePrecedenceGroupDeclaration(startLocation: startLocation)
      }

      // tried very hard and failed, throw exception
      throw _raiseFatal(.badDeclaration)
    }
  }

  private func parseProtocolDeclaration( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> ProtocolDeclaration {
    func parsePropertyMember(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.missingPropertyMemberName)
      }
      guard let typeAnnotation = try parseTypeAnnotation() else {
        throw _raiseFatal(.missingTypeForPropertyMember)
      }
      guard isGetterSetterBlockHead() else {
        throw _raiseFatal(.missingGetterSetterForPropertyMember)
      }
      let (getterSetterBlock, hasCodeBlock, _) = try parseGetterSetterBlock()
      guard !hasCodeBlock else {
        throw _raiseFatal(.protocolPropertyMemberWithBody)
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
        withAttributes: attrs, modifiers: modifiers, startLocation: .DUMMY)
      guard funcDecl.body == nil else {
        throw _raiseFatal(.protocolMethodMemberWithBody)
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
        withAttributes: attrs,
        modifiers: modifiers,
        forProtocolMember: true,
        startLocation: .DUMMY)

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
      withAttributes: attrs, modifiers: modifiers, startLocation: .DUMMY)
      guard case .getterSetterKeywordBlock(let getterSetterKeywordBlock) =
        subscriptDecl.body else
      {
        throw _raiseFatal(.missingProtocolSubscriptGetSetSpecifier)
      }

      let member = ProtocolDeclaration.SubscriptMember(
        attributes: attrs,
        modifiers: modifiers,
        genericParameter: subscriptDecl.genericParameterClause,
        parameterList: subscriptDecl.parameterList,
        resultAttributes: subscriptDecl.resultAttributes,
        resultType: subscriptDecl.resultType,
        genericWhere: subscriptDecl.genericWhereClause,
        getterSetterKeywordBlock: getterSetterKeywordBlock)

      return .subscript(member)
    }

    func parseAssociatedType(
      withAttributes attrs: Attributes, modifiers: DeclarationModifiers
    ) throws -> ProtocolDeclaration.Member {
      var accessLevelModifier: AccessLevelModifier?
      if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
        accessLevelModifier = modifier
      }

      guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
        throw _raiseFatal(.missingProtocolAssociatedTypeName)
      }

      let typeInheritanceClause = try parseTypeInheritanceClause()

      var assignmentType: Type?
      if _lexer.match(.assignmentOperator) {
        assignmentType = try parseType()
      }

      let genericWhere = try parseGenericWhereClause()

      let member = ProtocolDeclaration.AssociativityTypeMember(
        attributes: attrs,
        accessLevelModifier: accessLevelModifier,
        name: name,
        typeInheritance: typeInheritanceClause,
        assignmentType: assignmentType,
        genericWhere: genericWhere)

      return .associatedType(member)
    }

    func parseMember() throws -> ProtocolDeclaration.Member {
      let attrs = try parseAttributes()
      let modifiers = parseModifiers()
      let startLocation = getStartLocation()
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
        let compCtrlStmt =
          try parseCompilerControlStatement(startLocation: startLocation)
        return .compilerControl(compCtrlStmt)
      default:
        if _lexer.look().kind == .identifier("associatedtype") {
          _lexer.advance()
          return try parseAssociatedType(
            withAttributes: attrs, modifiers: modifiers)
        }
        throw _raiseFatal(.badProtocolMember)
      }
    }

    var accessLevelModifier: AccessLevelModifier?
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }

    guard let name = _lexer.look().kind.structName else {
      throw _raiseFatal(.missingProtocolName)
    }
    _lexer.advance()

    let typeInheritanceClause = try parseTypeInheritanceClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpected("protocol declaration body"))
    }

    var endLocation = getEndLocation()
    var members: [ProtocolDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let member = try parseMember()
      members.append(member)
      endLocation = getEndLocation()
    }

    let protocolDecl = ProtocolDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      name: name,
      typeInheritanceClause: typeInheritanceClause,
      members: members)
    protocolDecl.setSourceRange(startLocation, endLocation)
    return protocolDecl
  }

  private func parsePrecedenceGroupDeclaration( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    startLocation: SourceLocation
  ) throws -> PrecedenceGroupDeclaration {
    func parseAttribute() throws -> PrecedenceGroupDeclaration.Attribute {
      func consumeColon() throws {
        guard _lexer.match(.colon) else {
          throw _raiseFatal(.missingColonAfterAttributeNameInPrecedenceGroup)
        }
      }

      func getIdentifierList(
        forAttribute attributeName: String
      ) throws -> IdentifierList {
        var ids: [Identifier] = []
        repeat {
          guard case .identifier(let id) = _lexer.read(.dummyIdentifier) else {
            throw _raiseFatal(.missingPrecedenceGroupRelation(attributeName))
          }
          ids.append(id)
        } while _lexer.match(.comma)
        return ids
      }

      switch _lexer.read([.dummyIdentifier, .associativity]) {
      case .identifier(let attributeName):
        switch attributeName {
        case "higherThan":
          try consumeColon()
          let ids = try getIdentifierList(forAttribute: attributeName)
          return .higherThan(ids)
        case "lowerThan":
          try consumeColon()
          let ids = try getIdentifierList(forAttribute: attributeName)
          return .lowerThan(ids)
        case "assignment":
          try consumeColon()
          guard case .booleanLiteral(let b) =
            _lexer.read(.dummyBooleanLiteral) else
          {
            throw _raiseFatal(.expectedBooleanAfterPrecedenceGroupAssignment)
          }
          return .assignment(b)
        default:
          throw _raiseFatal(.unknownPrecedenceGroupAttribute(attributeName))
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
          throw _raiseFatal(.expectedPrecedenceGroupAssociativity)
        }
      default:
        throw _raiseFatal(.expectedPrecedenceGroupAttribute)
      }
    }

    guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.missingPrecedenceName)
    }

    var attrs: [PrecedenceGroupDeclaration.Attribute] = []
    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpected("precedence group declaration"))
    }

    var endLocation = getEndLocation()
    while !_lexer.match(.rightBrace) {
      let attr = try parseAttribute()
      attrs.append(attr)
      endLocation = getEndLocation()
    }

    let precedenceGroupDecl =
      PrecedenceGroupDeclaration(name: name, attributes: attrs)
    precedenceGroupDecl.setSourceRange(startLocation, endLocation)
    return precedenceGroupDecl
  }

  private func parseOperatorDeclaration(
    withModifiers modifiers: DeclarationModifiers, startLocation: SourceLocation
  ) throws -> OperatorDeclaration {
    func parseOperator(modifier kind: DeclarationModifier) throws -> Operator {
      guard let op = parseVerifiedOperator(againstModifier: kind) else {
        throw _raiseFatal(.expectedValidOperator)
      }

      return op
    }

    guard modifiers.count == 1, let modifier = modifiers.first else {
      throw _raiseFatal(.operatorDeclarationHasNoFixity)
    }

    var endLocation = getEndLocation()
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
      var id: Identifier?
      if _lexer.match(.colon) {
        endLocation = getEndLocation()
        guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
          throw _raiseFatal(.expectedOperatorNameAfterInfixOperator)
        }
        id = name
      }
      kind = .infix(op, id)
    default:
      throw _raiseFatal(.operatorDeclarationHasNoFixity)
    }

    if _lexer.look().kind == .leftBrace {
      _ = try parseCodeBlock()
      try _raiseWarning(.operatorHasBody)
    }

    let opDecl = OperatorDeclaration(kind: kind)
    opDecl.setSourceRange(startLocation, endLocation)
    return opDecl
  }

  private func parseSubscriptDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> SubscriptDeclaration {
    let genericParameterClause = try parseGenericParameterClause()
    let (params, _) = try parseParameterClause()
    guard _lexer.match(.arrow) else {
      throw _raiseFatal(.expectedArrowSubscript)
    }
    let resultAttributes = try parseAttributes()
    let type = try parseType()
    let genericWhereClause = try parseGenericWhereClause()

    let subscriptDecl: SubscriptDeclaration
    if isGetterSetterBlockHead() {
      let (getterSetterBlock, hasCodeBlock, endLocation) = try parseGetterSetterBlock()
      if hasCodeBlock {
        subscriptDecl = SubscriptDeclaration(
          attributes: attrs,
          modifiers: modifiers,
          genericParameterClause: genericParameterClause,
          parameterList: params,
          resultAttributes: resultAttributes,
          resultType: type,
          genericWhereClause: genericWhereClause,
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
        subscriptDecl = SubscriptDeclaration(
          attributes: attrs,
          modifiers: modifiers,
          genericParameterClause: genericParameterClause,
          parameterList: params,
          resultAttributes: resultAttributes,
          resultType: type,
          genericWhereClause: genericWhereClause,
          getterSetterKeywordBlock: getterSetterKeywordBlock)
      }
      subscriptDecl.setSourceRange(startLocation, endLocation)
    } else {
      let codeBlock = try parseCodeBlock()
      subscriptDecl = SubscriptDeclaration(
        attributes: attrs,
        modifiers: modifiers,
        genericParameterClause: genericParameterClause,
        parameterList: params,
        resultAttributes: resultAttributes,
        resultType: type,
        genericWhereClause: genericWhereClause,
        codeBlock: codeBlock)
      subscriptDecl.setSourceRange(startLocation, codeBlock.sourceRange.end)
    }
    return subscriptDecl
  }

  private func parseExtensionDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> ExtensionDeclaration {
    var accessLevelModifier: AccessLevelModifier?
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }

    let idTypeStartRange = getLookedRange()
    guard let name = _lexer.look().kind.structName else {
      throw _raiseFatal(.missingExtensionName)
    }
    _lexer.advance()
    let type = try parseIdentifierType(name, idTypeStartRange)

    let typeInheritanceClause = try parseTypeInheritanceClause()
    let genericWhereClause = try parseGenericWhereClause()

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpected("extension declaration body"))
    }

    var endLocation = getEndLocation()
    var members: [ExtensionDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let hashStartLocation = getStartLocation()
      if _lexer.match(.hash) {
        let compCtrlStmt =
          try parseCompilerControlStatement(startLocation: hashStartLocation)
        members.append(.compilerControl(compCtrlStmt))
      } else {
        let decl = try parseDeclaration()
        members.append(.declaration(decl))
      }
      endLocation = getEndLocation()

      removeTrailingSemicolons()
    }

    let extDecl: ExtensionDeclaration
    if let whereClause = genericWhereClause {
      extDecl = ExtensionDeclaration(
        attributes: attrs,
        accessLevelModifier: accessLevelModifier,
        type: type,
        genericWhereClause: whereClause,
        members: members)
    } else {
      extDecl = ExtensionDeclaration(
        attributes: attrs,
        accessLevelModifier: accessLevelModifier,
        type: type,
        typeInheritanceClause: typeInheritanceClause,
        members: members)
    }
    extDecl.setSourceRange(startLocation, endLocation)
    return extDecl
  }

  private func parseDeinitializerDeclaration(
    withAttributes attrs: Attributes, startLocation: SourceLocation
  ) throws -> DeinitializerDeclaration {
    let body = try parseCodeBlock()
    let deinitDecl = DeinitializerDeclaration(attributes: attrs, body: body)
    deinitDecl.setSourceRange(startLocation, body.sourceRange.end)
    return deinitDecl
  }

  private func parseInitializerDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    forProtocolMember: Bool = false,
    startLocation: SourceLocation
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

    let (params, _) = try parseParameterClause()

    let (throwsKind, _) = parseThrowsKind()

    let genericWhereClause = try parseGenericWhereClause()
    let body = forProtocolMember ? CodeBlock() : try parseCodeBlock()

    let initDecl = InitializerDeclaration(
      attributes: attrs,
      modifiers: modifiers,
      kind: initKind,
      genericParameterClause: genericParameterClause,
      parameterList: params,
      throwsKind: throwsKind,
      genericWhereClause: genericWhereClause,
      body: body)
    initDecl.setSourceRange(startLocation, body.sourceRange.end)
    return initDecl
  }

  private func parseClassDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> ClassDeclaration {
    var accessLevelModifier: AccessLevelModifier?
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
      throw _raiseFatal(.leftBraceExpected("class declaration body"))
    }

    var endLocation = getEndLocation()
    var members: [ClassDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let hashStartLocation = getStartLocation()
      if _lexer.match(.hash) {
        let compCtrlStmt =
          try parseCompilerControlStatement(startLocation: hashStartLocation)
        members.append(.compilerControl(compCtrlStmt))
      } else {
        let decl = try parseDeclaration()
        members.append(.declaration(decl))
      }
      endLocation = getEndLocation()

      removeTrailingSemicolons()
    }

    let classDecl = ClassDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      isFinal: isFinal,
      name: name,
      genericParameterClause: genericParameterClause,
      typeInheritanceClause: typeInheritanceClause,
      genericWhereClause: genericWhereClause,
      members: members)
    classDecl.setSourceRange(startLocation, endLocation)
    return classDecl
  }

  private func parseStructDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> StructDeclaration {
    var accessLevelModifier: AccessLevelModifier?
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
      throw _raiseFatal(.leftBraceExpected("struct declaration body"))
    }

    var endLocation = getEndLocation()
    var members: [StructDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let hashStartLocation = getStartLocation()
      if _lexer.match(.hash) {
        let compCtrlStmt =
          try parseCompilerControlStatement(startLocation: hashStartLocation)
        members.append(.compilerControl(compCtrlStmt))
      } else {
        let decl = try parseDeclaration()
        members.append(.declaration(decl))
      }
      endLocation = getEndLocation()

      removeTrailingSemicolons()
    }

    let structDecl = StructDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      name: name,
      genericParameterClause: genericParameterClause,
      typeInheritanceClause: typeInheritanceClause,
      genericWhereClause: genericWhereClause,
      members: members)
    structDecl.setSourceRange(startLocation, endLocation)
    return structDecl
  }

  private func parseEnumDeclaration( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    isIndirect: Bool,
    startLocation: SourceLocation
  ) throws -> EnumDeclaration {
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
        throw _raiseFatal(.missingTypeForRawValueEnumDeclaration)
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
              throw _raiseFatal(.unionStyleMixWithRawValueStyle)
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

    func parseMember() throws -> EnumDeclaration.Member { // swift-lint:suppress(high_npath_complexity,high_ncss)
      let hashStartLocation = getStartLocation()
      if _lexer.match(.hash) {
        let compilerCtrlStmt =
          try parseCompilerControlStatement(startLocation: hashStartLocation)
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
        throw _raiseFatal(.expectedEnumDeclarationCaseMember)
        // Note: ^ don't think we will reach this, because we have guard on `isCaseMember`
      }

      typealias CaseComponent = (
        Identifier,
        TupleType?,
        EnumDeclaration.RawValueStyleEnumCase.Case.RawValueLiteral?
      )
      var caseComponents: [CaseComponent] = []
      repeat {
        guard let s = _lexer.readNamedIdentifier() else {
          throw _raiseFatal(.expectedCaseName)
        }
        let startLocation = getStartLocation()
        switch _lexer.read([.leftParen, .assignmentOperator]) {
        case .leftParen:
          let tupleType = try parseTupleType(startLocation)
          caseComponents.append((s, tupleType, nil))
        case .assignmentOperator:
          let literalTokens: [Token.Kind] = [
            .dummyIntegerLiteral,
            .dummyFloatingPointLiteral,
            .dummyStaticStringLiteral,
            .dummyBooleanLiteral,
          ]
          switch _lexer.read(literalTokens) {
          case let .integerLiteral(i, _):
            caseComponents.append((s, nil, .integer(i)))
          case let .floatingPointLiteral(f, _):
            caseComponents.append((s, nil, .floatingPoint(f)))
          case let .staticStringLiteral(ss, _):
            caseComponents.append((s, nil, .string(ss)))
          case let .booleanLiteral(b):
            caseComponents.append((s, nil, .boolean(b)))
          default:
            throw _raiseFatal(.nonliteralEnumCaseRawValue)
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
          throw _raiseFatal(.unionStyleMixWithRawValueStyle)
        }
        let rawValueCaseMember = EnumDeclaration.RawValueStyleEnumCase(
          attributes: attributes, cases: rawValueCases)
        return .rawValue(rawValueCaseMember)
      }
      let unionCaseMember = EnumDeclaration.UnionStyleEnumCase(
        attributes: attributes, isIndirect: isIndirect, cases: unionCases)
      return .union(unionCaseMember)
    }

    var accessLevelModifier: AccessLevelModifier?
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
      throw _raiseFatal(.leftBraceExpected("enum declaration body"))
    }

    var endLocation = getEndLocation()
    var rawMembers: [EnumDeclaration.Member] = []
    while !_lexer.match(.rightBrace) {
      let member = try parseMember()
      rawMembers.append(member)
      endLocation = getEndLocation()

      removeTrailingSemicolons()
    }
    let members = try polishMembers(isIndirect: isIndirect,
      hasTypeInheritance: (typeInheritanceClause != nil), members: rawMembers)

    let enumDecl = EnumDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      isIndirect: isIndirect,
      name: name,
      genericParameterClause: genericParameterClause,
      typeInheritanceClause: typeInheritanceClause,
      genericWhereClause: genericWhereClause,
      members: members)
    enumDecl.setSourceRange(startLocation, endLocation)
    return enumDecl
  }

  private func parseParameterClause() throws -> ([FunctionSignature.Parameter], SourceRange) { /*
    swift-lint:suppress(high_ncss)
    */
    func parseParameter() throws -> FunctionSignature.Parameter {
      var externalName: Identifier?
      var internalName: Identifier?
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
        throw _raiseFatal(.unnamedParameter)
      }

      guard let typeAnnotation = try parseTypeAnnotation() else {
        throw _raiseFatal(.expectedParameterType)
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

    let startLocation = getStartLocation()
    guard _lexer.match(.leftParen) else {
      throw _raiseFatal(.expectedParameterOpenParenthesis)
    }

    var endLocation = getEndLocation()
    if _lexer.match(.rightParen) {
      return ([], SourceRange(start: startLocation, end: endLocation))
    }

    var params: [FunctionSignature.Parameter] = []
    repeat {
      let param = try parseParameter()
      params.append(param)
    } while _lexer.match(.comma)

    endLocation = getEndLocation()
    guard _lexer.match(.rightParen) else {
      throw _raiseFatal(.expectedParameterCloseParenthesis)
    }
    return (params, SourceRange(start: startLocation, end: endLocation))
  }

  private func parseFunctionDeclaration( // swift-lint:suppress(high_cyclomatic_complexity,high_ncss)
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> FunctionDeclaration {
    func parseName() throws -> Identifier {
      var kind: DeclarationModifier?
      for m in modifiers {
        switch m {
        case .prefix:
          kind == nil ? kind = .prefix : try _raiseError(.duplicatedFunctionModifiers)
        case .postfix:
          kind == nil ? kind = .postfix : try _raiseError(.duplicatedFunctionModifiers)
        case .infix:
          kind == nil ? kind = .infix : try _raiseError(.duplicatedFunctionModifiers)
        default:
          break
        }
      }

      if let op = parseVerifiedOperator(againstModifier: kind) {
        return op
      }

      guard let name = _lexer.readNamedIdentifier() else {
        throw _raiseFatal(.missingFunctionName)
      }
      return name
    }

    func parseSignature() throws -> (FunctionSignature, SourceLocation) {
      let (params, paramsSrcRange) = try parseParameterClause()
      let (throwsKind, throwsEndLocation) = parseThrowsKind()
      let result = try parseFunctionResult()

      let funcSign = FunctionSignature(
        parameterList: params, throwsKind: throwsKind, result: result)
      if let resultEndLocation = result?.type.sourceRange.end {
        return (funcSign, resultEndLocation)
      } else if let throwsEndLocation = throwsEndLocation {
        return (funcSign, throwsEndLocation)
      } else {
        return (funcSign, paramsSrcRange.end)
      }
    }

    let name = try parseName()
    let genericParameterClause = try parseGenericParameterClause()
    let (signature, signEndLocation) = try parseSignature()
    let genericWhereClause = try parseGenericWhereClause()
    var body: CodeBlock?
    if _lexer.look().kind == .leftBrace {
      body = try parseCodeBlock()
    }

    var endLocation = signEndLocation
    if let lastGenericReq = genericWhereClause?.requirementList.last {
      switch lastGenericReq {
      case .typeConformance(_, let type):
        endLocation = type.sourceRange.end
      case .protocolConformance(_, let type):
        endLocation = type.sourceRange.end
      case .sameType(_, let type):
        endLocation = type.sourceRange.end
      }
    }
    if let bodyEndLocation = body?.sourceRange.end {
      endLocation = bodyEndLocation
    }

    let funcDecl = FunctionDeclaration(
      attributes: attrs,
      modifiers: modifiers,
      name: name,
      genericParameterClause: genericParameterClause,
      signature: signature,
      genericWhereClause: genericWhereClause,
      body: body)
    funcDecl.setSourceRange(startLocation, endLocation)
    return funcDecl
  }

  private func parseTypealiasDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> TypealiasDeclaration {
    var accessLevelModifier: AccessLevelModifier?
    if modifiers.count == 1, case .accessLevel(let modifier) = modifiers[0] {
      accessLevelModifier = modifier
    }
    guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
      throw _raiseFatal(.missingTypealiasName)
    }
    let genericParameterClause = try parseGenericParameterClause()
    guard _lexer.match(.assignmentOperator) else {
      throw _raiseFatal(.expectedEqualInTypealias)
    }
    let assignment = try parseType()
    let typealiasDecl = TypealiasDeclaration(
      attributes: attrs,
      accessLevelModifier: accessLevelModifier,
      name: name,
      generic: genericParameterClause,
      assignment: assignment)
    typealiasDecl.setSourceRange(startLocation, assignment.sourceRange.end)
    return typealiasDecl
  }

  private func parseVariableDeclaration( // swift-lint:suppress(high_ncss)
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> VariableDeclaration {
    let inits = try parsePatternInitializerList()
    if _lexer.look().kind == .leftBrace, inits.count == 1,
      let idPattern = inits[0].pattern as? IdentifierPattern
    {
      switch (idPattern.typeAnnotation, inits[0].initializerExpression) {
      case (let typeAnnotation?, nil):
        if isGetterSetterBlockHead() {
          let (getterSetterBlock, hasCodeBlock, endLocation) = try parseGetterSetterBlock()
          if hasCodeBlock {
            let varDecl = VariableDeclaration(
              attributes: attrs,
              modifiers: modifiers,
              variableName: idPattern.identifier,
              typeAnnotation: typeAnnotation,
              getterSetterBlock: getterSetterBlock)
            varDecl.setSourceRange(startLocation, endLocation)
            return varDecl
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
            let varDecl = VariableDeclaration(
              attributes: attrs,
              modifiers: modifiers,
              variableName: idPattern.identifier,
              typeAnnotation: typeAnnotation,
              getterSetterKeywordBlock: getterSetterKeywordBlock)
            varDecl.setSourceRange(startLocation, endLocation)
            return varDecl
          }
        } else if isWillSetDidSetBlockHead() {
          let (willSetDidSetBlock, endLocation) = try parseWillSetDidSetBlock()
          let varDecl = VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            typeAnnotation: typeAnnotation,
            willSetDidSetBlock: willSetDidSetBlock)
          varDecl.setSourceRange(startLocation, endLocation)
          return varDecl
        } else {
          let codeBlock = try parseCodeBlock()
          let varDecl = VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            typeAnnotation: typeAnnotation,
            codeBlock: codeBlock)
          varDecl.setSourceRange(startLocation, codeBlock.sourceRange.end)
          return varDecl
        }
      case (nil, let initExpr?):
        if isWillSetDidSetBlockHead() {
          let (willSetDidSetBlock, endLocation) = try parseWillSetDidSetBlock()
          let varDecl = VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            initializer: initExpr,
            willSetDidSetBlock: willSetDidSetBlock)
          varDecl.setSourceRange(startLocation, endLocation)
          return varDecl
        }
      case let (typeAnnotation?, initExpr):
        if isWillSetDidSetBlockHead() {
          let (willSetDidSetBlock, endLocation) = try parseWillSetDidSetBlock()
          let varDecl = VariableDeclaration(
            attributes: attrs,
            modifiers: modifiers,
            variableName: idPattern.identifier,
            typeAnnotation: typeAnnotation,
            initializer: initExpr,
            willSetDidSetBlock: willSetDidSetBlock)
          varDecl.setSourceRange(startLocation, endLocation)
          return varDecl
        }
      default:
        break
      }
    }

    let varDecl = VariableDeclaration(
      attributes: attrs, modifiers: modifiers, initializerList: inits)
    if let lastInit = inits.last {
      varDecl.setSourceRange(startLocation, lastInit.sourceRange.end)
    }
    return varDecl
  }

  private func parseWillSetDidSetBlock() throws ->
    (WillSetDidSetBlock, SourceLocation)
  {
    func parseSet(_ accessorType: String) throws -> (Identifier?, CodeBlock) {
      var setterName: String?
      if _lexer.match(.leftParen) {
        guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
          throw _raiseFatal(.expectedAccesorName(accessorType))
        }
        guard _lexer.match(.rightParen) else {
           throw _raiseFatal(.expectedAccesorNameCloseParenthesis(accessorType))
        }
        setterName = name
      }
      let codeBlock = try parseCodeBlock()
      return (setterName, codeBlock)
    }

    guard _lexer.match(.leftBrace) else {
      throw _raiseFatal(.leftBraceExpected("willSet/didSet block"))
    }

    let attrs = try parseAttributes()

    var willSetClause: WillSetDidSetBlock.WillSetClause?
    var didSetClause: WillSetDidSetBlock.DidSetClause?

    if _lexer.match(.willSet) {
      let (setterName, codeBlock) = try parseSet("willSet")
      willSetClause = WillSetDidSetBlock.WillSetClause(
        attributes: attrs, name: setterName, codeBlock: codeBlock)

      let didSetAttrs = try parseAttributes()
      if _lexer.match(.didSet) {
        let (didSetSetterName, didSetCodeBlock) = try parseSet("didSet")
        didSetClause = WillSetDidSetBlock.DidSetClause(
          attributes: didSetAttrs,
          name: didSetSetterName,
          codeBlock: didSetCodeBlock)
      }
    } else if _lexer.match(.didSet) {
      let (setterName, codeBlock) = try parseSet("didSet")
      didSetClause = WillSetDidSetBlock.DidSetClause(
        attributes: attrs, name: setterName, codeBlock: codeBlock)

      let willSetAttrs = try parseAttributes()
      if _lexer.match(.willSet) {
        let (willSetSetterName, willSetCodeBlock) = try parseSet("willSet")
        willSetClause = WillSetDidSetBlock.WillSetClause(
          attributes: willSetAttrs,
          name: willSetSetterName,
          codeBlock: willSetCodeBlock)
      }
    }

    let endLocation = getEndLocation()
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.rightBraceExpected("willSet/didSet block"))
    }

    switch (willSetClause, didSetClause) {
    case let (wS?, dS):
      return (
        WillSetDidSetBlock(willSetClause: wS, didSetClause: dS),
        endLocation
      )
    case let (wS, dS?):
      return (
        WillSetDidSetBlock(didSetClause: dS, willSetClause: wS),
        endLocation
      )
    default:
      throw _raiseFatal(.expectedWillSetOrDidSet)
    }
  }

  private func parseGetterSetterBlock() throws ->
    (GetterSetterBlock, Bool, SourceLocation)
  {
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
      var setterName: String?
      if _lexer.match(.leftParen) {
        guard case .identifier(let name) = _lexer.read(.dummyIdentifier) else {
          throw _raiseFatal(.expectedAccesorName("setter"))
        }
        guard _lexer.match(.rightParen) else {
           throw _raiseFatal(.expectedAccesorNameCloseParenthesis("setter"))
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
      throw _raiseFatal(.leftBraceExpected("getter/setter block"))
    }

    let attrs = try parseAttributes()
    let modifier = parseMutationModifier()

    var getterClause: GetterSetterBlock.GetterClause?
    var setterClause: GetterSetterBlock.SetterClause?

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

    let endLocation = getEndLocation()
    guard _lexer.match(.rightBrace) else {
      throw _raiseFatal(.rightBraceExpected("getter/setter block"))
    }

    guard let getter = getterClause else {
      throw _raiseFatal(.varSetWithoutGet)
    }

    return (
      GetterSetterBlock(getter: getter, setter: setterClause),
      hasCodeBlock,
      endLocation
    )
  }

  private func parseConstantDeclaration(
    withAttributes attrs: Attributes,
    modifiers: DeclarationModifiers,
    startLocation: SourceLocation
  ) throws -> ConstantDeclaration {
    let inits = try parsePatternInitializerList()
    let letDecl = ConstantDeclaration(
      attributes: attrs, modifiers: modifiers, initializerList: inits)
    if let lastInit = inits.last {
      letDecl.setSourceRange(startLocation, lastInit.sourceRange.end)
    }
    return letDecl
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
    var initExpr: Expression?
    if _lexer.match(.assignmentOperator) {
      initExpr = try parseExpression()
    }
    return PatternInitializer(pattern: pttrn, initializerExpression: initExpr)
  }

  private func parseImportDeclaration(
    withAttributes attrs: Attributes, startLocation: SourceLocation
  ) throws -> ImportDeclaration {
    var kind: ImportDeclaration.Kind?
    let importTypeTokens: [Token.Kind] = [
      .typealias,
      .struct,
      .class,
      .enum,
      .protocol,
      .let,
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
    case .let:
      kind = .let
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

    var endLocation: SourceLocation
    repeat {
      endLocation = getEndLocation()
      switch _lexer.read(pathIdentifierTokens) {
      case .identifier(let name):
        path.append(name)
      case .prefixOperator(let op),
        .binaryOperator(let op),
        .postfixOperator(let op):
        path.append(op)
      default:
        throw _raiseFatal(.missingModuleNameImportDecl)
      }
    } while _lexer.match(.dot)

    let importDecl = ImportDeclaration(
      attributes: attrs, kind: kind, path: path)
    importDecl.setSourceRange(startLocation, endLocation)
    return importDecl
  }
}
