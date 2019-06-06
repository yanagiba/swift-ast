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

import AST
import Bocho

extension TopLevelDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    var firstLine: [String] = []
    if let interpreterDirective = shebang?.interpreterDirective {
      firstLine.append("shebang `\(interpreterDirective)`")
    }
    let head = dump("top_level_decl", sourceRange)
    let body = statements.map { $0.ttyDump.indented }
    let tail = ""
    return (firstLine + [head] + body + [tail]).joined(separator: "\n")
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
    var neck = "\n" + "name: \(name)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indented
    }
    if isFinal {
      neck += "\n"
      neck += "final: `true`".indented
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body>".indented
    } else {
      body = members.map { member -> String in
        switch member {
        case .declaration(let decl):
          return decl.ttyDump
        case .compilerControl(let stmt):
          return stmt.ttyDump
        }
      }.joined(separator: "\n").indented
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
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indented
    }
    let body = dump(initializerList).indented
    return "\(head)\(neck)\n\(body)"
  }
}

extension DeinitializerDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("deinit_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    let bodyTTYDump = body.ttyDump.indented
    return "\(head)\(neck)\n\(bodyTTYDump)"
  }
}

extension EnumDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String { // swift-lint:suppress(nested_code_block_depth)
    // TODO: some of these `ttyDump` implementations require serious refactorings

    let head = dump("enum_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indented
    }
    if isIndirect {
      neck += "\n"
      neck += "indirect: `true`".indented
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body>".indented
    } else { // swift-lint:suppress(nested_code_block_depth)
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
            caseNeck += "attributes: `\(unionCase.attributes.textDescription)`".indented
          }
          if unionCase.isIndirect {
            caseNeck += "\n"
            caseNeck += "indirect: `true`".indented
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
            caseBody = unionCase.cases.enumerated().map { e -> String in
              let nameDump = "\(e.offset): name: `\(e.element.name)`"
              return e.element.tuple.map({ "\(nameDump), tuple: `\($0.textDescription)`" }) ?? nameDump
            }.joined(separator: "\n")
          }
          return "\(caseHead)\(caseNeck)\n\(caseBody.indented)"
        case .rawValue(let rawValueCase):
          let caseHead = "raw_value_case"
          var caseNeck = ""
          if !rawValueCase.attributes.isEmpty {
            caseNeck += "\n"
            caseNeck += "attributes: `\(rawValueCase.attributes.textDescription)`".indented
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
            caseBody = rawValueCase.cases.enumerated().map { e -> String in
              let nameDump = "\(e.offset): name: `\(e.element.name)`"
              return e.element.assignment.map({ "\(nameDump), raw_value: `\($0)`" }) ?? nameDump
            }.joined(separator: "\n")
          }
          return "\(caseHead)\(caseNeck)\n\(caseBody.indented)"
        }
      }.joined(separator: "\n").indented
    }

    return "\(head)\(neck)\n\(body)"
  }
}

extension ExtensionDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("ext_decl", sourceRange)
    var neck = "\n" + "type: \(type.textDescription)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indented
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body>".indented
    } else {
      body = members.map { member -> String in
        switch member {
        case .declaration(let decl):
          return decl.ttyDump
        case .compilerControl(let stmt):
          return stmt.ttyDump
        }
      }.joined(separator: "\n").indented
    }

    return "\(head)\(neck)\n\(body)"
  }
}

extension FunctionDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("func_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indented
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
    }
    let signatureDump = dump(signature)
    if !signatureDump.isEmpty {
      neck += "\n" + signatureDump.indented
    }
    let bodyTTYDump = body?.ttyDump ?? "<func_def_only>"
    return "\(head)\(neck)\n\(bodyTTYDump.indented)"
  }
}

extension ImportDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("import_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let kind = kind {
      neck += "\n"
      neck += "kind: `\(kind)`".indented
    }
    let body = "path:\n" + path.enumerated().map { "\($0.0): `\($0.1)`" }.joined(separator: "\n")
    return "\(head)\(neck)\n\(body.indented)"
  }
}

