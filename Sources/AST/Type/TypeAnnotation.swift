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

import Source

public class TypeAnnotation : LocatableNode {
  public let type: Type
  public let attributes: Attributes
  public let isInOutParameter: Bool

  public init(
    type: Type,
    attributes: Attributes = [],
    isInOutParameter: Bool = false
  ) {
    self.type = type
    self.attributes = attributes
    self.isInOutParameter = isInOutParameter
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attr = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let inoutStr = isInOutParameter ? "inout " : ""
    return ": \(attr)\(inoutStr)\(type.textDescription)"
  }
}

extension TypeAnnotation : ASTTextRepresentable, SourceLocatable {
}
