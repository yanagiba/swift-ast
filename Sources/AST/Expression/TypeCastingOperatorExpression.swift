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

public class TypeCastingOperatorExpression : ASTNode, BinaryExpression {
  public enum Kind {
    case check(Expression, Type) // is
    case cast(Expression, Type) // as
    case conditionalCast(Expression, Type) // as?
    case forcedCast(Expression, Type) // as!
  }

  public let kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let exprText: String
    let operatorText: String
    let typeText: String
    switch kind {
    case let .check(expr, type):
      exprText = expr.textDescription
      operatorText = "is"
      typeText = type.textDescription
    case let .cast(expr, type):
      exprText = expr.textDescription
      operatorText = "as"
      typeText = type.textDescription
    case let .conditionalCast(expr, type):
      exprText = expr.textDescription
      operatorText = "as?"
      typeText = type.textDescription
    case let .forcedCast(expr, type):
      exprText = expr.textDescription
      operatorText = "as!"
      typeText = type.textDescription
    }
    return "\(exprText) \(operatorText) \(typeText)"
  }
}
