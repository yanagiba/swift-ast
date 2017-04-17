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

public class VariableDeclaration : ASTNode, Declaration {
  public enum Body {
    case initializerList([PatternInitializer])
    case codeBlock(Identifier, TypeAnnotation, CodeBlock)
    case getterSetterBlock(Identifier, TypeAnnotation, GetterSetterBlock)
    case getterSetterKeywordBlock(
      Identifier, TypeAnnotation, GetterSetterKeywordBlock)
    case willSetDidSetBlock(
      Identifier, TypeAnnotation?, Expression?, WillSetDidSetBlock)
  }
  public let attributes: Attributes
  public let modifiers: DeclarationModifiers
  public let body: Body

  private init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    body: Body
  ) {
    self.attributes = attributes
    self.modifiers = modifiers
    self.body = body
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    initializerList: [PatternInitializer]
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers, body: .initializerList(initializerList))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    variableName: Identifier,
    typeAnnotation: TypeAnnotation,
    codeBlock: CodeBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      body: .codeBlock(variableName, typeAnnotation, codeBlock))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    variableName: Identifier,
    typeAnnotation: TypeAnnotation,
    getterSetterBlock: GetterSetterBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      body: .getterSetterBlock(variableName, typeAnnotation, getterSetterBlock))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    variableName: Identifier,
    typeAnnotation: TypeAnnotation,
    getterSetterKeywordBlock: GetterSetterKeywordBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      body: .getterSetterKeywordBlock(
        variableName, typeAnnotation, getterSetterKeywordBlock))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    variableName: Identifier,
    initializer: Expression,
    willSetDidSetBlock: WillSetDidSetBlock
  ) {
    self.init(
      attributes: attributes,
      modifiers: modifiers,
      body: .willSetDidSetBlock(
        variableName, nil, initializer, willSetDidSetBlock))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    variableName: Identifier,
    typeAnnotation: TypeAnnotation,
    initializer: Expression? = nil,
    willSetDidSetBlock: WillSetDidSetBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      body: .willSetDidSetBlock(
        variableName, typeAnnotation, initializer, willSetDidSetBlock))
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    return "\(attrsText)\(modifiersText)var \(body.textDescription)"
  }
}

extension VariableDeclaration.Body : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .initializerList(let inits):
      return inits.map({ $0.textDescription }).joined(separator: ", ")
    case let .codeBlock(name, typeAnnotation, codeBlock):
      return "\(name)\(typeAnnotation) \(codeBlock.textDescription)"
    case let .getterSetterBlock(name, typeAnnotation, block):
      return "\(name)\(typeAnnotation) \(block.textDescription)"
    case let .getterSetterKeywordBlock(name, typeAnnotation, block):
      return "\(name)\(typeAnnotation) \(block.textDescription)"
    case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
      let typeAnnoStr = typeAnnotation?.textDescription ?? ""
      let initStr = initExpr.map({ " = \($0.textDescription)" }) ?? ""
      return "\(name)\(typeAnnoStr)\(initStr) \(block.textDescription)"
    }
  }
}
