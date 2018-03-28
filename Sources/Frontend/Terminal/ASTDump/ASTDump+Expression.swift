/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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
import Bocho

extension AssignmentOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("assign_expr", sourceRange)
    let leftExprDump = leftExpression.ttyDump.indented
    let rightExprDump = rightExpression.ttyDump.indented
    return "<AssignmentOperatorExpression>\(head)\n\(leftExprDump)\n\(rightExprDump)</AssignmentOperatorExpression>"
  }
}

extension BinaryOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("binary_op_expr", sourceRange)
    let opDump = "operator: `\(binaryOperator)`".indented
    let leftExprDump = leftExpression.ttyDump.indented
    let rightExprDump = rightExpression.ttyDump.indented
    return "<BinaryOperatorExpression>\(head)\n\(opDump.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;"))\n\(leftExprDump)\n\(rightExprDump)</BinaryOperatorExpression>"
  }
}

extension ClosureExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("closure_expr", sourceRange)
    var body = ""
    if let signature = signature {
      if let captureList = signature.captureList {
        body += "\n"
        body += "capture_list: `\(captureList.map({ $0.textDescription }).joined(separator: ", "))`".indented
      }
      if let parameterClause = signature.parameterClause {
        body += "\n"
        body += "parameters: `\(parameterClause.textDescription)`".indented
      }
      if signature.canThrow {
        body += "\n"
        body += "throwable: `true`".indented
      }
      if let functionResult = signature.functionResult {
        body += "\n"
        body += dump(functionResult).indented
      }
    }
    if let stmts = statements {
      body += "\n"
      body += "statements:".indented
      body += "\n"
      body += stmts.enumerated()
        .map { "\($0.offset): \($0.element.ttyDump)" }
        .joined(separator: "\n")
        .indented
    }
    return "<ClosureExpression>\(head)\(body)</ClosureExpression>"
  }
}

extension ExplicitMemberExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("explicit_member_expr", sourceRange)
    var body = ""
    switch kind {
    case let .tuple(postfixExpr, index):
      body += postfixExpr.ttyDump.indented
      body += "\n"
      body += "index: `\(index)`".indented
    case let .namedType(postfixExpr, identifier):
      body += postfixExpr.ttyDump.indented
      body += "\n"
      body += "identifier: `\(identifier)`".indented
    case let .generic(postfixExpr, identifier, genericClause):
      body += postfixExpr.ttyDump.indented
      body += "\n"
      body += "identifier: `\(identifier)`".indented
      body += ", generic_argument: `\(genericClause.textDescription)`"
    case let .argument(postfixExpr, identifier, argumentNames):
      body += postfixExpr.ttyDump.indented
      body += "\n"
      body += "identifier: `\(identifier)`".indented
      body += "\n" + "arguments:".indented
      if argumentNames.isEmpty {
        body += " &lt;empty&gt;"
      }
      for (index, arg) in argumentNames.enumerated() {
        body += "\n" + "\(index): name: `\(arg)`".indented
      }
    }
    return "<ExplicitMemberExpression>\(head)\n\(body)</ExplicitMemberExpression>"
  }
}

extension ForcedValueExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("forced_value_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indented
    return "<ForcedValueExpression>\(head)\n\(exprDump)</ForcedValueExpression>"
  }
}

extension FunctionCallExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("function_call_expr", sourceRange)
    var body = postfixExpression.ttyDump.indented
    if let argumentClause = argumentClause {
      body += "\n" + "arguments:".indented
      if argumentClause.isEmpty {
        body += " &lt;empty&gt;"
      }
      for (index, arg) in argumentClause.enumerated() {
        body += "\n" + "\(index): ".indented
        switch arg {
        case .expression(let expr):
          body += "kind: `expression`\n"
          body += expr.ttyDump.indented.indented
        case let .namedExpression(identifier, expr):
          body += "kind: `named_expression`, name: `\(identifier)`\n"
          body += expr.ttyDump.indented.indented
        case .memoryReference(let expr):
          body += "kind: `memory_reference`\n"
          body += expr.ttyDump.indented.indented
        case let .namedMemoryReference(name, expr):
          body += "kind: `named_memory_reference`, name: `\(name)\n"
          body += expr.ttyDump.indented.indented
        case .operator(let op):
          body += "kind: `operator`, operator: `\(op)`"
        case let .namedOperator(identifier, op):
          body += "kind: `named_operator`, name: `\(identifier)`, operator: `\(op)`"
        }
      }
    }
    if let trailingClosure = trailingClosure {
      body += "\n" + "trailing_\(trailingClosure.ttyDump)".indented
    }
    return "<FunctionCallExpression>\(head)\n\(body)</FunctionCallExpression>"
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
        body += ", generic_argument: `\(gnrc.textDescription.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;"))`"
      }
    case let .implicitParameterName(i, generic):
      body += "kind: `implicit_param_name`, index: `\(i)`"
      if let gnrc = generic {
        body += ", generic_argument: `\(gnrc.textDescription.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;"))`"
      }
    }
    return "<IdentifierExpression>\(head)\n\(body)</IdentifierExpression>"
  }
}

