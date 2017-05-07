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
  func ttyASTPrint(indentation: Int) -> String {
    return statements.ttyASTPrint(indentation: indentation)
  }

  var ttyPrint: String {
    return statements
      .map { $0.ttyPrint }
      .joined(separator: "\n")
      + "\n"
  }
}

extension CodeBlock : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    if statements.isEmpty {
      return "{}"
    }
    return "{\n\(statements.ttyASTPrint(indentation: indentation + 1))\n\(String(indentation: indentation))}"
  }
}

extension GetterSetterBlock.GetterClause : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)\(modifierText)get \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension GetterSetterBlock.SetterClause : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    let nameText = name.map({ "(\($0))" }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)\(modifierText)set\(nameText) \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension GetterSetterBlock : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    // no matter the original sequence, we always output getter first, and then the setter if exists
    let setterStr = setter.map({ "\n\($0.ttyASTPrint(indentation: indentation + 1))" }) ?? ""
    return "{\n\(getter.ttyASTPrint(indentation: indentation + 1))\(setterStr)\n" +
      String(indentation: indentation) + "}"
  }
}

extension GetterSetterKeywordBlock : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    // no matter the original sequence, we always output getter first, and then the setter if exists
    let setterStr = setter.map({ "\n\(String(indentation: indentation + 1))\($0.textDescription)" }) ?? ""
    return "{\n\(String(indentation: indentation + 1))\(getter.textDescription)\(setterStr)\n\(String(indentation: indentation))}"
  }
}

extension WillSetDidSetBlock.WillSetClause : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)willSet\(nameText) \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension WillSetDidSetBlock.DidSetClause : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)didSet\(nameText) \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension WillSetDidSetBlock : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    // no matter the original sequence, we always output willSetClause first, and then the didSetClause
    let willSetClauseStr = willSetClause.map({ "\n\($0.ttyASTPrint)" }) ?? ""
    let didSetClauseStr = didSetClause.map({ "\n\($0.ttyASTPrint)" }) ?? ""
    return "{\(willSetClauseStr)\(didSetClauseStr)\n\(String(indentation: indentation))}"
  }
}

extension ClassDeclaration.Member : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .declaration(let decl):
      return decl.ttyASTPrint(indentation: indentation)
    case .compilerControl(let stmt):
      return stmt.ttyASTPrint(indentation: indentation)
    }
  }
}

extension ClassDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let finalText = isFinal ? "final " : ""
    let headText = "\(attrsText)\(modifierText)\(finalText)class \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.ttyASTPrint(indentation: indentation + 1) }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return String(indentation: indentation) + "\(headText)\(neckText) {" +
      memberText +
      String(indentation: indentation) + "}"
  }
}

extension DeinitializerDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    return String(indentation: indentation) +
      "\(attrsText)deinit \(body.ttyASTPrint(indentation: indentation))"
  }
}

extension EnumDeclaration.Member : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .declaration(let decl):
      return decl.ttyASTPrint(indentation: indentation)
    case .union(let enumCase):
      return String(indentation: indentation) + enumCase.textDescription
    case .rawValue(let enumCase):
      return String(indentation: indentation) + enumCase.textDescription
    case .compilerControl(let stmt):
      return stmt.ttyASTPrint(indentation: indentation)
    }
  }
}

extension EnumDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let indirectText = isIndirect ? "indirect " : ""
    let headText = "\(attrsText)\(modifierText)\(indirectText)enum \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.ttyASTPrint(indentation: indentation + 1) }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return String(indentation: indentation) +
      "\(headText)\(neckText) {\(memberText)" +
      String(indentation: indentation) + "}"
  }
}

extension ExtensionDeclaration.Member : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .declaration(let decl):
      return decl.ttyASTPrint(indentation: indentation)
    case .compilerControl(let stmt):
      return stmt.ttyASTPrint(indentation: indentation)
    }
  }
}

extension ExtensionDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)extension \(type.textDescription)"
    let typeInheritanceText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(typeInheritanceText)\(whereText)"
    let membersText = members.map({ $0.ttyASTPrint(indentation: indentation + 1) }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return String(indentation: indentation) + "\(headText)\(neckText) {\(memberText)" +
      String(indentation: indentation) + "}"
  }
}

extension FunctionDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)func"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let signatureText = signature.textDescription
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.map({ " \($0.ttyASTPrint(indentation: indentation))" }) ?? ""
    return String(indentation: indentation) +
      "\(headText) \(name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)\(bodyText)"
  }
}

