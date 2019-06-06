/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

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
import AST
import Bocho

protocol TTYASTDumpRepresentable {
  var ttyDump: String { get }

  func dump(_ nodeType: String, _ sourceRange: SourceRange) -> String
  func dump(_ exprs: ExpressionList) -> String
  func dump(_ args: [SubscriptArgument]) -> String
  func dump(_ funcSign: FunctionSignature) -> String
  func dump(_ funcSignParams: [FunctionSignature.Parameter]) -> String
  func dump(_ funcResult: FunctionResult) -> String
  func dump(_ condition: Condition) -> String
  func dump(_ conditionList: ConditionList) -> String
  func dump(_ inits: [PatternInitializer]) -> String
  func dump(_ patternInit: PatternInitializer) -> String
  func dump(_ block: GetterSetterKeywordBlock) -> String
  func dump(_ block: GetterSetterBlock) -> String
}

extension TTYASTDumpRepresentable {
  func dump(_ nodeType: String, _ sourceRange: SourceRange) -> String {
    return nodeType.colored(with: .magenta) + " " +
      "<range: \(sourceRange.ttyDescription)>".colored(with: .yellow)
  }

  func dump(_ exprs: ExpressionList) -> String {
    return exprs.enumerated()
      .map { "\($0.offset): \($0.element.ttyDump)" }
      .joined(separator: "\n")
  }

  func dump(_ args: [SubscriptArgument]) -> String {
    return args.enumerated()
      .map { e -> String in
        let arg = e.element
        var idDump = ""
        if let id = arg.identifier {
          idDump = "identifier: `\(id)` "
        }
        return "\(e.offset): \(idDump)\(arg.expression.ttyDump)"
      }
      .joined(separator: "\n")
  }

  func dump(_ funcSign: FunctionSignature) -> String {
    var dumps: [String] = []
    if !funcSign.parameterList.isEmpty {
      dumps.append(dump(funcSign.parameterList))
    }
    if funcSign.throwsKind != .nothrowing {
      dumps.append("throws_kind: `\(funcSign.throwsKind.textDescription)`")
    }
    if let result = funcSign.result {
      dumps.append(dump(result))
    }
    return dumps.joined(separator: "\n")
  }

  func dump(_ funcSignParams: [FunctionSignature.Parameter]) -> String {
    return "parameters:\n" + funcSignParams.enumerated()
      .map { "\($0.offset): \($0.element.textDescription)" }
      .joined(separator: "\n")
  }

  func dump(_ funcResult: FunctionResult) -> String {
    let typeDump = "return_type: `\(funcResult.type.textDescription)`"
    if funcResult.attributes.isEmpty {
      return typeDump
    }
    return "\(typeDump) with attributes `\(funcResult.attributes.textDescription)`"
  }

  func dump(_ conditions: ConditionList) -> String {
    return "conditions:\n" + conditions.enumerated()
      .map { "\($0.offset): \(dump($0.element))" }
      .joined(separator: "\n")
  }

  func dump(_ condition: Condition) -> String {
    switch condition {
    case .expression(let expr):
      return expr.ttyDump
    case .availability(let availabilityCondition):
      return availabilityCondition.textDescription
    case let .case(pattern, expr):
      return "case_binding: `\(pattern)`\n\(expr.ttyDump.indented)"
    case let .let(pattern, expr):
      return "constant_optional_binding: `\(pattern)`\n\(expr.ttyDump.indented)"
    case let .var(pattern, expr):
      return "variable_optional_binding: `\(pattern)`\n\(expr.ttyDump.indented)"
    }
  }

  func dump(_ inits: [PatternInitializer]) -> String {
    switch inits.count {
    case 0:
      return "<no_pattern_initializers>" // Note: this should never happen
    case 1:
      return dump(inits[0])
    default:
      return "pattern_initializers:\n" + inits.enumerated()
        .map { "\($0.offset): \(dump($0.element))" }
        .joined(separator: "\n")
    }
  }

  func dump(_ patternInit: PatternInitializer) -> String {
    let patternDump = "pattern: \(patternInit.pattern.textDescription)"
    guard let initExpr = patternInit.initializerExpression else {
      return patternDump
    }
    return "\(patternDump)\n\(initExpr.ttyDump.indented)"
  }

  func dump(_ block: GetterSetterKeywordBlock) -> String {
    let head = "getter_setter_keyword_block:"
    var body = "getter"
    if !block.getter.attributes.isEmpty {
      body += ", attributes: `\(block.getter.attributes.textDescription)`"
    }
    if let getterModifier = block.getter.mutationModifier {
      body += ", modifier: `\(getterModifier.textDescription)`"
    }
    if let setter = block.setter {
      body += "\nsetter"
      if !setter.attributes.isEmpty {
        body += ", attributes: `\(setter.attributes.textDescription)`"
      }
      if let setterModifier = setter.mutationModifier {
        body += ", modifier: `\(setterModifier.textDescription)`"
      }
    }
    return "\(head)\n\(body.indented)"
  }

  func dump(_ block: GetterSetterBlock) -> String {
    let head = "getter_setter_block:"
    var body = "getter"
    if !block.getter.attributes.isEmpty {
      body += ", attributes: `\(block.getter.attributes.textDescription)`"
    }
    if let getterModifier = block.getter.mutationModifier {
      body += ", modifier: `\(getterModifier.textDescription)`"
    }
    body += "\n"
    body += block.getter.codeBlock.ttyDump.indented
    if let setter = block.setter {
      body += "\nsetter"
      if let setterName = setter.name {
        body += ", name: `\(setterName)`"
      }
      if !setter.attributes.isEmpty {
        body += ", attributes: `\(setter.attributes.textDescription)`"
      }
      if let setterModifier = setter.mutationModifier {
        body += ", modifier: `\(setterModifier.textDescription)`"
      }
      body += "\n"
      body += setter.codeBlock.ttyDump.indented
    }
    return "\(head)\n\(body.indented)"
  }
}
