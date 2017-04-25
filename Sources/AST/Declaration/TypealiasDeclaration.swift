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

public class TypealiasDeclaration : ASTNode, Declaration {
  public let attributes: Attributes
  public let accessLevelModifier: AccessLevelModifier?
  public let name: Identifier
  public let generic: GenericParameterClause?
  public let assignment: Type

  public init(
    attributes: Attributes = [],
    accessLevelModifier: AccessLevelModifier? = nil,
    name: Identifier,
    generic: GenericParameterClause? = nil,
    assignment: Type
  ) {
    self.attributes = attributes
    self.accessLevelModifier = accessLevelModifier
    self.name = name
    self.generic = generic
    self.assignment = assignment
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let genericText = generic?.textDescription ?? ""
    return "\(attrsText)\(modifierText)typealias \(name)\(genericText) = \(assignment.textDescription)"
  }
}
