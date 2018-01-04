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

public class SelectorExpression : ASTNode, PrimaryExpression {
  public enum Kind {
    case selector(Expression)
    case getter(Expression)
    case setter(Expression)

    // Note: I don't see any defined expression that I can use,
    // so store this special type of expression inside selector-expression for now
    // TODO: consider introducing a new expression type
    case selfMember(Identifier, [Identifier])
  }

  public let kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case .selector(let expr):
      return "#selector(\(expr.textDescription))"
    case .getter(let expr):
      return "#selector(getter: \(expr.textDescription))"
    case .setter(let expr):
      return "#selector(setter: \(expr.textDescription))"
    case let .selfMember(identifier, argumentNames):
      var textDesc = identifier.textDescription
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0.textDescription):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      return "#selector(\(textDesc))"
    }
  }
}
