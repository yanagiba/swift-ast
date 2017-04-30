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

import Source
import AST

class ASTDumpPresenter : ASTVisitor {
  var presentation = ""
  private var _nested = 0

  private func append(
    _ nodeType: String,
    _ sourceRange: SourceRange,
    _ autoIndent: Bool = true
  ) {
    if autoIndent {
      presentation += String(indentation: _nested)
    }
    presentation += nodeType.colored(with: .magenta) + " "
    presentation += "<range: \(sourceRange.ttyDescription)>".colored(with: .yellow)
    presentation += "\n"
  }

  public func visit(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
    guard _nested == 0 else {
      return false
    }

    presentation = ""

    append("top_level_decl", topLevelDecl.sourceRange)
    _nested += 1

    return true
  }

  public func visit(_ codeBlock: CodeBlock) throws -> Bool {
    _nested += 1
    for stmt in codeBlock.statements {
      _ = try traverse(stmt)
    }
    _nested -= 1
    return false
  }

  // Declarations

  public func visit(_ classDecl: ClassDeclaration) throws -> Bool {
    append("class_decl", classDecl.sourceRange)

    _nested += 1
    for member in classDecl.members {
      switch member {
      case .declaration(let decl):
        _ = try traverse(decl)
      case .compilerControl(let stmt):
        _ = try traverse(stmt)
      }
    }
    _nested -= 1

    return false
  }

  public func visit(_ constDecl: ConstantDeclaration) throws -> Bool {
    append("const_decl", constDecl.sourceRange)

    _nested += 1
    for initializer in constDecl.initializerList {
      if let expr = initializer.initializerExpression {
        guard try traverse(expr) else { return false }
      }
    }
    _nested -= 1

    return false
  }

  public func visit(_ deinitDecl: DeinitializerDeclaration) throws -> Bool {
    append("deinit_decl", deinitDecl.sourceRange)

    return true
  }

  public func visit(_ enumDecl: EnumDeclaration) throws -> Bool {
    append("enum_decl", enumDecl.sourceRange)

    _nested += 1
    for member in enumDecl.members {
      switch member {
      case .declaration(let decl):
        _ = try traverse(decl)
      case .compilerControl(let stmt):
        _ = try traverse(stmt)
      case .union:
        presentation += String(indentation: _nested)
        presentation += "<union_case> TODO" + "\n"
      case .rawValue:
        presentation += String(indentation: _nested)
        presentation += "<raw_value_case> TODO" + "\n"
      }
    }
    _nested -= 1

    return false
  }

  public func visit(_ extDecl: ExtensionDeclaration) throws -> Bool {
    append("ext_decl", extDecl.sourceRange)

    _nested += 1
    for member in extDecl.members {
      switch member {
      case .declaration(let decl):
        _ = try traverse(decl)
      case .compilerControl(let stmt):
        _ = try traverse(stmt)
      }
    }
    _nested -= 1

    return false
  }

  public func visit(_ funcDecl: FunctionDeclaration) throws -> Bool {
    append("func_decl", funcDecl.sourceRange)

    if let body = funcDecl.body {
      _ = try traverse(body)
    }

    return false
  }

  public func visit(_ importDecl: ImportDeclaration) throws -> Bool {
    append("import_decl", importDecl.sourceRange)

    return true
  }

  public func visit(_ initDecl: InitializerDeclaration) throws -> Bool {
    append("init_decl", initDecl.sourceRange)

    _ = try traverse(initDecl.body)

    return false
  }

  public func visit(_ opDecl: OperatorDeclaration) throws -> Bool {
    append("op_decl", opDecl.sourceRange)

    return true
  }

  public func visit(
    _ precedenceGroupDecl: PrecedenceGroupDeclaration
  ) throws -> Bool {
    append("precedence_group_decl", precedenceGroupDecl.sourceRange)

    return true
  }

  public func visit(_ protoDecl: ProtocolDeclaration) throws -> Bool {
    append("proto_decl", protoDecl.sourceRange)

    _nested += 1
    for member in protoDecl.members {
      presentation += String(indentation: _nested)
      presentation += "<protocol_decl_member> TODO" + "\n"
      // switch member {
      // case .method(let method):
      //   for param in method.signature.parameterList {
      //     if let defaultArg = param.defaultArgumentClause {
      //       guard try traverse(defaultArg) else { return false }
      //     }
      //   }
      // case .initializer(let initializer):
      //   for param in initializer.parameterList {
      //     if let defaultArg = param.defaultArgumentClause {
      //       guard try traverse(defaultArg) else { return false }
      //     }
      //   }
      // case .subscript(let member):
      //   for param in member.parameterList {
      //     if let defaultArg = param.defaultArgumentClause {
      //       guard try traverse(defaultArg) else { return false }
      //     }
      //   }
      // case .compilerControl(let stmt):
      //   guard try traverse(stmt) else { return false }
      // default:
      //   continue
      // }
    }
    _nested -= 1

    return false
  }