extension InitializerDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("init_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indented
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
    }
    neck += "\n" + "kind: ".indented
    switch kind {
    case .nonfailable:
      neck += "`non_failable`"
    case .optionalFailable:
      neck += "`optional_failable`"
    case .implicitlyUnwrappedFailable:
      neck += "`implicit_unwrapped_failable`"
    }
    if !parameterList.isEmpty {
      neck += "\n" + dump(parameterList).indented
    }
    let bodyTTYDump = body.ttyDump.indented
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
    return "\(head)\n\(body.indented)"
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
    let neck = "name: \(name)".indented
    let body: String
    switch attributes.count {
    case 0:
      body = "<no_attributes>"
    case 1:
      body = dumpAttr(attributes[0])
    default:
      body = "attributes:\n" + attributes.enumerated()
        .map { "\($0.offset): \(dumpAttr($0.element))" }
        .joined(separator: "\n")
    }
    return "\(head)\n\(neck)\n\(body.indented)"
  }
}

extension ProtocolDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("proto_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indented
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indented
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body_block>"
    } else {
      body = members.enumerated()
        .map { e -> String in
          var memberDump = "\(e.offset): "
          switch e.element {
          case .property(let member):
            memberDump += "kind: `property`\n"
            memberDump += "name: \(name)".indented
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indented
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indented
            }
            memberDump += "\n"
            memberDump += "type\(member.typeAnnotation.textDescription)".indented
            memberDump += "\n" + dump(member.getterSetterKeywordBlock).indented
          case .method(let member):
            memberDump += "kind: `method`\n"
            memberDump += "name: \(name)".indented
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indented
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indented
            }
            if let genericParam = member.genericParameter {
              memberDump += "\n"
              memberDump += "generic_param: `\(genericParam.textDescription)`".indented
            }
            if let genericWhere = member.genericWhere {
              memberDump += "\n"
              memberDump += "generic_where: `\(genericWhere.textDescription)`".indented
            }
            let signatureDump = dump(member.signature)
            if !signatureDump.isEmpty {
              memberDump += "\n" + signatureDump.indented
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
              memberDump += "attributes: `\(member.attributes.textDescription)`".indented
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indented
            }
            if let genericParam = member.genericParameter {
              memberDump += "\n"
              memberDump += "generic_param: `\(genericParam.textDescription)`".indented
            }
            if let genericWhere = member.genericWhere {
              memberDump += "\n"
              memberDump += "generic_where: `\(genericWhere.textDescription)`".indented
            }
            if !member.parameterList.isEmpty {
              memberDump += "\n" + dump(member.parameterList).indented
            }
            if member.throwsKind != .nothrowing {
              memberDump += "\n" + "throws_kind: `\(member.throwsKind.textDescription)`".indented
            }
          case .subscript(let member):
            memberDump += "kind: `subscript`"
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indented
            }
            if !member.modifiers.isEmpty {
              memberDump += "\n"
              memberDump += "modifiers: \(member.modifiers.textDescription)".indented
            }
            if !member.parameterList.isEmpty {
              memberDump += "\n" + dump(member.parameterList).indented
            }
            memberDump += "\n"
            memberDump += "type: \(member.resultType.textDescription)".indented
            if !member.resultAttributes.isEmpty {
              memberDump += "\n"
              memberDump += "result_attributes: `\(member.resultAttributes.textDescription)`".indented
            }
            if let genericParam = member.genericParameter {
              memberDump += "\n"
              memberDump += "generic_param: `\(genericParam.textDescription)`".indented
            }
            if let genericWhere = member.genericWhere {
              memberDump += "\n"
              memberDump += "generic_where: `\(genericWhere.textDescription)`".indented
            }
            memberDump += "\n" + dump(member.getterSetterKeywordBlock).indented
          case .associatedType(let member):
            memberDump += "kind: `associated_type`\n"
            memberDump += "name: \(name)".indented
            if !member.attributes.isEmpty {
              memberDump += "\n"
              memberDump += "attributes: `\(member.attributes.textDescription)`".indented
            }
            if let accessLevel = member.accessLevelModifier {
              memberDump += "\n"
              memberDump += "access_level: \(accessLevel.textDescription)".indented
            }
            if let typeInheritance = member.typeInheritance {
              memberDump += "\n"
              memberDump += "parent_types\(typeInheritance.textDescription)".indented
            }
            if let assignmentType = member.assignmentType {
              memberDump += "\n"
              memberDump += "assignment_type: \(assignmentType.textDescription)".indented
            }
            if let genericWhere = member.genericWhere {
              memberDump += "\n"
              memberDump += "generic_where: `\(genericWhere.textDescription)`".indented
            }
          case .compilerControl(let stmt):
            memberDump += "kind: `compiler_control`\n"
            memberDump += stmt.ttyDump.indented
          }
          return memberDump
        }
        .joined(separator: "\n")
    }
    return "\(head)\(neck)\n\(body.indented)"
  }
}

