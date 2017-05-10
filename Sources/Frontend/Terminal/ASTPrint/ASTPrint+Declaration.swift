/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

extension TopLevelDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return statements.ttyPrint + "\n"
  }
}

extension CodeBlock : TTYASTPrintRepresentable {
  var ttyPrint: String {
    if statements.isEmpty {
      return "{}"
    }
    return "{\n\(statements.ttyPrint.indent)\n}"
  }
}

extension GetterSetterBlock.GetterClause {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    return "\(attrsText)\(modifierText)get \(codeBlock.ttyPrint)"
  }
}

extension GetterSetterBlock.SetterClause {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    let nameText = name.map({ "(\($0))" }) ?? ""
    return "\(attrsText)\(modifierText)set\(nameText) \(codeBlock.ttyPrint)"
  }
}

extension GetterSetterBlock {
  var ttyPrint: String {
    let setterStr = setter.map({ "\n\($0.ttyPrint)" }) ?? ""
    return "{\n" + "\(getter.ttyPrint)\(setterStr)".indent + "\n}"
  }
}

extension GetterSetterKeywordBlock {
  var ttyPrint: String {
    let setterStr = setter.map({ "\n\($0.textDescription.indent)" }) ?? ""
    return "{\n\(getter.textDescription.indent)\(setterStr)\n}"
  }
}

extension WillSetDidSetBlock.WillSetClause {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return "\(attrsText)willSet\(nameText) \(codeBlock.ttyPrint)"
  }
}

extension WillSetDidSetBlock.DidSetClause {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return "\(attrsText)didSet\(nameText) \(codeBlock.ttyPrint)"
  }
}

extension WillSetDidSetBlock {
  var ttyPrint: String {
    let willSetClauseStr = willSetClause.map({ "\n\($0.ttyPrint.indent)" }) ?? ""
    let didSetClauseStr = didSetClause.map({ "\n\($0.ttyPrint.indent)" }) ?? ""
    return "{\(willSetClauseStr)\(didSetClauseStr)\n}"
  }
}

extension PatternInitializer {
  var ttyPrint: String {
    let pttrnText = pattern.textDescription
    guard let initExpr = initializerExpression else {
      return pttrnText
    }
    return "\(pttrnText) = \(initExpr.ttyPrint)"
  }
}

extension Collection where Iterator.Element == PatternInitializer {
  var ttyPrint: String {
    return self.map({ $0.ttyPrint }).joined(separator: ", ")
  }
}

extension ClassDeclaration.Member {
  var ttyPrint: String {
    switch self {
    case .declaration(let decl):
      return decl.ttyPrint
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    }
  }
}

extension ClassDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let finalText = isFinal ? "final " : ""
    let headText = "\(attrsText)\(modifierText)\(finalText)class \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.ttyPrint }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText.indent)\n"
    return "\(headText)\(neckText) {" + memberText + "}"
  }
}

extension ConstantDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    return "\(attrsText)\(modifiersText)let \(initializerList.ttyPrint)"
  }
}

extension DeinitializerDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    return "\(attrsText)deinit \(body.ttyPrint)"
  }
}

extension EnumDeclaration.Member {
  var ttyPrint: String {
    switch self {
    case .declaration(let decl):
      return decl.ttyPrint
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    default:
      return textDescription
    }
  }
}

extension EnumDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let indirectText = isIndirect ? "indirect " : ""
    let headText = "\(attrsText)\(modifierText)\(indirectText)enum \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.ttyPrint }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText.indent)\n"
    return "\(headText)\(neckText) {\(memberText)}"
  }
}

extension ExtensionDeclaration.Member {
  var ttyPrint: String {
    switch self {
    case .declaration(let decl):
      return decl.ttyPrint
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    }
  }
}

extension ExtensionDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)extension \(type.textDescription)"
    let typeInheritanceText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(typeInheritanceText)\(whereText)"
    let membersText = members.map({ $0.ttyPrint }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText.indent)\n"
    return "\(headText)\(neckText) {\(memberText)}"
  }
}

extension FunctionDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)func"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let signatureText = signature.textDescription
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.map({ " \($0.ttyPrint)" }) ?? ""
    return "\(headText) \(name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)\(bodyText)"
  }
}

extension InitializerDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)init\(kind.textDescription)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let throwsKindText = throwsKind.textDescription.isEmpty ? "" : " \(throwsKind.textDescription)"
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    return "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText) \(body.ttyPrint)"
  }
}

extension PrecedenceGroupDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.map({ $0.textDescription }).joined(separator: "\n")
    let attrsBlockText = attributes.isEmpty ? "{}" : "{\n\(attrsText.indent)\n}"
    return "precedencegroup \(name) \(attrsBlockText)"
  }
}

extension ProtocolDeclaration.PropertyMember {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let blockText = getterSetterKeywordBlock.ttyPrint
    return "\(attrsText)\(modifiersText)var \(name)\(typeAnnotation) \(blockText)"
  }
}

extension ProtocolDeclaration.SubscriptMember {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return "\(headText) \(resultText) \(getterSetterKeywordBlock.ttyPrint)"
  }
}

extension ProtocolDeclaration.Member {
  var ttyPrint: String {
    switch self {
    case .property(let member):
      return member.ttyPrint
    case .subscript(let member):
      return member.ttyPrint
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    default:
      return textDescription
    }
  }
}

extension ProtocolDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)protocol \(name)"
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let membersText = members.map({ $0.ttyPrint }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText.indent)\n"
    return "\(headText)\(typeText) {\(memberText)}"
  }
}

extension StructDeclaration.Member {
  var ttyPrint: String {
    switch self {
    case .declaration(let decl):
      return decl.ttyPrint
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    }
  }
}

extension StructDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)struct \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.ttyPrint }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText.indent)\n"
    return "\(headText)\(neckText) {\(memberText)}"
  }
}

extension SubscriptDeclaration.Body {
  var ttyPrint: String {
    switch self {
    case .codeBlock(let block):
      return block.ttyPrint
    case .getterSetterBlock(let block):
      return block.ttyPrint
    case .getterSetterKeywordBlock(let block):
      return block.ttyPrint
    }
  }
}

extension SubscriptDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return "\(headText) \(resultText) \(body.ttyPrint)"
  }
}

extension VariableDeclaration.Body : TTYASTPrintRepresentable {
  var ttyPrint: String {
    switch self {
    case .initializerList(let inits):
      return inits.map({ $0.ttyPrint }).joined(separator: ", ")
    case let .codeBlock(name, typeAnnotation, codeBlock):
      return "\(name)\(typeAnnotation) \(codeBlock.ttyPrint)"
    case let .getterSetterBlock(name, typeAnnotation, block):
      return "\(name)\(typeAnnotation) \(block.ttyPrint)"
    case let .getterSetterKeywordBlock(name, typeAnnotation, block):
      return "\(name)\(typeAnnotation) \(block.ttyPrint)"
    case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
      let typeAnnoStr = typeAnnotation?.textDescription ?? ""
      let initStr = initExpr.map({ " = \($0.textDescription)" }) ?? ""
      return "\(name)\(typeAnnoStr)\(initStr) \(block.ttyPrint)"
    }
  }
}

extension VariableDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    return "\(attrsText)\(modifiersText)var \(body.ttyPrint)"
  }
}
