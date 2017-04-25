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

public class InitializerDeclaration : ASTNode, Declaration {
  public enum InitKind {
    case nonfailable
    case optionalFailable
    case implicitlyUnwrappedFailable
  }

  public let attributes: Attributes
  public let modifiers: DeclarationModifiers
  public let kind: InitKind
  public let genericParameterClause: GenericParameterClause?
  public let parameterList: [FunctionSignature.Parameter]
  public let throwsKind: ThrowsKind
  public let genericWhereClause: GenericWhereClause?
  public let body: CodeBlock

  public init(
    attributes: Attributes = [],
    modifiers: DeclarationModifiers = [],
    kind: InitKind = .nonfailable,
    genericParameterClause: GenericParameterClause? = nil,
    parameterList: [FunctionSignature.Parameter] = [],
    throwsKind: ThrowsKind = .nothrowing,
    genericWhereClause: GenericWhereClause? = nil,
    body: CodeBlock
  ) {
    self.attributes = attributes
    self.modifiers = modifiers
    self.kind = kind
    self.genericParameterClause = genericParameterClause
    self.parameterList = parameterList
    self.throwsKind = throwsKind
    self.genericWhereClause = genericWhereClause
    self.body = body
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifiersText = modifiers.isEmpty ? "" : "\(modifiers.textDescription) "
    let headText = "\(attrsText)\(modifiersText)init\(kind.textDescription)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let parameterText = "(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"
    let throwsKindText = throwsKind.textDescription.isEmpty ? "" : " \(throwsKind.textDescription)"
    let genericWhereClauseText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let bodyText = body.textDescription
    return "\(headText)\(genericParameterClauseText)\(parameterText)\(throwsKindText)\(genericWhereClauseText) \(bodyText)"
  }
}

extension InitializerDeclaration.InitKind : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .nonfailable:
      return ""
    case .optionalFailable:
      return "?"
    case .implicitlyUnwrappedFailable:
      return "!"
    }
  }
}
