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

public class PrecedenceGroupDeclaration : ASTNode, Declaration {
  public enum Attribute {
    case higherThan(IdentifierList)
    case lowerThan(IdentifierList)
    case assignment(Bool)
    case associativityLeft
    case associativityRight
    case associativityNone
  }

  public let name: Identifier
  public let attributes: [Attribute]

  public init(name: Identifier, attributes: [Attribute] = []) {
    self.name = name
    self.attributes = attributes
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.map({ $0.textDescription }).joined(separator: "\n")
    let attrsBlockText = attributes.isEmpty ? "{}" : "{\n\(attrsText)\n}"
    return "precedencegroup \(name) \(attrsBlockText)"
  }
}

extension PrecedenceGroupDeclaration.Attribute : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .higherThan(let ids):
      return "higherThan: \(ids.textDescription)"
    case .lowerThan(let ids):
      return "lowerThan: \(ids.textDescription)"
    case .assignment(let b):
      let boolText = b ? "true" : "false"
      return "assignment: \(boolText)"
    case .associativityLeft:
      return "associativity: left"
    case .associativityRight:
      return "associativity: right"
    case .associativityNone:
      return "associativity: none"
    }
  }
}
