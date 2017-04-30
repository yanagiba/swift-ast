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
    return statements.map { $0.ttyDump }.joined(separator: "\n")
  }
}

// extension ImportDeclaration : TTYASTDumpDeclaration {
//   func ttyDeclarationDump(indentation: Int) -> String {
//     return String(indentation: indentation) +
//       "(".colored(with: .blue) +
//       "import_decl".colored(with: .magenta) +
//       " " +
//       "<range: \(sourceRange)>".colored(with: .yellow) +
//       " " +
//       (attributes.isEmpty ? "" : "\(attributes.textDescription) ") +
//       (kind.map({ " \($0.rawValue)" }) ?? "") +
//       path.joined(separator: ".").colored(with: .yellow) +
//       ")".colored(with: .blue)
//   }
// }
