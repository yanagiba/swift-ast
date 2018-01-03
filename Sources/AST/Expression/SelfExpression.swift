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

public class SelfExpression : ASTNode, PrimaryExpression {
  public enum Kind {
    case `self`
    case method(Identifier) // Note: even though this includes functions and properties,
                            // but Swift PL reference calls it `self-method-expression`
    case `subscript`([SubscriptArgument])
    case initializer
  }

  public private(set) var kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - Node Mutations

  public func reset(with newKind: Kind) {
    kind = newKind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case .self:
      return "self"
    case .method(let name):
      return "self.\(name)"
    case .subscript(let arguments):
      return "self[\(arguments.textDescription)]"
    case .initializer:
      return "self.init"
    }
  }
}
