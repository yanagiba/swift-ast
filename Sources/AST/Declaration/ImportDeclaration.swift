/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

public class ImportDeclaration : ASTNode, Declaration {
  public enum Kind : String {
    case `typealias`, `struct`, `class`, `enum`, `protocol`, `let`, `var`, `func`
  }
  public typealias PathIdentifier = String

  public let attributes: Attributes
  public let kind: Kind?
  public let path: [PathIdentifier]

  public init(
    attributes: Attributes = [], kind: Kind? = nil, path: [PathIdentifier]
  ) {
    self.attributes = attributes
    self.kind = kind
    self.path = path
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let kindText = kind.map({ " \($0.rawValue)" }) ?? ""
    let pathText = path.joined(separator: ".")
    return "\(attrsText)import\(kindText) \(pathText)"
  }
}
