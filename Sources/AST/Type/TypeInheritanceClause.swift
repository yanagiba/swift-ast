/*
   Copyright 2016, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public struct TypeInheritanceClause {
  public struct InheritedType {
    public let type: TypeIdentifier
    public let isSuppressed: Bool

    public init(type: TypeIdentifier, isSuppressed: Bool = false) {
      self.type = type
      self.isSuppressed = isSuppressed
    }
  }

  public let classRequirement: Bool
  public let typeInheritanceList: [InheritedType]

  public init(
    classRequirement: Bool = false, typeInheritanceList: [InheritedType] = []
  ) {
    self.classRequirement = classRequirement
    self.typeInheritanceList = typeInheritanceList
  }
}

extension TypeInheritanceClause.InheritedType : ASTTextRepresentable {
  public var textDescription: String {
    let prefix = isSuppressed ? "~" : ""
    return "\(prefix)\(type.textDescription)"
  }
}

extension TypeInheritanceClause : ASTTextRepresentable {
  public var textDescription: String {
    var prefixText = ": "
    if classRequirement {
        prefixText += "class"
    }
    if classRequirement && !typeInheritanceList.isEmpty {
        prefixText += ", "
    }
    return "\(prefixText)\(typeInheritanceList.map({ $0.textDescription }).joined(separator: ", "))"
  }
}
