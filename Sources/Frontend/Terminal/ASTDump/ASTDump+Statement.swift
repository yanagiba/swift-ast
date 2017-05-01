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

extension Statement {
  var ttyDump: String {
    switch self {
    case let ttyAstDumpRepresentable as TTYASTDumpRepresentable:
      return ttyAstDumpRepresentable.ttyDump
    default:
      return "(".colored(with: .blue) +
        "unknown".colored(with: .red) +
        ")".colored(with: .blue) +
        " " +
        "<range: \(sourceRange.ttyDescription)>".colored(with: .yellow)
    }
  }
}

extension BreakStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("break_stmt", sourceRange)
    let body = labelName.map { ["label_name: `\($0)`".indent] } ?? []
    return ([head] + body).joined(separator: "\n")
  }
}

extension CompilerControlStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("compiler_ctrl_stmt", sourceRange)
    var body = String.indent
    switch kind {
    case .if(let condition):
      body += "kind: `if`, condition: `\(condition)`"
    case .elseif(let condition):
      body += "kind: `elseif`, condition: `\(condition)`"
    case .else:
      body += "kind: `else`"
    case .endif:
      body += "kind: `endif`"
    case let .sourceLocation(fileName, lineNumber):
      body += "kind: `source_location`"
      if let fileName = fileName, let lineNumber = lineNumber {
        body += ", file_name: `\(fileName)`, line_number: `\(lineNumber)`"
      }
    }
    return "\(head)\n\(body)"
  }
}

extension ContinueStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("continue_stmt", sourceRange)
    let body = labelName.map { ["label_name: `\($0)`".indent] } ?? []
    return ([head] + body).joined(separator: "\n")
  }
}

extension DeferStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    let head = dump("defer_stmt", sourceRange)
    let body = codeBlock.ttyDump.indent
    return "\(head)\n\(body)"
  }
}

extension DoStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("do_stmt", sourceRange)
  }
}

extension FallthroughStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("fallthrough_stmt", sourceRange)
  }
}

extension ForInStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("for_stmt", sourceRange)
  }
}

extension GuardStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("guard_stmt", sourceRange)
  }
}

extension IfStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("if_stmt", sourceRange)
  }
}

extension LabeledStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("labeled_stmt", sourceRange)
  }
}

extension RepeatWhileStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("repeat_stmt", sourceRange)
  }
}

extension ReturnStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("return_stmt", sourceRange)
  }
}

extension SwitchStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("switch_stmt", sourceRange)
  }
}

extension ThrowStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("throw_stmt", sourceRange)
  }
}

extension WhileStatement : TTYASTDumpRepresentable {
  var ttyDump: String {
    return dump("while_stmt", sourceRange)
  }
}
