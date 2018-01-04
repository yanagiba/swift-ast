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

public class TupleType : TypeBase {
  public struct Element {
    public let type: Type
    public let name: Identifier?
    public let attributes: Attributes
    public let isInOutParameter: Bool

    public init(type: Type) {
      self.type = type
      self.name = nil
      self.attributes = []
      self.isInOutParameter = false
    }

    public init(
      type: Type,
      name: Identifier,
      attributes: Attributes = [],
      isInOutParameter: Bool = false
    ) {
      self.name = name
      self.type = type
      self.attributes = attributes
      self.isInOutParameter = isInOutParameter
    }
  }

  public let elements: [Element]

  public init(elements: [Element]) {
    self.elements = elements
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    return "(\(elements.map({ $0.textDescription }).joined(separator: ", ")))"
  }
}

extension TupleType.Element : ASTTextRepresentable {
  public var textDescription: String {
    let attr = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let inoutStr = isInOutParameter ? "inout " : ""
    var nameStr = ""
    if let name = name {
      nameStr = "\(name): "
    }
    return "\(nameStr)\(attr)\(inoutStr)\(type.textDescription)"
  }
}