extension StructDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("struct_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indented
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    if let typeInheritance = typeInheritanceClause {
      neck += "\n"
      neck += "parent_types\(typeInheritance.textDescription)".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
    }
    let body: String
    if members.isEmpty {
      body = "<empty_body>".indented
    } else {
      body = members.map { member -> String in
        switch member {
        case .declaration(let decl):
          return decl.ttyDump
        case .compilerControl(let stmt):
          return stmt.ttyDump
        }
      }.joined(separator: "\n").indented
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
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indented
    }
    if !parameterList.isEmpty {
      neck += "\n" + dump(parameterList).indented
    }
    neck += "\n"
    neck += "type: \(resultType.textDescription)".indented
    if !resultAttributes.isEmpty {
      neck += "\n"
      neck += "result_attributes: `\(resultAttributes.textDescription)`".indented
    }
    if let genericParam = genericParameterClause {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    if let genericWhere = genericWhereClause {
      neck += "\n"
      neck += "generic_where: `\(genericWhere.textDescription)`".indented
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
    return "\(head)\(neck)\n\(bodyTTYDump.indented)"
  }
}

extension TypealiasDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("typealias_decl", sourceRange)
    var neck = "\n" + "name: \(name)".indented
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if let accessLevel = accessLevelModifier {
      neck += "\n"
      neck += "access_level: \(accessLevel)".indented
    }
    if let genericParam = generic {
      neck += "\n"
      neck += "generic_param: `\(genericParam.textDescription)`".indented
    }
    neck += "\n"
    neck += "type: \(assignment.textDescription)".indented
    return "\(head)\(neck)"
  }
}

extension VariableDeclaration : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("var_decl", sourceRange)
    var neck = ""
    if !attributes.isEmpty {
      neck += "\n"
      neck += "attributes: `\(attributes.textDescription)`".indented
    }
    if !modifiers.isEmpty {
      neck += "\n"
      neck += "modifiers: \(modifiers.textDescription)".indented
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
        blockDump += "\n" + "will_set".indented
        if let setterName = willSetClause.name {
          blockDump += ", name: `\(setterName)`"
        }
        if !willSetClause.attributes.isEmpty {
          blockDump += ", attributes: `\(willSetClause.attributes.textDescription)`"
        }
        blockDump += "\n"
        blockDump += willSetClause.codeBlock.ttyDump.indented.indented
      }
      if let didSetClause = block.didSetClause {
        blockDump += "\n" + "did_set".indented
        if let setterName = didSetClause.name {
          blockDump += ", name: `\(setterName)`"
        }
        if !didSetClause.attributes.isEmpty {
          blockDump += ", attributes: `\(didSetClause.attributes.textDescription)`"
        }
        blockDump += "\n"
        blockDump += didSetClause.codeBlock.ttyDump.indented.indented
      }
      bodyTTYDump = blockDump
    }
    return "\(head)\(neck)\n\(bodyTTYDump.indented)"
  }
}
