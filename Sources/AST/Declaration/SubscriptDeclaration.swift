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

public class SubscriptDeclaration : ASTNode, Declaration {
  public enum Body {
    case codeBlock(CodeBlock)
    case getterSetterBlock(GetterSetterBlock)
    case getterSetterKeywordBlock(GetterSetterKeywordBlock)
  }

  public let attributes: Attributes
  public let modifiers: DeclarationModifiers
  public let parameterList: [FunctionSignature.Parameter]
  public let resultAttributes: Attributes
  public let resultType: Type
  public let body: Body

  private init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    parameterList: [FunctionSignature.Parameter] = [],
    resultAttributes: Attributes = [],
    resultType: Type,
    body: Body
  ) {
    self.attributes = attributes
    self.modifiers = modifiers
    self.parameterList = parameterList
    self.resultAttributes = resultAttributes
    self.resultType = resultType
    self.body = body
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    parameterList: [FunctionSignature.Parameter] = [],
    resultAttributes: Attributes = [],
    resultType: Type,
    codeBlock: CodeBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      parameterList: parameterList,
      resultAttributes: resultAttributes,
      resultType: resultType,
      body: .codeBlock(codeBlock))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    parameterList: [FunctionSignature.Parameter] = [],
    resultAttributes: Attributes = [],
    resultType: Type,
    getterSetterBlock: GetterSetterBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      parameterList: parameterList,
      resultAttributes: resultAttributes,
      resultType: resultType,
      body: .getterSetterBlock(getterSetterBlock))
  }

  public convenience init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    parameterList: [FunctionSignature.Parameter] = [],
    resultAttributes: Attributes = [],
    resultType: Type,
    getterSetterKeywordBlock: GetterSetterKeywordBlock
  ) {
    self.init(attributes: attributes,
      modifiers: modifiers,
      parameterList: parameterList,
      resultAttributes: resultAttributes,
      resultType: resultType,
      body: .getterSetterKeywordBlock(getterSetterKeywordBlock))
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let headText = "\(attrsText)\(modifiersText)subscript\(parameterText)"

    let resultAttrsText = resultAttributes.isEmpty ? "" : "\(resultAttributes.textDescription) "
    let resultText = "-> \(resultAttrsText)\(resultType.textDescription)"

    return "\(headText) \(resultText) \(body.textDescription)"
  }
}

extension SubscriptDeclaration.Body : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .codeBlock(let block):
      return block.textDescription
    case .getterSetterBlock(let block):
      return block.textDescription
    case .getterSetterKeywordBlock(let block):
      return block.textDescription
    }
  }
}
