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

extension AssignmentOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("assign_expr", sourceRange)
    let leftExprDump = leftExpression.ttyDump.indent
    let rightExprDump = rightExpression.ttyDump.indent
    return "\(head)\n\(leftExprDump)\n\(rightExprDump)"
  }
}

extension BinaryOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("binary_op_expr", sourceRange)
    let opDump = "operator: `\(binaryOperator)`".indent
    let leftExprDump = leftExpression.ttyDump.indent
    let rightExprDump = rightExpression.ttyDump.indent
    return "\(head)\n\(opDump)\n\(leftExprDump)\n\(rightExprDump)"
  }
}

extension ClosureExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("closure_expr", sourceRange)
    var body = ""
    if let signature = signature {
      if let captureList = signature.captureList {
        body += "\n"
        body += "capture_list: `\(captureList.map({ $0.textDescription }).joined(separator: ", "))`".indent
      }
      if let parameterClause = signature.parameterClause {
        body += "\n"
        body += "parameters: `\(parameterClause.textDescription)`".indent
      }
      if signature.canThrow {
        body += "\n"
        body += "throwable: `true`".indent
      }
      if let functionResult = signature.functionResult {
        body += "\n"
        body += dump(functionResult).indent
      }
    }
    if let stmts = statements {
      body += "\n"
      body += "statements:".indent
      body += "\n"
      body += stmts.enumerated()
        .map { "\($0): \($1.ttyDump)" }
        .joined(separator: "\n")
        .indent
    }
    return "\(head)\(body)"
  }
}

extension ExplicitMemberExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("explicit_member_expr", sourceRange)
    var body = ""
    switch kind {
    case let .tuple(postfixExpr, index):
      body += postfixExpr.ttyDump.indent
      body += "\n"
      body += "index: `\(index)`".indent
    case let .namedType(postfixExpr, identifier):
      body += postfixExpr.ttyDump.indent
      body += "\n"
      body += "identifier: `\(identifier)`".indent
    case let .generic(postfixExpr, identifier, genericClause):
      body += postfixExpr.ttyDump.indent
      body += "\n"
      body += "identifier: `\(identifier)`".indent
      body += ", generic_argument: `\(genericClause.textDescription)`"
    case let .argument(postfixExpr, identifier, argumentNames):
      body += postfixExpr.ttyDump.indent
      body += "\n"
      body += "identifier: `\(identifier)`".indent
      body += "\n" + "arguments:".indent
      if argumentNames.isEmpty {
        body += " <empty>"
      }
      for (index, arg) in argumentNames.enumerated() {
        body += "\n" + "\(index): name: `\(arg)`".indent
      }
    }
    return "\(head)\n\(body)"
  }
}

extension ForcedValueExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("forced_value_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indent
    return "\(head)\n\(exprDump)"
  }
}

extension FunctionCallExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("function_call_expr", sourceRange)
    var body = postfixExpression.ttyDump.indent
    if let argumentClause = argumentClause {
      body += "\n" + "arguments:".indent
      if argumentClause.isEmpty {
        body += " <empty>"
      }
      for (index, arg) in argumentClause.enumerated() {
        body += "\n" + "\(index): ".indent
        switch arg {
        case .expression(let expr):
          body += "kind: `expression`\n"
          body += expr.ttyDump.indent.indent
        case let .namedExpression(identifier, expr):
          body += "kind: `named_expression`, name: `\(identifier)`\n"
          body += expr.ttyDump.indent.indent
        case .memoryReference(let expr):
          body += "kind: `memory_reference`\n"
          body += expr.ttyDump.indent.indent
        case let .namedMemoryReference(name, expr):
          body += "kind: `named_memory_reference`, name: `\(name)\n"
          body += expr.ttyDump.indent.indent
        case .operator(let op):
          body += "kind: `operator`, operator: `\(op)`"
        case let .namedOperator(identifier, op):
          body += "kind: `named_operator`, name: `\(identifier)`, operator: `\(op)`"
        }
      }
    }
    if let trailingClosure = trailingClosure {
      body += "\n" + "trailing_\(trailingClosure.ttyDump)".indent
    }
    return "\(head)\n\(body)"
  }
}

