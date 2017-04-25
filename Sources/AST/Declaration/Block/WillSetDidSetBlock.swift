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

public struct WillSetDidSetBlock {
  public struct WillSetClause {
    public let attributes: Attributes
    public let name: Identifier?
    public let codeBlock: CodeBlock

    public init(
      attributes: Attributes = [],
      name: Identifier? = nil,
      codeBlock: CodeBlock
    ) {
      self.attributes = attributes
      self.name = name
      self.codeBlock = codeBlock
    }
  }

  public struct DidSetClause {
    public let attributes: Attributes
    public let name: Identifier?
    public let codeBlock: CodeBlock

    public init(
      attributes: Attributes = [],
      name: Identifier? = nil,
      codeBlock: CodeBlock
    ) {
      self.attributes = attributes
      self.name = name
      self.codeBlock = codeBlock
    }
  }

  public let willSetClause: WillSetClause?
  public let didSetClause: DidSetClause?

  public init(
    willSetClause: WillSetClause, didSetClause: DidSetClause? = nil
  ) {
    self.willSetClause = willSetClause
    self.didSetClause = didSetClause
  }

  public init(
    didSetClause: DidSetClause, willSetClause: WillSetClause? = nil
  ) {
    self.willSetClause = willSetClause
    self.didSetClause = didSetClause
  }
}

extension WillSetDidSetBlock.WillSetClause : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return "\(attrsText)willSet\(nameText) \(codeBlock.textDescription)"
  }
}

extension WillSetDidSetBlock.DidSetClause : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let nameText = name.map({ "(\($0))" }) ?? ""
    return "\(attrsText)didSet\(nameText) \(codeBlock.textDescription)"
  }
}

extension WillSetDidSetBlock : ASTTextRepresentable {
  public var textDescription: String {
    // no matter the original sequence, we always output willSetClause first,
    // and then the didSetClause
    let willSetClauseStr =
      willSetClause.map({ "\n\($0.textDescription)" }) ?? ""
    let didSetClauseStr = didSetClause.map({ "\n\($0.textDescription)" }) ?? ""
    return "{\(willSetClauseStr)\(didSetClauseStr)\n}"
  }
}
