/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public class ExplicitMemberExpression : ASTNode, PostfixExpression {
  public enum Kind {
    case tuple(PostfixExpression, Int)
    case namedType(PostfixExpression, Identifier)
    case generic(PostfixExpression, Identifier, GenericArgumentClause)
    case argument(PostfixExpression, Identifier, [Identifier])
  }

  public let kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case let .tuple(postfixExpr, index):
      return "\(postfixExpr.textDescription).\(index)"
    case let .namedType(postfixExpr, identifier):
      return "\(postfixExpr.textDescription).\(identifier)"
    case let .generic(postfixExpr, identifier, genericArgumentClause):
      return "\(postfixExpr.textDescription).\(identifier)" +
        "\(genericArgumentClause.textDescription)"
    case let .argument(postfixExpr, identifier, argumentNames):
      var textDesc = "\(postfixExpr.textDescription).\(identifier)"
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      return textDesc
    }
  }
}