extension IdentifierExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("identifier_expr", sourceRange)
    var body = String.indent
    switch kind {
    case let .identifier(id, generic):
      body += "kind: `identifier`, identifier: `\(id)`"
      if let gnrc = generic {
        body += ", generic_argument: `\(gnrc.textDescription)`"
      }
    case let .implicitParameterName(i, generic):
      body += "kind: `implicit_param_name`, index: `\(i)`"
      if let gnrc = generic {
        body += ", generic_argument: `\(gnrc.textDescription)`"
      }
    }
    return "\(head)\n\(body)"
  }
}

extension ImplicitMemberExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("implicit_member_expr", sourceRange)
    let body = String.indent + "identifier: `identifier`"
    return "\(head)\n\(body)"
  }
}

extension InOutExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("in_out_expr", sourceRange)
    let body = "identifier: `\(identifier)`".indent
    return "\(head)\n\(body)"
  }
}

extension InitializerExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("initializer_expr", sourceRange)
    var body = postfixExpression.ttyDump.indent
    body += "\n" + "arguments:".indent
    if argumentNames.isEmpty {
      body += " <empty>"
    }
    for (index, arg) in argumentNames.enumerated() {
      body += "\n" + "\(index): name: `\(arg)`".indent
    }
    return "\(head)\n\(body)"
  }
}

extension KeyPathExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("keypath_expr", sourceRange) + "\n" + expression.ttyDump.indent
  }
}

extension LiteralExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("literal_expr", sourceRange)
    var body = String.indent
    switch kind {
    case .nil:
      body += "kind: `nil`, literal: `nil`"
    case .boolean(let bool):
      body += "kind: `bool`, literal: `\(bool ? "true" : "false")`"
    case let .integer(i, rawText):
      body += "kind: `int`, literal: `\(i)`, raw_text: `\(rawText)`"
    case let .floatingPoint(d, rawText):
      body += "kind: `double`, literal: `\(d)`, raw_text: `\(rawText)`"
    case let .staticString(_, rawText):
      body += "kind: `string`, raw_text: `\(rawText)`"
    case let .interpolatedString(_, rawText):
      body += "kind: `interpolated_string`, raw_text: `\(rawText)`"
    case .array(let exprs):
      body += "kind: `array`"
      if exprs.isEmpty {
        body += ", elements: <empty>"
      } else {
        body += "\n"
        body += dump(exprs).indent
      }
    case .dictionary(let entries):
      body += "kind: `dict`"
      if entries.isEmpty {
        body += ", entries: <empty>"
      } else {
        body += "\n"
        body += entries.enumerated()
          .map { (index, entry) -> String in
            "\(index): " + entry.key.ttyDump + "\n\(index): " + entry.value.ttyDump
          }
          .joined(separator: "\n")
          .indent
      }
    }
    return "\(head)\n\(body)"
  }
}

extension OptionalChainingExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("optional_chaining_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indent
    return "\(head)\n\(exprDump)"
  }
}

extension ParenthesizedExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("paren_expr", sourceRange)
    let exprDump = expression.ttyDump.indent
    return "\(head)\n\(exprDump)"
  }
}

extension PostfixOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("postfix_op_expr", sourceRange)
    let opDump = "operator: `\(postfixOperator)`".indent
    let exprDump = postfixExpression.ttyDump.indent
    return "\(head)\n\(opDump)\n\(exprDump)"
  }
}

extension PostfixSelfExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("postfix_self_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indent
    return "\(head)\n\(exprDump)"
  }
}

extension PrefixOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("prefix_op_expr", sourceRange)
    let opDump = "operator: `\(prefixOperator)`".indent
    let exprDump = postfixExpression.ttyDump.indent
    return "\(head)\n\(opDump)\n\(exprDump)"
  }
}

