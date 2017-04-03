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

public struct GetterSetterKeywordBlock {
  public struct GetterKeywordClause {
    public let attributes: Attributes
    public let mutationModifier: MutationModifier?

    public init(
      attributes: Attributes = [],
      mutationModifier: MutationModifier? = nil
    ) {
      self.attributes = attributes
      self.mutationModifier = mutationModifier
    }
  }

  public struct SetterKeywordClause {
    public let attributes: Attributes
    public let mutationModifier: MutationModifier?

    public init(
      attributes: Attributes = [],
      mutationModifier: MutationModifier? = nil
    ) {
      self.attributes = attributes
      self.mutationModifier = mutationModifier
    }
  }

  public let getter: GetterKeywordClause
  public let setter: SetterKeywordClause?

  public init(
    getter: GetterKeywordClause, setter: SetterKeywordClause? = nil
  ) {
    self.getter = getter
    self.setter = setter
  }
}

extension GetterSetterKeywordBlock.GetterKeywordClause : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    return "\(attrsText)\(modifierText)get"
  }
}

extension GetterSetterKeywordBlock.SetterKeywordClause : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = mutationModifier.map({ "\($0.textDescription) " }) ?? ""
    return "\(attrsText)\(modifierText)set"
  }
}

extension GetterSetterKeywordBlock : ASTTextRepresentable {
  public var textDescription: String {
    // no matter the original sequence, we always output getter first,
    // and then the setter if exists
    let setterStr = setter.map({ "\n\($0.textDescription)" }) ?? ""
    return "{\n\(getter.textDescription)\(setterStr)\n}"
  }
}
