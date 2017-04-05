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

import AST

extension Expression {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case let representable as TTYASTPrintRepresentable:
      return representable.ttyASTPrint(indentation: indentation)
    default:
      return textDescription
    }
  }
}

extension AssignmentOperatorExpression : TTYASTPrintExpression {
  func ttyASTPrint(indentation: Int) -> String {
    return "\(leftExpression.textDescription) = " +
      rightExpression.ttyASTPrint(indentation: indentation)
  }
}

extension ClosureExpression : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    var signatureText = ""
    var stmtsText = ""

    if let signature = signature {
      signatureText = " \(signature.textDescription) in"
      if statements == nil {
        stmtsText = " "
      }
    }

    if let stmts = statements {
      if signature == nil && stmts.count == 1 {
        let stmt = stmts[0]
        switch stmt {
        case let tryOpExpr as TryOperatorExpression:
          stmtsText = "\n\(String(indentation: indentation + 1))" +
            tryOpExpr.ttyASTPrint(indentation: indentation + 1) +
            "\n\(String(indentation: indentation))"
        default:
          stmtsText = " \(stmt.textDescription) "
        }
      } else {
        stmtsText = "\n\(stmts.ttyASTPrint(indentation: indentation + 1))" +
          "\n\(String(indentation: indentation))"
      }
    }
    return "{\(signatureText)\(stmtsText)}"
  }
}

extension ExplicitMemberExpression : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case let .tuple(postfixExpr, index):
      return "\(postfixExpr.ttyASTPrint(indentation: indentation)).\(index)"
    case let .namedType(postfixExpr, identifier):
      return "\(postfixExpr.ttyASTPrint(indentation: indentation)).\(identifier)"
    case let .generic(postfixExpr, identifier, genericArgumentClause):
      return "\(postfixExpr.ttyASTPrint(indentation: indentation)).\(identifier)" +
        "\(genericArgumentClause.textDescription)"
    case let .argument(postfixExpr, identifier, argumentNames):
      var textDesc = "\(postfixExpr.ttyASTPrint(indentation: indentation)).\(identifier)"
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      return textDesc
    }
  }
}

extension FunctionCallExpression.Argument : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .expression(let expr):
      return expr.ttyASTPrint(indentation: indentation)
    case let .namedExpression(identifier, expr):
      return "\(identifier): \(expr.ttyASTPrint(indentation: indentation))"
    default:
      return textDescription
    }
  }
}

extension FunctionCallExpression : TTYASTPrintExpression {
  func ttyASTPrint(indentation: Int) -> String {
    var parameterText = ""
    if let argumentClause = argumentClause {
      let argumentsText = argumentClause
        .map({ $0.ttyASTPrint(indentation: indentation) })
        .joined(separator: ", ")
      parameterText = "(\(argumentsText))"
    }
    var trailingText = ""
    if let trailingClosure = trailingClosure {
      trailingText = " \(trailingClosure.ttyASTPrint(indentation: indentation))"
    }
    return postfixExpression.ttyASTPrint(indentation: indentation) +
      "\(parameterText)\(trailingText)"
  }
}

extension TryOperatorExpression : TTYASTPrintExpression {
  func ttyASTPrint(indentation: Int) -> String {
    let tryText: String
    let exprText: String
    switch self {
    case .try(let expr):
      tryText = "try"
      exprText = expr.ttyASTPrint(indentation: indentation)
    case .forced(let expr):
      tryText = "try!"
      exprText = expr.ttyASTPrint(indentation: indentation)
    case .optional(let expr):
      tryText = "try?"
      exprText = expr.ttyASTPrint(indentation: indentation)
    }
    return "\(tryText) \(exprText)"
  }
}
