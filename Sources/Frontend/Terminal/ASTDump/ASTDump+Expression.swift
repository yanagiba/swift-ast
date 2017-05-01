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
    return dump("binary_op_expr", sourceRange)
  }
}

extension ClosureExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("closure_expr", sourceRange)
  }
}

extension DynamicTypeExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("dyn_type_expr", sourceRange)
  }
}

extension ExplicitMemberExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("explicit_member_expr", sourceRange)
  }
}

extension ForcedValueExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("forced_value_expr", sourceRange)
  }
}

extension FunctionCallExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("function_call_expr", sourceRange)
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
    return dump("implicit_member_expr", sourceRange)
  }
}

extension InOutExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("in_out_expr", sourceRange)
  }
}

extension InitializerExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("initializer_expr", sourceRange)
  }
}

extension KeyPathExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("keypath_expr", sourceRange)
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
    return dump("optional_chaining_expr", sourceRange)
  }
}

extension ParenthesizedExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("paren_expr", sourceRange)
  }
}

extension PostfixOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("postfix_op_expr", sourceRange)
  }
}

extension PostfixSelfExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("postfix_self_expr", sourceRange)
  }
}

extension PrefixOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("prefix_op_expr", sourceRange)
  }
}

extension SelectorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("selector_expr", sourceRange)
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
    return dump("subscript_expr", sourceRange)
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
    return dump("ternary_cond_expr", sourceRange)
  }
}

extension TryOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("try_expr", sourceRange)
  }
}

extension TupleExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("tuple_expr", sourceRange)
  }
}

extension TypeCastingOperatorExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("type_casting_expr", sourceRange)
  }
}

extension WildcardExpression : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("wildcard_expr", sourceRange)
  }
}
