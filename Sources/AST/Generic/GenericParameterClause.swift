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

public struct GenericParameterClause {
  public enum GenericParameter {
    case identifier(Identifier)
    case typeConformance(Identifier, TypeIdentifier)
    case protocolConformance(Identifier, ProtocolCompositionType)
  }

  public let parameterList: [GenericParameter]

  public init(parameterList: [GenericParameter]) {
    self.parameterList = parameterList
  }
}

extension GenericParameterClause.GenericParameter : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case let .identifier(t):
      return t.textDescription
    case let .typeConformance(t, typeIdentifier):
      return "\(t): \(typeIdentifier.textDescription)"
    case let .protocolConformance(t, protocolCompositionType):
      return "\(t): \(protocolCompositionType.textDescription)"
    }
  }
}

extension GenericParameterClause : ASTTextRepresentable {
  public var textDescription: String {
    return "<\(parameterList.map({ $0.textDescription }).joined(separator: ", "))>"
  }
}