extension SelectorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("selector_expr", sourceRange)
    let body: String
    switch kind {
    case .selector(let expr):
      body = expr.ttyDump
    case .getter(let expr):
      body = "getter: " + expr.ttyDump
    case .setter(let expr):
      body = "setter: " + expr.ttyDump
    case let .selfMember(identifier, argumentNames):
      var textDesc = identifier
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      body = "self_member: `\(textDesc)`"
    }
    return "\(head)\n\(body.indent)"
  }
}

extension SelfExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("self_expr", sourceRange)
    var body = String.indent
    switch kind {
    case .self:
      body += "kind: `self`"
    case .method(let name):
      body += "kind: `method`, method_name: `\(name)`"
    case .subscript(let exprs):
      body += "kind: `subscript`"
      body += "\n"
      body += dump(exprs).indent
    case .initializer:
      body += "kind: `initializer`"
    }
    return "\(head)\n\(body)"
  }
}

extension SubscriptExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("subscript_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indent
    let indexHead = "index:".indent
    let exprsDump = dump(expressionList).indent
    return "\(head)\n\(exprDump)\n\(indexHead)\n\(exprsDump)"
  }
}

extension SuperclassExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("superclass_expr", sourceRange)
    var body = String.indent
    switch kind {
    case .method(let name):
      body += "kind: `method`, method_name: `\(name)`"
    case .subscript(let exprs):
      body += "kind: `subscript`"
      body += "\n"
      body += dump(exprs).indent
    case .initializer:
      body += "kind: `initializer`"
    }
    return "\(head)\n\(body)"
  }
}

extension TernaryConditionalOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("ternary_cond_expr", sourceRange)
    let condExprDump = conditionExpression.ttyDump.indent
    let trueExprDump = trueExpression.ttyDump.indent
    let falseExprDump = falseExpression.ttyDump.indent
    return "\(head)\n\(condExprDump)\n\(trueExprDump)\n\(falseExprDump)"
  }
}

extension TryOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("try_expr", sourceRange)
    let tryText: String
    let exprDump: String
    switch kind {
    case .try(let expr):
      tryText = "try"
      exprDump = expr.ttyDump
    case .forced(let expr):
      tryText = "forced_try"
      exprDump = expr.ttyDump
    case .optional(let expr):
      tryText = "optional_try"
      exprDump = expr.ttyDump
    }
    return "\(head)\n" + "kind: `\(tryText)`\n\(exprDump)".indent
  }
}

extension TupleExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("tuple_expr", sourceRange)
    let body: String
    if elementList.isEmpty {
      body = String.indent + "elements: <empty>"
    } else {
      body = elementList.enumerated().map { index, element in
        var idText = "\(index): "
        if let id = element.identifier {
          idText += "id: `\(id)` "
        }
        return "\(idText)\(element.expression.ttyDump)"
      }.joined(separator: "\n").indent
    }
    return "\(head)\n\(body)"
  }
}

extension TypeCastingOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("type_casting_expr", sourceRange)
    let exprText: String
    let operatorText: String
    let typeText: String
    switch kind {
    case let .check(expr, type):
      exprText = expr.ttyDump
      operatorText = "is"
      typeText = type.textDescription
    case let .cast(expr, type):
      exprText = expr.ttyDump
      operatorText = "cast"
      typeText = type.textDescription
    case let .conditionalCast(expr, type):
      exprText = expr.ttyDump
      operatorText = "conditional_cast"
      typeText = type.textDescription
    case let .forcedCast(expr, type):
      exprText = expr.ttyDump
      operatorText = "forced_cast"
      typeText = type.textDescription
    }
    return "\(head)\n" +
      "kind: `\(operatorText)`, type: `\(typeText)`\n\(exprText)".indent
  }
}

extension WildcardExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("wildcard_expr", sourceRange)
  }
}