  public func visit(_ structDecl: StructDeclaration) throws -> Bool {
    append("struct_decl", structDecl.sourceRange)

    _nested += 1
    for member in structDecl.members {
      switch member {
      case .declaration(let decl):
        _ = try traverse(decl)
      case .compilerControl(let stmt):
        _ = try traverse(stmt)
      }
    }
    _nested -= 1

    return false
  }

  public func visit(_ subscriptDecl: SubscriptDeclaration) throws -> Bool {
    append("subscript_decl", subscriptDecl.sourceRange)

    // TODO: handle block properly

    return true
  }

  public func visit(_ typealiasDecl: TypealiasDeclaration) throws -> Bool {
    append("typealias_decl", typealiasDecl.sourceRange)

    return true
  }

  public func visit(_ varDecl: VariableDeclaration) throws -> Bool {
    append("var_decl", varDecl.sourceRange)

    // TODO: handle block properly

    return true
  }

  // Statements

  public func visit(_ breakStmt: BreakStatement) throws -> Bool {
    append("break_stmt", breakStmt.sourceRange)
    if let labelName = breakStmt.labelName {
      presentation += String(indentation: _nested+2)
      presentation += "label_name: `\(labelName)`\n"
    }

    return true
  }

  public func visit(
    _ compilerCtrlStmt: CompilerControlStatement
  ) throws -> Bool {
    append("compiler_ctrl_stmt", compilerCtrlStmt.sourceRange, false)

    presentation += String(indentation: _nested+2)
    switch compilerCtrlStmt.kind {
    case .if(let condition):
      presentation += "kind: `if`, condition: `\(condition)`"
    case .elseif(let condition):
      presentation += "kind: `elseif`, condition: `\(condition)`"
    case .else:
      presentation += "kind: `else`"
    case .endif:
      presentation += "kind: `endif`"
    case let .sourceLocation(fileName, lineNumber):
      presentation += "kind: `source_location`"
      if let fileName = fileName, let lineNumber = lineNumber {
        presentation += ", file_name: `\(fileName)`, line_number: `\(lineNumber)`"
      }
    }
    presentation += "\n"

    return true
  }

  public func visit(_ continueStmt: ContinueStatement) throws -> Bool {
    append("continue_stmt", continueStmt.sourceRange)

    if let labelName = continueStmt.labelName {
      presentation += String(indentation: _nested+2)
      presentation += "label_name: `\(labelName)`\n"
    }

    return true
  }

  public func visit(_ deferStmt: DeferStatement) throws -> Bool {
    append("defer_stmt", deferStmt.sourceRange)

    return true
  }

  public func visit(_ doStmt: DoStatement) throws -> Bool {
    append("do_stmt", doStmt.sourceRange)

    return true
  }

  public func visit(_ fallthroughStmt: FallthroughStatement) throws -> Bool {
    append("fallthrough_stmt", fallthroughStmt.sourceRange)

    return true
  }

  public func visit(_ forStmt: ForInStatement) throws -> Bool {
    append("for_stmt", forStmt.sourceRange)

    return true
  }

  public func visit(_ guardStmt: GuardStatement) throws -> Bool {
    append("guard_stmt", guardStmt.sourceRange)

    return true
  }

  public func visit(_ ifStmt: IfStatement) throws -> Bool {
    append("if_stmt", ifStmt.sourceRange)

    return true
  }

  public func visit(_ labeledStmt: LabeledStatement) throws -> Bool {
    append("labeled_stmt", labeledStmt.sourceRange)

    return true
  }

  public func visit(_ repeatStmt: RepeatWhileStatement) throws -> Bool {
    append("repeat_stmt", repeatStmt.sourceRange)

    return true
  }

  public func visit(_ returnStmt: ReturnStatement) throws -> Bool {
    append("return_stmt", returnStmt.sourceRange)

    return true
  }

  public func visit(_ switchStmt: SwitchStatement) throws -> Bool {
    append("switch_stmt", switchStmt.sourceRange)

    return true
  }

  public func visit(_ throwStmt: ThrowStatement) throws -> Bool {
    append("throw_stmt", throwStmt.sourceRange)

    return true
  }

  public func visit(_ whileStmt: WhileStatement) throws -> Bool {
    append("while_stmt", whileStmt.sourceRange)

    return true
  }

  // Expressions

