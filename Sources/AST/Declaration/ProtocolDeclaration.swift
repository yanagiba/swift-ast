/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public class ProtocolDeclaration : ASTNode, Declaration {
  public struct PropertyMember {
    public let attributes: Attributes
    public let modifiers: DeclarationModifiers
    public let name: Identifier
    public let typeAnnotation: TypeAnnotation
    public let getterSetterKeywordBlock: GetterSetterKeywordBlock

    public init(
      attributes: Attributes = [],
      modifiers: DeclarationModifiers = [],
      name: Identifier,
      typeAnnotation: TypeAnnotation,
      getterSetterKeywordBlock: GetterSetterKeywordBlock
    ) {
      self.attributes = attributes
      self.modifiers = modifiers
      self.name = name
      self.typeAnnotation = typeAnnotation
      self.getterSetterKeywordBlock = getterSetterKeywordBlock
    }
  }

  public struct MethodMember {
    public let attributes: Attributes
    public let modifiers: DeclarationModifiers
    public let name: Identifier
    public let genericParameter: GenericParameterClause?
    public let signature: FunctionSignature
    public let genericWhere: GenericWhereClause?

    public init(
      attributes: Attributes = [],
      modifiers: DeclarationModifiers = [],
      name: Identifier,
      genericParameter: GenericParameterClause? = nil,
      signature: FunctionSignature,
      genericWhere: GenericWhereClause? = nil
    ) {
      self.attributes = attributes
      self.modifiers = modifiers
      self.name = name
      self.genericParameter = genericParameter
      self.signature = signature
      self.genericWhere = genericWhere
    }
  }

  public struct InitializerMember {
    public let attributes: Attributes
    public let modifiers: DeclarationModifiers
    public let kind: InitializerDeclaration.InitKind
    public let genericParameter: GenericParameterClause?
    public let parameterList: [FunctionSignature.Parameter]
    public let throwsKind: ThrowsKind
    public let genericWhere: GenericWhereClause?

    public init(
      attributes: Attributes = [],
      modifiers: DeclarationModifiers = [],
      kind: InitializerDeclaration.InitKind = .nonfailable,
      genericParameter: GenericParameterClause? = nil,
      parameterList: [FunctionSignature.Parameter] = [],
      throwsKind: ThrowsKind = .nothrowing,
      genericWhere: GenericWhereClause? = nil
    ) {
      self.attributes = attributes
      self.modifiers = modifiers
      self.kind = kind
      self.genericParameter = genericParameter
      self.parameterList = parameterList
      self.throwsKind = throwsKind
      self.genericWhere = genericWhere
    }
  }

  public struct SubscriptMember {
    public let attributes: Attributes
    public let modifiers: DeclarationModifiers
    public let parameterList: [FunctionSignature.Parameter]
    public let resultAttributes: Attributes
    public let resultType: Type
    public let getterSetterKeywordBlock: GetterSetterKeywordBlock

    public init(
      attributes: Attributes = [],
      modifiers: DeclarationModifiers = [],
      parameterList: [FunctionSignature.Parameter] = [],
      resultAttributes: Attributes = [],
      resultType: Type,
      getterSetterKeywordBlock: GetterSetterKeywordBlock
    ) {
      self.attributes = attributes
      self.modifiers = modifiers
      self.parameterList = parameterList
      self.resultAttributes = resultAttributes
      self.resultType = resultType
      self.getterSetterKeywordBlock = getterSetterKeywordBlock
    }
  }

  public struct AssociativityTypeMember {
    public let attributes: Attributes
    public let accessLevelModifier: AccessLevelModifier?
    public let name: Identifier
    public let typeInheritance: TypeInheritanceClause?
    public let assignmentType: Type?

    public init(
      attributes: Attributes = [],
      accessLevelModifier: AccessLevelModifier? = nil,
      name: Identifier,
      typeInheritance: TypeInheritanceClause? = nil,
      assignmentType: Type? = nil
    ) {
      self.attributes = attributes
      self.accessLevelModifier = accessLevelModifier
      self.name = name
      self.typeInheritance = typeInheritance
      self.assignmentType = assignmentType
    }
  }

  public enum Member {
    case property(PropertyMember)
    case method(MethodMember)
    case initializer(InitializerMember)
    case `subscript`(SubscriptMember)
    case associatedType(AssociativityTypeMember)
    case compilerControl(CompilerControlStatement)
  }

  public let attributes: Attributes
  public let accessLevelModifier: AccessLevelModifier?
  public let name: Identifier
  public let typeInheritanceClause: TypeInheritanceClause?
  public let members: [Member]

  public init(
    attributes: Attributes = [],
    accessLevelModifier: AccessLevelModifier? = nil,
    name: Identifier,
    typeInheritanceClause: TypeInheritanceClause? = nil,
    members: [Member] = []
  ) {
    self.attributes = attributes
    self.accessLevelModifier = accessLevelModifier
    self.name = name
    self.typeInheritanceClause = typeInheritanceClause
    self.members = members
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)protocol \(name)"
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let membersText = members.map({ $0.textDescription }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return "\(headText)\(typeText) {\(memberText)}"
  }
}

extension ProtocolDeclaration.PropertyMember : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let blockText = getterSetterKeywordBlock.textDescription
    return "\(attrsText)\(modifiersText)var \(name)\(typeAnnotation) \(blockText)"
  }
}

extension ProtocolDeclaration.MethodMember : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)func"
    let genericParameterClauseText = genericParameter?.textDescription ?? ""
    let signatureText = signature.textDescription
    let genericWhereClauseText = genericWhere.map({ " \($0.textDescription)" }) ?? ""
    return "\(headText) \(name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)"
  }
}

extension ProtocolDeclaration.InitializerMember : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)init\(kind.textDescription)"
    let genericParameterClauseText = genericParameter?.textDescription ?? ""
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let throwsKindText = throwsKind.textDescription.isEmpty ? "" : " \(throwsKind.textDescription)"
    let genericWhereClauseText = genericWhere.map({ " \($0.textDescription)" }) ?? ""
    return "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText)"
  }
}

extension ProtocolDeclaration.SubscriptMember : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return "\(headText) \(resultText) \(getterSetterKeywordBlock.textDescription)"
  }
}

extension ProtocolDeclaration.AssociativityTypeMember : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let typeText = typeInheritance?.textDescription ?? ""
    let assignmentText = assignmentType.map({ " = \($0.textDescription)" }) ?? ""
    return "\(attrsText)\(modifierText)associatedtype \(name)\(typeText)\(assignmentText)"
  }
}

extension ProtocolDeclaration.Member : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .property(let member):
      return member.textDescription
    case .method(let member):
      return member.textDescription
    case .initializer(let member):
      return member.textDescription
    case .subscript(let member):
      return member.textDescription
    case .associatedType(let member):
      return member.textDescription
    case .compilerControl(let stmt):
      return stmt.textDescription
    }
  }
}
