/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public class MacroDeclaration : ASTNode, Declaration {
  public let attributes: Attributes
  public let accessLevelModifier: AccessLevelModifier?
  public let name: Identifier
  public let genericParameterClause: GenericParameterClause?
  public private(set) var signature: FunctionSignature
  public let genericWhereClause: GenericWhereClause?
  public let definition: ASTExpression?

  public init(
    attributes: Attributes = [],
    accessLevelModifier: AccessLevelModifier? = nil,
    name: Identifier,
    genericParameterClause: GenericParameterClause? = nil,
    signature: FunctionSignature,
    genericWhereClause: GenericWhereClause? = nil,
    definition: ASTExpression? = nil
  ) {
    self.attributes = attributes
    self.accessLevelModifier = accessLevelModifier
    self.name = name
    self.genericParameterClause = genericParameterClause
    self.signature = signature
    self.genericWhereClause = genericWhereClause
    self.definition = definition
  }

  // MARK: - Node Mutations

  public func replaceSignature(with newSignature: FunctionSignature) {
    signature = newSignature
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let headText = "\(attrsText)\(modifierText)macro"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let signatureText = signature.textDescription
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let definitionText = definition.map({ " = \($0.textDescription)" }) ?? ""
    return "\(headText) \(name)\(genericParameterClauseText)\(signatureText)\(genericWhereClauseText)\(definitionText)"
  }
}
