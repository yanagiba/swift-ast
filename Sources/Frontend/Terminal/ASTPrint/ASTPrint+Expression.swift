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

extension AssignmentOperatorExpression : TTYASTPrintExpression {
  var ttyPrint: String {
    return leftExpression.ttyPrint + " = " + rightExpression.ttyPrint
  }
}

extension ClosureExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    switch kind {
    case let .tuple(postfixExpr, index):
      return "\(postfixExpr.ttyPrint).\(index)"
    case let .namedType(postfixExpr, identifier):
      return "\(postfixExpr.ttyPrint).\(identifier)"
    case let .generic(postfixExpr, identifier, genericArgumentClause):
      return "\(postfixExpr.ttyPrint).\(identifier)" +
        "\(genericArgumentClause.textDescription)"
    case let .argument(postfixExpr, identifier, argumentNames):
      var textDesc = "\(postfixExpr.ttyPrint).\(identifier)"
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      return textDesc
    }
  }
}

extension FunctionCallExpression.Argument : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .expression(let expr):
      return expr.ttyPrint
    case let .namedExpression(identifier, expr):
      return "\(identifier): \(expr.ttyPrint)"
    default:
      return textDescription
    }
  }
}

extension FunctionCallExpression : TTYASTPrintExpression {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    var parameterText = ""
    if let argumentClause = argumentClause {
      let argumentsText = argumentClause
        .map({ $0.ttyPrint })
        .joined(separator: ", ")
      parameterText = "(\(argumentsText))"
    }
    var trailingText = ""
    if let trailingClosure = trailingClosure {
      trailingText = " \(trailingClosure.ttyPrint)"
    }
    return postfixExpression.ttyPrint +
      "\(parameterText)\(trailingText)"
  }
}

extension KeyPathExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "#keyPath(\(expression.ttyPrint))"
  }
}

extension LiteralExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    switch kind {
    case .array(let exprs):
      let arrayText = exprs
        .map({ $0.ttyPrint })
        .joined(separator: ", ")
      return "[\(arrayText)]"
    case .dictionary(let entries):
      if entries.isEmpty {
        return "[:]"
      }
      let dictText = entries
        .map({ "\($0.key.ttyPrint): \($0.value.ttyPrint)" })
        .joined(separator: ", ")
      return "[\(dictText)]"
    default:
      return textDescription
    }
  }
}

extension ParenthesizedExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "(\(expression.ttyPrint))"
  }
}

extension SelectorExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    switch kind {
    case .selector(let expr):
      return "#selector(\(expr.ttyPrint))"
    case .getter(let expr):
      return "#selector(getter: \(expr.ttyPrint))"
    case .setter(let expr):
      return "#selector(setter: \(expr.ttyPrint))"
    default:
      return textDescription
    }
  }
}

extension SelfExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    switch kind {
    case .subscript(let exprs):
      let exprsText = exprs
        .map({ $0.ttyPrint })
        .joined(separator: ", ")
      return "self[\(exprsText)]"
    default:
      return textDescription
    }
  }
}

extension SuperclassExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    switch kind {
    case .subscript(let exprs):
      let exprsText = exprs
        .map({ $0.ttyPrint })
        .joined(separator: ", ")
      return "super[\(exprsText)]"
    default:
      return textDescription
    }
  }
}

extension TryOperatorExpression : TTYASTPrintExpression {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    let tryText: String
    let exprText: String
    switch kind {
    case .try(let expr):
      tryText = "try"
      exprText = expr.ttyPrint
    case .forced(let expr):
      tryText = "try!"
      exprText = expr.ttyPrint
    case .optional(let expr):
      tryText = "try?"
      exprText = expr.ttyPrint
    }
    return "\(tryText) \(exprText)"
  }
}

extension TupleExpression : TTYASTPrintRepresentable {
  var ttyPrint: String {
    if elementList.isEmpty {
      return "()"
    }

    let listText: [String] = elementList.map { element in
      var idText = ""
      if let id = element.identifier {
        idText = "\(id): "
      }
      return "\(idText)\(element.expression.ttyPrint)"
    }
    return "(\(listText.joined(separator: ", ")))"
  }
}
