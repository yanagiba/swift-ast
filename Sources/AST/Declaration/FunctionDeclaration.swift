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

public class FunctionDeclaration : ASTNode, Declaration {
  public let attributes: Attributes
  public let modifiers: DeclarationModifiers
  public let name: Identifier
  public let genericParameterClause: GenericParameterClause?
  public let signature: FunctionSignature
  public let genericWhereClause: GenericWhereClause?
  public let body: CodeBlock?

  public init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    name: Identifier,
    genericParameterClause: GenericParameterClause? = nil,
    signature: FunctionSignature,
    genericWhereClause: GenericWhereClause? = nil,
    body: CodeBlock? = nil
  ) {
    self.attributes = attributes
    self.modifiers = modifiers
    self.name = name
    self.genericParameterClause = genericParameterClause
    self.signature = signature
    self.genericWhereClause = genericWhereClause
    self.body = body
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)func"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let signatureText = signature.textDescription
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.map({ " \($0.textDescription)" }) ?? ""
    return "\(headText) \(name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)\(bodyText)"
  }
}