extension ImplicitMemberExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("implicit_member_expr", sourceRange)
    let body = String.indent + "identifier: `identifier`"
    return "<ImplicitMemberExpression>\(head)\n\(body)</ImplicitMemberExpression>"
  }
}

extension InOutExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("in_out_expr", sourceRange)
    let body = "identifier: `\(identifier)`".indented
    return "<InOutExpression>\(head)\n\(body)</InOutExpression>"
  }
}

extension InitializerExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("initializer_expr", sourceRange)
    var body = postfixExpression.ttyDump.indented
    body += "\n" + "arguments:".indented
    if argumentNames.isEmpty {
      body += " &lt;empty&gt;"
    }
    for (index, arg) in argumentNames.enumerated() {
      body += "\n" + "\(index): name: `\(arg)`".indented
    }
    return "<InitializerExpression>\(head)\n\(body)</InitializerExpression>"
  }
}

extension KeyPathExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("key_path_expr", sourceRange)
    var body = ""
    if let type = type {
      body += "\n" + "type: `\(type.textDescription)`".indented
    }
    for (offset, element) in components.enumerated() {
      let component = (element.0?.textDescription ?? "") + element.1.map({ $0.textDescription }).joined()
      body += "\n" + "\(offset): component: `\(component)`".indented
    }
    return "<KeyPathExpression>\(head)\(body)</KeyPathExpression>"
  }
}

extension KeyPathStringExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let result = dump("key_path_string_expr", sourceRange) + "\n" + expression.ttyDump.indented
    return "<KeyPathStringExpression>\(result)</KeyPathStringExpression>"
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
        body += ", elements: &lt;empty&gt;"
      } else {
        body += "\n"
        body += dump(exprs).indented
      }
    case .dictionary(let entries):
      body += "kind: `dict`"
      if entries.isEmpty {
        body += ", entries: &lt;empty&gt;"
      } else {
        body += "\n"
        body += entries.enumerated()
          .map { e -> String in
            "\(e.offset): " + e.element.key.ttyDump +
              "\n\(e.offset): " + e.element.value.ttyDump
          }
          .joined(separator: "\n")
          .indented
      }
    case .playground(let playgroundLiteral):
      body += "kind: `playground`, literal: `\(playgroundLiteral.textDescription)`"
    }
    return "<LiteralExpression>\(head)\n\(body)</LiteralExpression>"
  }
}

extension OptionalChainingExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("optional_chaining_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indented
    return "<OptionalChainingExpression>\(head)\n\(exprDump)</OptionalChainingExpression>"
  }
}

extension ParenthesizedExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("paren_expr", sourceRange)
    let exprDump = expression.ttyDump.indented
    return "<ParenthesizedExpression>\(head)\n\(exprDump)</ParenthesizedExpression>"
  }
}

extension PostfixOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("postfix_op_expr", sourceRange)
    let opDump = "operator: `\(postfixOperator)`".indented
    let exprDump = postfixExpression.ttyDump.indented
    return "<PostfixOperatorExpression>\(head)\n\(opDump)\n\(exprDump)</PostfixOperatorExpression>"
  }
}

extension PostfixSelfExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("postfix_self_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indented
    return "<PostfixSelfExpression>\(head)\n\(exprDump)</PostfixSelfExpression>"
  }
}

