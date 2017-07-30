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

import Source

public class SequenceExpression : ASTNode, Expression {
  public enum ElementKind {
    case expression(Expression)
    case assignmentOperator
    case binaryOperator(Operator)
    case ternaryConditionalOperator(Expression)
    case typeCheck(Type)
    case typeCast(Type)
    case typeConditionalCast(Type)
    case typeForcedCast(Type)
  }

  public typealias Element = (ElementKind, SourceRange)

  public let elements: [Element]

  public init(elements: [Element]) {
    self.elements = elements
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    return elements.map({ $0.0.textDescription }).joined(separator: " ")
  }
}

extension SequenceExpression.ElementKind : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .expression(let expr):
      return expr.textDescription
    case .assignmentOperator:
      return "="
    case .binaryOperator(let op):
      return op
    case .ternaryConditionalOperator(let expr):
      return "? \(expr.textDescription) :"
    case .typeCheck(let type):
      return "as \(type.textDescription)"
    case .typeCast(let type):
      return "as \(type.textDescription)"
    case .typeConditionalCast(let type):
      return "as \(type.textDescription)"
    case .typeForcedCast(let type):
      return "as \(type.textDescription)"
    }
  }
}
