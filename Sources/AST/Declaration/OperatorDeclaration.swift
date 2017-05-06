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

public class OperatorDeclaration : ASTNode, Declaration {
  public enum Kind {
    case prefix(Operator)
    case postfix(Operator)
    case infix(Operator, Identifier?)
  }

  public let kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case .prefix(let op):
      return "prefix operator \(op)"
    case .postfix(let op):
      return "postfix operator \(op)"
    case .infix(let op, nil):
      return "infix operator \(op)"
    case .infix(let op, let id?):
      return "infix operator \(op) : \(id)"
    }
  }
}
