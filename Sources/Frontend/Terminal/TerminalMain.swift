/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
import Parser
import Source
import Diagnostic

public enum TTYType {
  case astDump
  case astPrint
  case astText
  case diagnosticsOnly
}

public func terminalMain(
  filePaths: [String], ttyType: TTYType = .astText
) -> Int32 {
  for filePath in filePaths {
    let pathCharCount = filePath.characters.count
    let separator = String(repeating: "=", count: pathCharCount)
    print(separator.colored(with: .red))
    print(filePath)
    print(separator.colored(with: .blue))
    guard let sourceFile = try? SourceReader.read(at: filePath) else {
      print("Can't read file")
      return -1
    }
    let diagnosticConsumer = TerminalDiagnosticConsumer()
    let parser = Parser(source: sourceFile)
    guard let result = try? parser.parse() else {
      DiagnosticPool.shared.report(withConsumer: diagnosticConsumer)
      return -2
    }
    DiagnosticPool.shared.report(withConsumer: diagnosticConsumer)
    switch ttyType {
    case .astDump:
      print(result.ttyASTDump(indentation: 0))
    case .astPrint:
      print(result.ttyASTPrint(indentation: 0))
    case .astText:
      print(result.textDescription)
    case .diagnosticsOnly:
      print()
    }
  }

  return 0
}
