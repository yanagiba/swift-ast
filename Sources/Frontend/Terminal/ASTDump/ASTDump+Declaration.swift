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
      neck += "parent_types\(typeInheritance.textDescription)".indent
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
      neck += "parent_types\(typeInheritance.textDescription)".indent
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
    var neck = "\n" + "type: \(type.textDescription)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indent
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indent
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

extension FunctionDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("func_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indent
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indent
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indent
    }
    let signatureDump = dump(signature)
    if !signatureDump.isEmpty {
      neck += "\n" + signatureDump.indent
    }
    let bodyTTYDump = body?.ttyDump ?? "<func_def_only>"
    return "\(head)\(neck)\n\(bodyTTYDump.indent)"
  }
}

extension ImportDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("import_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let kind = kind {
      neck += "\n"
      neck += "kind: `\(kind)`".indent
    }
    let body = "path:\n" + path.enumerated().map { "\($0): `\($1)`" }.joined(separator: "\n")
    return "\(head)\(neck)\n\(body.indent)"
  }
}

extension InitializerDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("init_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indent
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indent
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indent
    }
    neck += "\n" + "kind: ".indent
    switch kind {
    case .nonfailable:
      neck += "`non_failable`"
    case .optionalFailable:
      neck += "`optional_failable`"
    case .implicitlyUnwrappedFailable:
      neck += "`implicit_unwrapped_failable`"
    }
    if !parameterList.isEmpty {
      neck += "\n" + dump(parameterList).indent
    }
    let bodyTTYDump = body.ttyDump.indent
    return "\(head)\(neck)\n\(bodyTTYDump)"
  }
}

extension OperatorDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("op_decl", sourceRange)
    let body: String
    switch kind {
    case .prefix(let op):
      body = "kind: `prefix`, operator: `\(op)`"
    case .postfix(let op):
      body = "kind: `postfix`, operator: `\(op)`"
    case .infix(let op, nil):
      body = "kind: `infix`, operator: `\(op)`"
    case .infix(let op, let id?):
      body = "kind: `infix`, operator: `\(op)`, precedence_group_name: `\(id)`"
    }
    return "\(head)\n\(body.indent)"
  }
}

extension PrecedenceGroupDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    func dumpAttr(_ attr: PrecedenceGroupDeclaration.Attribute) -> String {
      switch attr {
      case .higherThan(let ids):
        return "higherThan: `\(ids.textDescription)`"
      case .lowerThan(let ids):
        return "lowerThan: `\(ids.textDescription)`"
      case .assignment(let b):
        let boolText = b ? "`true`" : "`false`"
        return "assignment: \(boolText)"
      case .associativityLeft:
        return "associativity: `left`"
      case .associativityRight:
        return "associativity: `right`"
      case .associativityNone:
        return "associativity: `none`"
      }
    }

    let head = dump("precedence_group_decl", sourceRange)
    let neck = "name: \(name)".indent
    let body: String
    switch attributes.count {
    case 0:
      body = "<no_attributes>"
    case 1:
      body = dumpAttr(attributes[0])
    default:
      body = "attributes:\n" + attributes.enumerated()
        .map { "\($0): \(dumpAttr($1))" }
        .joined(separator: "\n")
    }
    return "\(head)\n\(neck)\n\(body.indent)"
  }
}

