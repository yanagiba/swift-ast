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

extension Collection where Iterator.Element == Statement {
  func ttyASTDump(indentation: Int) -> String {
    return self.map({ $0.ttyASTDump(indentation: indentation) }).joined(separator: "\n")
  }
}

extension Statement {
  func ttyASTDump(indentation: Int) -> String {
    switch self {
    case let representable as TTYASTDumpRepresentable:
      return representable.ttyASTDump(indentation: indentation)
    default:
      return String(indentation: indentation) + textDescription
    }
  }
}
