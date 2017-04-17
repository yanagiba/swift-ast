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

public class FunctionCallExpression : ASTNode, PostfixExpression {
  public enum Argument {
    case expression(Expression)
    case namedExpression(Identifier, Expression)
    case memoryReference(Expression)
    case namedMemoryReference(Identifier, Expression)
    case `operator`(Operator)
    case namedOperator(Identifier, Operator)
  }

  public typealias ArgumentList = [Argument]

  public let postfixExpression: PostfixExpression
  public let argumentClause: ArgumentList?
  public let trailingClosure: ClosureExpression?

  public init(
    postfixExpression: PostfixExpression, argumentClause: ArgumentList
  ) {
    self.postfixExpression = postfixExpression
    self.argumentClause = argumentClause
    self.trailingClosure = nil
  }

  public init(
    postfixExpression: PostfixExpression,
    argumentClause: ArgumentList? = nil,
    trailingClosure: ClosureExpression
  ) {
    self.postfixExpression = postfixExpression
    self.argumentClause = argumentClause
    self.trailingClosure = trailingClosure
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    var parameterText = ""
    if let argumentClause = argumentClause {
      let argumentsText = argumentClause.map({ $0.textDescription }).joined(separator: ", ")
      parameterText = "(\(argumentsText))"
    }
    var trailingText = ""
    if let trailingClosure = trailingClosure {
      trailingText = " \(trailingClosure.textDescription)"
    }
    return "\(postfixExpression.textDescription)\(parameterText)\(trailingText)"
  }
}

extension FunctionCallExpression.Argument : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .expression(let expr):
      return expr.textDescription
    case let .namedExpression(identifier, expr):
      return "\(identifier): \(expr.textDescription)"
    case .memoryReference(let expr):
      return "&\(expr.textDescription)"
    case let .namedMemoryReference(name, expr):
      return "\(name): &\(expr.textDescription)"
    case .operator(let op):
      return op
    case let .namedOperator(identifier, op):
      return "\(identifier): \(op)"
    }
  }
}
