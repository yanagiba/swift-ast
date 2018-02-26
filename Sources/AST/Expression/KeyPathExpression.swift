/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public class KeyPathExpression : ASTNode, PrimaryExpression {
  public enum Postfix {
    case question
    case exclaim
    case `subscript`([SubscriptArgument])
  }

  public typealias Component = (Identifier?, [Postfix])

  public let type: Type?
  public let components: [Component]

  public init(type: Type? = nil, components: [Component]) {
    self.type = type
    self.components = components
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let typeDescription = type?.textDescription ?? ""
    let componentsDescription = components
      .map { ($0.0?.textDescription ?? "") + $0.1.map({ $0.textDescription }).joined() }
      .joined(separator: ".")
    return "\\\(typeDescription).\(componentsDescription)"
  }
}

extension KeyPathExpression.Postfix : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .question:
      return "?"
    case .exclaim:
      return "!"
    case .subscript(let args):
      return "[\(args.textDescription)]"
    }
  }
}
