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
    return statements
      .map { $0.ttyPrint }
      .joined(separator: "\n")
      + "\n"
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

extension GetterSetterBlock.GetterClause : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)\(modifierText)get \(codeBlock.ttyPrint)"
  }
}

extension GetterSetterBlock.SetterClause : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    let nameText = name.map({ "(\($0))" }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)\(modifierText)set\(nameText) \(codeBlock.ttyPrint)"
  }
}

extension GetterSetterBlock : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    // no matter the original sequence, we always output getter first, and then the setter if exists
    let setterStr = setter.map({ "\n\($0.ttyASTPrint(indentation: indentation + 1))" }) ?? ""
    return "{\n\(getter.ttyASTPrint(indentation: indentation + 1))\(setterStr)\n" +
      String(indentation: indentation) + "}"
  }
}

extension GetterSetterKeywordBlock : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    // no matter the original sequence, we always output getter first, and then the setter if exists
    let setterStr = setter.map({ "\n\(String(indentation: indentation + 1))\($0.textDescription)" }) ?? ""
    return "{\n\(String(indentation: indentation + 1))\(getter.textDescription)\(setterStr)\n\(String(indentation: indentation))}"
  }
}

extension WillSetDidSetBlock.WillSetClause : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)willSet\(nameText) \(codeBlock.ttyPrint)"
  }
}

extension WillSetDidSetBlock.DidSetClause : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return String(indentation: indentation) +
      "\(attrsText)didSet\(nameText) \(codeBlock.ttyPrint)"
  }
}

extension WillSetDidSetBlock : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    // no matter the original sequence, we always output willSetClause first, and then the didSetClause
    let willSetClauseStr = willSetClause.map({ "\n\($0.ttyASTPrint)" }) ?? ""
    let didSetClauseStr = didSetClause.map({ "\n\($0.ttyASTPrint)" }) ?? ""
    return "{\(willSetClauseStr)\(didSetClauseStr)\n\(String(indentation: indentation))}"
  }
}

extension ClassDeclaration.Member : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
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
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    return String(indentation: indentation) +
      "\(attrsText)deinit \(body.ttyPrint)"
  }
}

extension EnumDeclaration.Member : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .declaration(let decl):
      return decl.ttyPrint
    case .union(let enumCase):
      return String(indentation: indentation) + enumCase.textDescription
    case .rawValue(let enumCase):
      return String(indentation: indentation) + enumCase.textDescription
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    }
  }
}

extension EnumDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
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
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)func"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let signatureText = signature.textDescription
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.map({ " \($0.ttyPrint)" }) ?? ""
    return String(indentation: indentation) +
      "\(headText) \(name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)\(bodyText)"
  }
}

extension InitializerDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)init\(kind.textDescription)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let throwsKindText = throwsKind.textDescription.isEmpty ? "" : " \(throwsKind.textDescription)"
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.ttyPrint
    return String(indentation: indentation) +
      "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText) \(bodyText)"
  }
}

extension PrecedenceGroupDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.map({ String(indentation: indentation + 1) + $0.textDescription }).joined(separator: "\n")
    let attrsBlockText = attributes.isEmpty ? "{}" : "{\n\(attrsText)\n}"
    return String(indentation: indentation) + "precedencegroup \(name) \(attrsBlockText)"
  }
}

extension ProtocolDeclaration.PropertyMember : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let blockText = getterSetterKeywordBlock.ttyPrint
    return String(indentation: indentation) + "\(attrsText)\(modifiersText)var \(name)\(typeAnnotation) \(blockText)"
  }
}

extension ProtocolDeclaration.SubscriptMember : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return "\(headText) \(resultText) \(getterSetterKeywordBlock.ttyPrint)"
  }
}

extension ProtocolDeclaration.Member : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .property(let member):
      return member.ttyPrint
    case .method(let member):
      return String(indentation: indentation) + member.textDescription
    case .initializer(let member):
      return String(indentation: indentation) + member.textDescription
    case .subscript(let member):
      return member.ttyPrint
    case .associatedType(let member):
      return String(indentation: indentation) + member.textDescription
    case .compilerControl(let stmt):
      return stmt.ttyPrint
    }
  }
}

extension ProtocolDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
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
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
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
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return String(indentation: indentation) + "\(headText) \(resultText) \(body.ttyPrint)"
  }
}

extension PatternInitializer : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let pttrnText = pattern.textDescription
    guard let initExpr = initializerExpression else {
      return pttrnText
    }
    return "\(pttrnText) = \(initExpr.ttyPrint)"
  }
}

extension ConstantDeclaration : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let initsText = initializerList.map({ $0.ttyPrint }).joined(separator: ", ")
    return String(indentation: indentation) + "\(attrsText)\(modifiersText)let \(initsText)"
  }
}

extension VariableDeclaration.Body : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
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
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    return String(indentation: indentation) + "\(attrsText)\(modifiersText)var \(body.ttyPrint)"
  }
}