extension InitializerDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)init\(kind.textDescription)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let throwsKindText = throwsKind.textDescription.isEmpty ? "" : " \(throwsKind.textDescription)"
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.ttyASTPrint(indentation: indentation)
    return String(indentation: indentation) +
      "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText) \(bodyText)"
  }
}

extension PrecedenceGroupDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.map({ String(indentation: indentation + 1) + $0.textDescription }).joined(separator: "\n")
    let attrsBlockText = attributes.isEmpty ? "{}" : "{\n\(attrsText)\n}"
    return String(indentation: indentation) + "precedencegroup \(name) \(attrsBlockText)"
  }
}

extension ProtocolDeclaration.PropertyMember : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let blockText = getterSetterKeywordBlock.ttyASTPrint(indentation: indentation)
    return String(indentation: indentation) + "\(attrsText)\(modifiersText)var \(name)\(typeAnnotation) \(blockText)"
  }
}

extension ProtocolDeclaration.SubscriptMember : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return "\(headText) \(resultText) \(getterSetterKeywordBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension ProtocolDeclaration.Member : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .property(let member):
      return member.ttyASTPrint(indentation: indentation)
    case .method(let member):
      return String(indentation: indentation) + member.textDescription
    case .initializer(let member):
      return String(indentation: indentation) + member.textDescription
    case .subscript(let member):
      return member.ttyASTPrint(indentation: indentation)
    case .associatedType(let member):
      return String(indentation: indentation) + member.textDescription
    case .compilerControl(let stmt):
      return stmt.ttyASTPrint(indentation: indentation)
    }
  }
}

extension ProtocolDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)protocol \(name)"
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let membersText = members.map({ $0.ttyASTPrint(indentation: indentation + 1) }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return String(indentation: indentation) +
      "\(headText)\(typeText) {\(memberText)" +
      String(indentation: indentation) + "}"
  }
}

extension StructDeclaration.Member : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .declaration(let decl):
      return decl.ttyASTPrint(indentation: indentation)
    case .compilerControl(let stmt):
      return stmt.ttyASTPrint(indentation: indentation)
    }
  }
}

extension StructDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)struct \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.ttyASTPrint(indentation: indentation + 1) }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return String(indentation: indentation) + "\(headText)\(neckText) {\(memberText)" +
      String(indentation: indentation) + "}"
  }
}

extension SubscriptDeclaration.Body : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .codeBlock(let block):
      return block.ttyASTPrint(indentation: indentation)
    case .getterSetterBlock(let block):
      return block.ttyASTPrint(indentation: indentation)
    case .getterSetterKeywordBlock(let block):
      return block.ttyASTPrint(indentation: indentation)
    }
  }
}

extension SubscriptDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return String(indentation: indentation) + "\(headText) \(resultText) \(body.ttyASTPrint(indentation: indentation))"
  }
}

extension PatternInitializer : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let pttrnText = pattern.textDescription
    guard let initExpr = initializerExpression else {
      return pttrnText
    }
    return "\(pttrnText) = \(initExpr.ttyASTPrint(indentation: indentation))"
  }
}

extension ConstantDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let initsText = initializerList.map({ $0.ttyASTPrint(indentation: indentation) }).joined(separator: ", ")
    return String(indentation: indentation) + "\(attrsText)\(modifiersText)let \(initsText)"
  }
}

extension VariableDeclaration.Body : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .initializerList(let inits):
      return inits.map({ $0.ttyASTPrint(indentation: indentation) }).joined(separator: ", ")
    case let .codeBlock(name, typeAnnotation, codeBlock):
      return "\(name)\(typeAnnotation) \(codeBlock.ttyASTPrint(indentation: indentation))"
    case let .getterSetterBlock(name, typeAnnotation, block):
      return "\(name)\(typeAnnotation) \(block.ttyASTPrint(indentation: indentation))"
    case let .getterSetterKeywordBlock(name, typeAnnotation, block):
      return "\(name)\(typeAnnotation) \(block.ttyASTPrint(indentation: indentation))"
    case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
      let typeAnnoStr = typeAnnotation?.textDescription ?? ""
      let initStr = initExpr.map({ " = \($0.textDescription)" }) ?? ""
      return "\(name)\(typeAnnoStr)\(initStr) \(block.ttyASTPrint(indentation: indentation))"
    }
  }
}

extension VariableDeclaration : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    return String(indentation: indentation) + "\(attrsText)\(modifiersText)var \(body.ttyASTPrint(indentation: indentation))"
  }
}
