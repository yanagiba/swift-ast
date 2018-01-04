/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public class FunctionType : TypeBase {
  public struct Argument {
    public let externalName: Identifier?
    public let localName: Identifier?
    public let type: Type
    public let attributes: Attributes
    public let isInOutParameter: Bool
    public let isVariadic: Bool

    public init(
      type: Type,
      externalName: Identifier? = nil,
      localName: Identifier? = nil,
      attributes: Attributes = [],
      isInOutParameter: Bool = false,
      isVariadic: Bool = false
    ) {
      self.externalName = externalName
      self.localName = localName
      self.type = type
      self.attributes = attributes
      self.isInOutParameter = isInOutParameter
      self.isVariadic = isVariadic
    }
  }

  public let attributes: Attributes
  public let arguments: [Argument]
  public let returnType: Type
  public let throwsKind: ThrowsKind

  public init(
    attributes: Attributes = [],
    arguments: [Argument],
    returnType: Type,
    throwsKind: ThrowsKind
  ) {
    self.attributes = attributes
    self.arguments = arguments
    self.returnType = returnType
    self.throwsKind = throwsKind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let argsText = "(\(arguments.map({ $0.textDescription }).joined(separator: ", ")))"
    let throwsText = throwsKind.textDescription.isEmpty ? "" : " \(throwsKind.textDescription)"
    return "\(attrsText)\(argsText)\(throwsText) -> \(returnType.textDescription)"
  }
}

extension FunctionType.Argument : ASTTextRepresentable {
  public var textDescription: String {
    let attr = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let inoutStr = isInOutParameter ? "inout " : ""
    var nameStr = externalName.map({ "\($0) " }) ?? ""
    if let localName = localName {
      nameStr += "\(localName): "
    }
    let variadicDots = isVariadic ? "..." : ""
    return "\(nameStr)\(attr)\(inoutStr)\(type.textDescription)\(variadicDots)"
  }
}
