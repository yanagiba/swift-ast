/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public struct FunctionSignature {
  public struct Parameter {
    public let externalName: Identifier?
    public let localName: Identifier
    public let typeAnnotation: TypeAnnotation
    public let defaultArgumentClause: Expression?
    public let isVarargs: Bool

    public init(
      externalName: Identifier? = nil,
      localName: Identifier,
      typeAnnotation: TypeAnnotation
    ) {
      self.externalName = externalName
      self.localName = localName
      self.typeAnnotation = typeAnnotation
      self.defaultArgumentClause = nil
      self.isVarargs = false
    }

    public init(
      externalName: Identifier? = nil,
      localName: Identifier,
      typeAnnotation: TypeAnnotation,
      isVarargs: Bool = false
    ) {
      self.externalName = externalName
      self.localName = localName
      self.typeAnnotation = typeAnnotation
      self.defaultArgumentClause = nil
      self.isVarargs = isVarargs
    }

    public init(
      externalName: Identifier? = nil,
      localName: Identifier,
      typeAnnotation: TypeAnnotation,
      defaultArgumentClause: Expression? = nil
    ) {
      self.externalName = externalName
      self.localName = localName
      self.typeAnnotation = typeAnnotation
      self.defaultArgumentClause = defaultArgumentClause
      self.isVarargs = false
    }
  }

  public let parameterList: [Parameter]
  public let throwsKind: ThrowsKind
  public let result: FunctionResult?

  public init(
    parameterList: [Parameter] = [],
    throwsKind: ThrowsKind = .nothrowing,
    result: FunctionResult? = nil
  ) {
    self.parameterList = parameterList
    self.throwsKind = throwsKind
    self.result = result
  }
}

extension FunctionSignature.Parameter : ASTTextRepresentable {
  public var textDescription: String {
    let externalNameText = externalName.map({ [$0.textDescription] }) ?? []
    let localNameText = localName.textDescription.isEmpty ? [] : [localName.textDescription]
    let nameText = (externalNameText + localNameText).joined(separator: " ")
    let typeAnnoText = typeAnnotation.textDescription
    let defaultText =
      defaultArgumentClause.map({ " = \($0.textDescription)" }) ?? ""
    let varargsText = isVarargs ? "..." : ""
    return "\(nameText)\(typeAnnoText)\(defaultText)\(varargsText)"
  }
}

extension FunctionSignature : ASTTextRepresentable {
  public var textDescription: String {
    let parameterText =
      ["(\(parameterList.map({ $0.textDescription }).joined(separator: ", ")))"]
    let throwsKindText =
      throwsKind.textDescription.isEmpty ? [] : [throwsKind.textDescription]
    let resultText = result.map({ [$0.textDescription] }) ?? []
    return (parameterText + throwsKindText + resultText).joined(separator: " ")
  }
}