  public func visit(
    _ assignExpr: AssignmentOperatorExpression
  ) throws -> Bool {
    append("assign_expr", assignExpr.sourceRange)

    return true
  }

  public func visit(_ biOpExpr: BinaryOperatorExpression) throws -> Bool {
    append("binary_op_expr", biOpExpr.sourceRange)

    return true
  }

  public func visit(_ closureExpr: ClosureExpression) throws -> Bool {
    append("closure_expr", closureExpr.sourceRange)

    return true
  }

  public func visit(_ dynTypeExpr: DynamicTypeExpression) throws -> Bool {
    append("dyn_type_expr", dynTypeExpr.sourceRange)

    return true
  }

  public func visit(
    _ explicitMemberExpr: ExplicitMemberExpression
  ) throws -> Bool {
    append("explicit_member_expr", explicitMemberExpr.sourceRange)

    return true
  }

  public func visit(_ forcedValueExpr: ForcedValueExpression) throws -> Bool {
    append("forced_value_expr", forcedValueExpr.sourceRange)

    return true
  }

  public func visit(_ functionCallExpr: FunctionCallExpression) throws -> Bool {
    append("function_call_expr", functionCallExpr.sourceRange)

    return true
  }

  public func visit(_ identifierExpr: IdentifierExpression) throws -> Bool {
    append("identifier_expr", identifierExpr.sourceRange)

    return true
  }

  public func visit(
    _ implicitMemberExpr: ImplicitMemberExpression
  ) throws -> Bool {
    append("implicit_member_expr", implicitMemberExpr.sourceRange)

    return true
  }

  public func visit(_ inOutExpr: InOutExpression) throws -> Bool {
    append("in_out_expr", inOutExpr.sourceRange)

    return true
  }

  public func visit(_ initializerExpr: InitializerExpression) throws -> Bool {
    append("initializer_expr", initializerExpr.sourceRange)

    return true
  }

  public func visit(_ keyPathExpr: KeyPathExpression) throws -> Bool {
    append("keypath_expr", keyPathExpr.sourceRange)

    return true
  }

  public func visit(_ literalExpr: LiteralExpression) throws -> Bool {
    append("literal_expr", literalExpr.sourceRange)

    return true
  }

  public func visit(
    _ optionalChainingExpr: OptionalChainingExpression
  ) throws -> Bool {
    append("optional_chaining_expr", optionalChainingExpr.sourceRange)

    return true
  }

  public func visit(_ parenExpr: ParenthesizedExpression) throws -> Bool {
    append("paren_expr", parenExpr.sourceRange)

    return true
  }

  public func visit(_ postfixOpExpr: PostfixOperatorExpression) throws -> Bool {
    append("postfix_op_expr", postfixOpExpr.sourceRange)

    return true
  }

  public func visit(_ postfixSelfExpr: PostfixSelfExpression) throws -> Bool {
    append("postfix_self_expr", postfixSelfExpr.sourceRange)

    return true
  }

  public func visit(_ prefixOpExpr: PrefixOperatorExpression) throws -> Bool {
    append("prefix_op_expr", prefixOpExpr.sourceRange)

    return true
  }

  public func visit(_ selectorExpr: SelectorExpression) throws -> Bool {
    append("selector_expr", selectorExpr.sourceRange)

    return true
  }

  public func visit(_ selfExpr: SelfExpression) throws -> Bool {
    append("self_expr", selfExpr.sourceRange)

    return true
  }

  public func visit(_ subscriptExpr: SubscriptExpression) throws -> Bool {
    append("subscript_expr", subscriptExpr.sourceRange)

    return true
  }

  public func visit(_ superclassExpr: SuperclassExpression) throws -> Bool {
    append("superclass_expr", superclassExpr.sourceRange)

    return true
  }

  public func visit(
    _ ternaryCondExpr: TernaryConditionalOperatorExpression
  ) throws -> Bool {
    append("ternary_cond_expr", ternaryCondExpr.sourceRange)

    return true
  }

  public func visit(_ tryExpr: TryOperatorExpression) throws -> Bool {
    append("try_expr", tryExpr.sourceRange)

    return true
  }

  public func visit(_ tupleExpr: TupleExpression) throws -> Bool {
    append("tuple_expr", tupleExpr.sourceRange)

    return true
  }

  public func visit(
    _ typeCastingExpr: TypeCastingOperatorExpression
  ) throws -> Bool {
    append("type_casting_expr", typeCastingExpr.sourceRange)

    return true
  }

  public func visit(_ wildcardExpr: WildcardExpression) throws -> Bool {
    append("wildcard_expr", wildcardExpr.sourceRange)

    return true
  }
}
