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
    var neck = "\n" + "name: \(name)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indent
    }
    if isFinal {
      neck += "\n"
      neck += "final: `true`".indent
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indent
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types: \(typeInheritance.textDescription)".indent
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indent
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body>".indent
    } else {
      body = members.map { member -> String in
        switch member {
        case .declaration(let decl):
          return decl.ttyDump
        case .compilerControl(let stmt):
          return stmt.ttyDump
        }
      }.joined(separator: "\n").indent
    }

    return "\(head)\(neck)\n\(body)"
  }
}

extension ConstantDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("const_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indent
    }
    let body = dump(initializerList).indent
    return "\(head)\(neck)\n\(body)"
  }
}

extension DeinitializerDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("deinit_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    let bodyTTYDump = body.ttyDump.indent
    return "\(head)\(neck)\n\(bodyTTYDump)"
  }
}

extension EnumDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("enum_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indent
    }
    if isIndirect {
      neck += "\n"
      neck += "indirect: `true`".indent
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indent
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types: \(typeInheritance.textDescription)".indent
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indent
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body>".indent
    } else {
      body = members.map { member -> String in
        switch member {
        case .declaration(let decl):
          return decl.ttyDump
        case .compilerControl(let stmt):
          return stmt.ttyDump
        case .union(let unionCase):
          let caseHead = "union_case"
          var caseNeck = ""
          if !unionCase.attributes.isEmpty {
            caseNeck += "\n"
            caseNeck += "attributes: `\(unionCase.attributes.textDescription)`".indent
          }
          if unionCase.isIndirect {
            caseNeck += "\n"
            caseNeck += "indirect: `true`".indent
          }
          let caseBody: String
          switch unionCase.cases.count {
          case 0:
            caseBody = "<no_union_cases>" // Note: this should never happen
          case 1:
            let unionCaseCase = unionCase.cases[0]
            let nameDump = "name: `\(unionCaseCase.name)`"
            caseBody = unionCaseCase.tuple.map({ "\(nameDump)\ntuple: `\($0.textDescription)`" }) ?? nameDump
          default:
            caseBody = unionCase.cases.enumerated().map { (index, e) -> String in
              let nameDump = "\(index): name: `\(e.name)`"
              return e.tuple.map({ "\(nameDump), tuple: `\($0.textDescription)`" }) ?? nameDump
            }.joined(separator: "\n")
          }
          return "\(caseHead)\(caseNeck)\n\(caseBody.indent)"
        case .rawValue(let rawValueCase):
          let caseHead = "raw_value_case"
          var caseNeck = ""
          if !rawValueCase.attributes.isEmpty {
            caseNeck += "\n"
            caseNeck += "attributes: `\(rawValueCase.attributes.textDescription)`".indent
          }
          let caseBody: String
          switch rawValueCase.cases.count {
          case 0:
            caseBody = "<no_raw_value_cases>" // Note: this should never happen
          case 1:
            let rawValueCaseCase = rawValueCase.cases[0]
            let nameDump = "name: `\(rawValueCaseCase.name)`"
            caseBody = rawValueCaseCase.assignment.map({ "\(nameDump)\nraw_value: `\($0)`" }) ?? nameDump
          default:
            caseBody = rawValueCase.cases.enumerated().map { (index, e) -> String in
              let nameDump = "\(index): name: `\(e.name)`"
              return e.assignment.map({ "\(nameDump), raw_value: `\($0)`" }) ?? nameDump
            }.joined(separator: "\n")
          }
          return "\(caseHead)\(caseNeck)\n\(caseBody.indent)"
        }
      }.joined(separator: "\n").indent
    }

    return "\(head)\(neck)\n\(body)"

    // TODO: some of these `ttyDump` implementations require serious refactorings
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
