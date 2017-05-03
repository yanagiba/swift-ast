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

extension TopLevelDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("top_level_decl", sourceRange)
    let body = statements.map { $0.ttyDump.indent }
    let tail = ""
    return ([head] + body + [tail]).joined(separator: "\n")
  }
}

extension CodeBlock : TTYASTDumpRepresentable {
  var ttyDump: String {
    if statements.isEmpty {
      return "<empty_code_block>"
    }
    return statements.map { $0.ttyDump }.joined(separator: "\n")
  }
}

extension ClassDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("class_decl", sourceRange)

    let body = members.map { member -> String in
      switch member {
      case .declaration(let decl):
        return decl.ttyDump
      case .compilerControl(let stmt):
        return stmt.ttyDump
      }
    }.joined(separator: "\n").indent

    return "\(head)\n\(body)"
  }
}

extension ConstantDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("const_decl", sourceRange)

    // for initializer in constDecl.initializerList {
    //   if let expr = initializer.initializerExpression {
    //     guard try traverse(expr) else { return faldump
    //     }
    //   }
    // }

    return head
  }
}

extension DeinitializerDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("deinit_decl", sourceRange)
    let bodyTTYDump = body.ttyDump.indent
    return "\(head)\n\(bodyTTYDump)"
  }
}

extension EnumDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("enum_decl", sourceRange)

    // for member in enumDecl.members {
    //   switch member {
    //   case .declaration(let decl):
    //     _ = try traverse(decl)
    //   case .compilerControl(let stmt):
    //     _ = try traverse(stmt)
    //   case .union:
    //     presentation += String(indentation: _nested)
    //     presentation += "<union_case> TODO" + "\n"
    //   case .rawValue:
    //     presentation += String(indentation: _nested)
    //     presentation += "<raw_value_case> TODO" + "\n"
    //   }
    // }

    return head
  }
}

extension ExtensionDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("ext_decl", sourceRange)

    let body = members.map { member -> String in
      switch member {
      case .declaration(let decl):
        return decl.ttyDump
      case .compilerControl(let stmt):
        return stmt.ttyDump
      }
    }.joined(separator: "\n").indent

    return "\(head)\n\(body)"
  }
}

extension FunctionDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("func_decl", sourceRange)

    let bodyTTYDump = body?.ttyDump.indent ?? ""
    return "\(head)\n\(bodyTTYDump)"
  }
}

extension ImportDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("import_decl", sourceRange)

    return head
  }
}

extension InitializerDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("init_decl", sourceRange)
    let bodyTTYDump = body.ttyDump.indent
    return "\(head)\n\(bodyTTYDump)"
  }
}

extension OperatorDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("op_decl", sourceRange)

    return head
  }
}

extension PrecedenceGroupDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("precedence_group_decl", sourceRange)

    return head
  }
}

extension ProtocolDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("proto_decl", sourceRange)

    /*
    for member in protoDecl.members {
      presentation += String(indentation: _nested)
      presentation += "<protocol_decl_member> TODO" + "\n"
      // switch member {
      // case .method(let method):
      //   for param in method.signature.parameterList {
      //     if let defaultArg = param.defaultArgumentClause {
      //       guard try traverse(defaultArg) else { return faldump
      }
      //     }
      //   }
      // case .initializer(let initializer):
      //   for param in initializer.parameterList {
      //     if let defaultArg = param.defaultArgumentClause {
      //       guard try traverse(defaultArg) else { return faldump
      }
      //     }
      //   }
      // case .subscript(let member):
      //   for param in member.parameterList {
      //     if let defaultArg = param.defaultArgumentClause {
      //       guard try traverse(defaultArg) else { return faldump
      }
      //     }
      //   }
      // case .compilerControl(let stmt):
      //   guard try traverse(stmt) else { return faldump
      }
      // default:
      //   continue
      // }
    }
    */

    return head
  }
}

extension StructDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("struct_decl", sourceRange)

    let body = members.map { member -> String in
      switch member {
      case .declaration(let decl):
        return decl.ttyDump
      case .compilerControl(let stmt):
        return stmt.ttyDump
      }
    }.joined(separator: "\n").indent

    return "\(head)\n\(body)"
  }
}

extension SubscriptDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("subscript_decl", sourceRange)

    // TODO: handle block properly

    return head
  }
}

extension TypealiasDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("typealias_decl", sourceRange)

    return head
  }
}

extension VariableDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("var_decl", sourceRange)

    // TODO: handle block properly

    return head
  }
}