extension ProtocolDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("proto_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indent
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indent
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body_block>"
    } else {
      body = members.enumerated()
        .map { index, m -> String in
          var memberDump = "\(index): "
          switch m {
          case .property(let member):
            memberDump += "kind: `property`\n"
            memberDump += "name: \(name)".indent
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indent
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indent
            }
            memberDump += "\n"
            memberDump += "type\(member.typeAnnotation.textDescription)".indent
            memberDump += "\n" + dump(member.getterSetterKeywordBlock).indent
          case .method(let member):
            memberDump += "kind: `method`\n"
            memberDump += "name: \(name)".indent
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indent
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indent
            }
            if let genericParam = member.genericParameter {
              memberDump += "\n"
              memberDump += "generic_param: `\(genericParam.textDescription)`".indent
            }
            if let genericWhere = member.genericWhere {
              memberDump += "\n"
              memberDump += "generic_where: `\(genericWhere.textDescription)`".indent
            }
            let signatureDump = dump(member.signature)
            if !signatureDump.isEmpty {
              memberDump += "\n" + signatureDump.indent
            }
          case .initializer(let member):
            memberDump += "kind: "
            switch member.kind {
            case .nonfailable:
              memberDump += "`non_failable_initializer`"
            case .optionalFailable:
              memberDump += "`optional_failable_initializer`"
            case .implicitlyUnwrappedFailable:
              memberDump += "`implicit_unwrapped_failable_initializer`"
            }
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indent
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indent
            }
            if let genericParam = member.genericParameter {
              memberDump += "\n"
              memberDump += "generic_param: `\(genericParam.textDescription)`".indent
            }
            if let genericWhere = member.genericWhere {
              memberDump += "\n"
              memberDump += "generic_where: `\(genericWhere.textDescription)`".indent
            }
            if !member.parameterList.isEmpty {
              memberDump += "\n" + dump(member.parameterList).indent
            }
            if member.throwsKind != .nothrowing {
              memberDump += "\n" + "throws_kind: `\(member.throwsKind.textDescription)`".indent
            }
          case .subscript(let member):
            memberDump += "kind: `subscript`"
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indent
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indent
            }
            if !member.parameterList.isEmpty {
              memberDump += "\n" + dump(member.parameterList).indent
            }
            memberDump += "\n"
            memberDump += "type: \(member.resultType.textDescription)".indent
            if !member.resultAttributes.isEmpty {
              memberDump += "\n"
              memberDump += "result_attributes: `\(member.resultAttributes.textDescription)`".indent
            }
            memberDump += "\n" + dump(member.getterSetterKeywordBlock).indent
          case .associatedType(let member):
            memberDump += "kind: `associated_type`\n"
            memberDump += "name: \(name)".indent
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indent
            }
            if let accessLevel = member.accessLevelModifier {
              memberDump += "\n"
              memberDump += "access_level: \(accessLevel.textDescription)".indent
            }
            if let typeInheritance = member.typeInheritance {
              memberDump += "\n"
              memberDump += "parent_types\(typeInheritance.textDescription)".indent
            }
            if let assignmentType = member.assignmentType {
              memberDump += "\n"
              memberDump += "assignment_type: \(assignmentType.textDescription)".indent
            }
          case .compilerControl(let stmt):
            memberDump += "kind: `compiler_control`\n"
            memberDump += stmt.ttyDump.indent
          }
          return memberDump
        }
        .joined(separator: "\n")
    }
    return "\(head)\(neck)\n\(body.indent)"
  }
}

extension StructDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("struct_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indent
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indent
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indent
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

extension SubscriptDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("subscript_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indent
    }
    if !parameterList.isEmpty {
      neck += "\n" + dump(parameterList).indent
    }
    neck += "\n"
    neck += "type: \(resultType.textDescription)".indent
    if !resultAttributes.isEmpty {
      neck += "\n"
      neck += "result_attributes: `\(resultAttributes.textDescription)`".indent
    }
    let bodyTTYDump: String
    switch body {
    case .codeBlock(let block):
      bodyTTYDump = block.ttyDump
    case .getterSetterBlock(let block):
      bodyTTYDump = dump(block)
    case .getterSetterKeywordBlock(let block):
      bodyTTYDump = dump(block)
    }
    return "\(head)\(neck)\n\(bodyTTYDump.indent)"
  }
}

extension TypealiasDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("typealias_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indent
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indent
    }
    if let genericParam = generic {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indent
    }
    neck += "\n"
    neck += "type: \(assignment.textDescription)".indent
    return "\(head)\(neck)"
  }
}

extension VariableDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("var_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indent
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indent
    }
    let bodyTTYDump: String
    switch body {
    case .initializerList(let inits):
      bodyTTYDump = dump(inits)
    case let .codeBlock(name, typeAnnotation, codeBlock):
      bodyTTYDump = "name: \(name)\ntype\(typeAnnotation)\n\(codeBlock.ttyDump)"
    case let .getterSetterBlock(name, typeAnnotation, block):
      bodyTTYDump = "name: \(name)\ntype\(typeAnnotation)\n\(dump(block))"
    case let .getterSetterKeywordBlock(name, typeAnnotation, block):
      bodyTTYDump = "name: \(name)\ntype\(typeAnnotation)\n\(dump(block))"
    case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
      var blockDump = "name: \(name)"
      if let typeAnnotation = typeAnnotation {
        blockDump += "\ntype\(typeAnnotation)"
      }
      if let initExpr = initExpr {
        blockDump += "\ninit_expr: \(initExpr.ttyDump)"
      }

      blockDump += "\nwill_set_did_set_block:"
      if let willSetClause = block.willSetClause {
        blockDump += "\n" + "will_set".indent
        if let setterName = willSetClause.name {
          blockDump += ", name: `\(setterName)`"
        }
        if !willSetClause.attributes.isEmpty {
          blockDump += ", attributes: `\(willSetClause.attributes.textDescription)`"
        }
        blockDump += "\n"
        blockDump += willSetClause.codeBlock.ttyDump.indent.indent
      }
      if let didSetClause = block.didSetClause {
        blockDump += "\n" + "did_set".indent
        if let setterName = didSetClause.name {
          blockDump += ", name: `\(setterName)`"
        }
        if !didSetClause.attributes.isEmpty {
          blockDump += ", attributes: `\(didSetClause.attributes.textDescription)`"
        }
        blockDump += "\n"
        blockDump += didSetClause.codeBlock.ttyDump.indent.indent
      }
      bodyTTYDump = blockDump
    }
    return "\(head)\(neck)\n\(bodyTTYDump.indent)"
  }
}