extension PrefixOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("prefix_op_expr", sourceRange)
    let opDump = "operator: `\(prefixOperator)`".indented
    let exprDump = postfixExpression.ttyDump.indented
    return "<PrefixOperatorExpression>\(head)\n\(opDump)\n\(exprDump)</PrefixOperatorExpression>"
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
      var textDesc = identifier.textDescription
      if !argumentNames.isEmpty {
        let argumentNamesDesc = argumentNames.map({ "\($0):" }).joined()
        textDesc += "(\(argumentNamesDesc))"
      }
      body = "self_member: `\(textDesc)`"
    }
    return "<SelectorExpression>\(head)\n\(body.indented)</SelectorExpression>"
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
    case .subscript(let args):
      body += "kind: `subscript`"
      body += "\n"
      body += dump(args).indented
    case .initializer:
      body += "kind: `initializer`"
    }
    return "<SelfExpression>\(head)\n\(body)</SelfExpression>"
  }
}

extension SequenceExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("sequence_expr", sourceRange)

    let body = elements.enumerated().map {
      let elemDump: String
      switch $0.element {
      case .expression(let expr):
        elemDump = "type: expression " + expr.ttyDump.indented
      case .assignmentOperator:
        elemDump = "type: assignment_op"
      case .binaryOperator(let op):
        elemDump = "type: binary_op operator: `\(op)`"
      case .ternaryConditionalOperator(let expr):
        elemDump = "type: ternary_conditional_op " + expr.ttyDump.indented
      case .typeCheck(let type):
        elemDump = "type: check " + type.textDescription
      case .typeCast(let type):
        elemDump = "type: cast " + type.textDescription
      case .typeConditionalCast(let type):
        elemDump = "type: conditional_cast " + type.textDescription
      case .typeForcedCast(let type):
        elemDump = "type: forced_cast " + type.textDescription
      }
      return "\($0.offset): \(elemDump)"
    }.joined(separator: "\n").indented

    return "<SequenceExpression>\(head)\n\(body)</SequenceExpression>"
  }
}

extension SubscriptExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("subscript_expr", sourceRange)
    let exprDump = postfixExpression.ttyDump.indented
    let indexHead = "index:".indented
    let argsDump = dump(arguments).indented
    return "<SubscriptExpression>\(head)\n\(exprDump)\n\(indexHead)\n\(argsDump)</SubscriptExpression>"
  }
}

extension SuperclassExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("superclass_expr", sourceRange)
    var body = String.indent
    switch kind {
    case .method(let name):
      body += "kind: `method`, method_name: `\(name)`"
    case .subscript(let args):
      body += "kind: `subscript`"
      body += "\n"
      body += dump(args).indented
    case .initializer:
      body += "kind: `initializer`"
    }
    return "<SuperclassExpression>\(head)\n\(body)</SuperclassExpression>"
  }
}

extension TernaryConditionalOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("ternary_cond_expr", sourceRange)
    let condExprDump = conditionExpression.ttyDump.indented
    let trueExprDump = trueExpression.ttyDump.indented
    let falseExprDump = falseExpression.ttyDump.indented
    return "<TernaryConditionalOperatorExpression>\(head)\n\(condExprDump)\n\(trueExprDump)\n\(falseExprDump)</TernaryConditionalOperatorExpression>"
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
    return "<TryOperatorExpression>\(head)\n" + "kind: `\(tryText)`\n\(exprDump)</TryOperatorExpression>".indented
  }
}

extension TupleExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("tuple_expr", sourceRange)
    let body: String
    if elementList.isEmpty {
      body = String.indent + "elements: &lt;empty&gt;"
    } else {
      body = elementList.enumerated().map {
        var idText = "\($0.offset): "
        if let id = $0.element.identifier {
          idText += "id: `\(id)` "
        }
        return "\(idText)\($0.element.expression.ttyDump)"
      }.joined(separator: "\n").indented
    }
    return "<TupleExpression>\(head)\n\(body)</TupleExpression>"
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
      typeText = type.textDescription.replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;")
    case let .conditionalCast(expr, type):
      exprText = expr.ttyDump
      operatorText = "conditional_cast"
      typeText = type.textDescription
    case let .forcedCast(expr, type):
      exprText = expr.ttyDump
      operatorText = "forced_cast"
      typeText = type.textDescription
    }
    return "<TypeCastingOperatorExpression>\(head)\n" +
      "kind: `\(operatorText)`, type: `\(typeText)`\n\(exprText)</TypeCastingOperatorExpression>".indented
  }
}

extension WildcardExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    let result = dump("wildcard_expr", sourceRange)
    return "<WildcardExpression>\(result)</WildcardExpression>"
  }
}
