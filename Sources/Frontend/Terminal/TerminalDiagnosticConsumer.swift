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

import Foundation
import Diagnostic
import Source

struct TerminalDiagnosticConsumer : DiagnosticConsumer {
  func consume(diagnostics: [Diagnostic]) {
    var cachedContent: [String: String] = [:]

    for d in diagnostics {
      let levelStr: String
      switch d.level {
      case .fatal, .error:
        levelStr = d.level.rawValue.colored(with: .red)
      case .warning:
        levelStr = d.level.rawValue.colored(with: .yellow)
      }
      print("\(d.location) \(levelStr): \(d.kind.diagnosticMessage)")

      let filePath = d.location.path
      var fileContent = cachedContent[filePath]
      if fileContent == nil {
        fileContent = (try? SourceReader.read(at: filePath))?.content
      }
      if let fileContent = fileContent {
        cachedContent[filePath] = fileContent
        let lines = fileContent.components(separatedBy: .newlines)
        var lineNum = d.location.line - 1
        if lineNum < 0 {
          lineNum = 0
        }
        if lineNum < lines.count {
          print(lines[lineNum])
          var paddingNum = d.location.column - 1
          if paddingNum < 0 {
            paddingNum = 0
          }
          let padding = String(repeating: " ", count: paddingNum)
          let pointer = padding + "^~~~".colored(with: .green)
          print(pointer)
        }
      }

      print()
    }
  }
}
