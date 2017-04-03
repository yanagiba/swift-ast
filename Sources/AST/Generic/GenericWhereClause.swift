/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public struct GenericWhereClause {
  public enum Requirement {
    case typeConformance(TypeIdentifier, TypeIdentifier)
    case protocolConformance(TypeIdentifier, ProtocolCompositionType)
    case sameType(TypeIdentifier, Type)
  }

  public let requirementList: [Requirement]

  public init(requirementList: [Requirement]) {
    self.requirementList = requirementList
  }
}

extension GenericWhereClause.Requirement : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case let .sameType(t, type):
      return "\(t.textDescription) == \(type.textDescription)"
    case let .typeConformance(t, typeIdentifier):
      return "\(t.textDescription): \(typeIdentifier.textDescription)"
    case let .protocolConformance(t, protocolCompositionType):
      return "\(t.textDescription): \(protocolCompositionType.textDescription)"
    }
  }
}

extension GenericWhereClause : ASTTextRepresentable {
  public var textDescription: String {
    return "where \(requirementList.map({ $0.textDescription }).joined(separator: ", "))"
  }
}
