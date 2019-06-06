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

import Foundation
import Bocho
import AST
import Parser
import Source
import Diagnostic

func runGitHubIssueGen(for filePaths: [String]) -> Int32 {
  guard filePaths.count == 1 else {
    print("""
    ⛔️
    You provide \(filePaths.count) files for GitHub issue generation.
    Please run GitHub issue model once for each file respectively.
    """)
    return 0
  }

  let outputPath = "swift-ast_github_issue_\(getCurrentDateString()).md"

  let filePath = filePaths[0]
  var sourceFile: SourceFile?
  do {
    let source = try SourceReader.read(at: filePath)
    sourceFile = source

    DiagnosticPool.shared.clear()
    let parser = Parser(source: source)
    _ = try parser.parse()

    print("""
    🙈
    Don't see any problems here.
    """)
  } catch SourceError.cannotReadFile(let absolutePath) {
    let content = genForFilePathIssues(
      filePath: filePath, absolutePath: absolutePath)
    flush(content, to: outputPath)
  } catch {
    let diagnosticExtractor = DiagnosticExtractor()
    DiagnosticPool.shared.report(withConsumer: diagnosticExtractor)
    let diagnostics = diagnosticExtractor.diagnostics
    let content = genForParserError(
      sourceFile: sourceFile, diagnostics: diagnostics
    )
    flush(content, to: outputPath)
  }

  return 0
}

private class DiagnosticExtractor : DiagnosticConsumer {
  var diagnostics: [Diagnostic] = []

  func consume(diagnostics: [Diagnostic]) {
    self.diagnostics = diagnostics
  }
}

private func getCurrentDateString() -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "en_US")
  dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
  return dateFormatter.string(from: Date())
}

private func flush(_ content: String, to path: String) {
  do {
    try content.write(toFile: path, atomically: false, encoding: .utf8)

    print("""
    🎉
    Please copy the content from
    \(path.colored(with: .yellow))
    and submit a GitHub issue
    Please \("censor".colored(with: .red)) its content by following Code of Conduct
    (http://contributor-covenant.org/version/1/4/)
    """)
  }
  catch {
    print("""
    🤦
    Couldn't save to the file, so I am going to dump the content to the console:
    \("------".colored(with: .yellow))
    \(content)
    \("------".colored(with: .yellow))
    """)
  }
}

private func getOSInfo() -> String {
#if os(macOS)
  let osName = "macOS "
#elseif os(Linux)
  let osName = "Linux "
#else
  let osName = ""
#endif
  return "\(osName)\(ProcessInfo.processInfo.operatingSystemVersionString)"
}

private func genForFilePathIssues(
  filePath: String, absolutePath: String
) -> String {
  return """
  ### Issue Summary
  [Insert a brief but thorough description of the issue]

  I tried to invoke `swift-ast` with the command:
  `swift-ast \(filePath)`

  And it interprets the path and converts it to:
  `\(absolutePath)`

  Then `swift-ast` couldn't read from that path.

  ### Environment
  - OS Info: \(getOSInfo())
  - Yanagiba/swift-ast version: \(Version.current.library)

  """
}

private func genForParserError(
  sourceFile: SourceFile?, diagnostics: [Diagnostic]
) -> String {
  let sourceContent = sourceFile?.content ?? "[Insert the source content here]"
  let command = (sourceFile?.identifier).map({ "`swift-ast \($0)`" }) ?? "[Insert the command]"
  let diagnosticMessages = diagnostics
    .map({ "\($0.location) \($0.level): \($0.kind)" })
    .joined(separator: "\n")

  return """
  ### Issue Summary
  [A brief but thorough description of the issue]

  ### Environment
  - OS Info: \(getOSInfo())
  - Yanagiba/swift-ast version: \(Version.current.library)

  ### Reproduction Steps
  [Detailed steps to reproduce the issue.]

  <details>
  <summary>Sample code</summary>

  ```
  \(sourceContent)
  ```

  Command to run `swift-ast` with the code above:
  \(command)

  </details>

  ### Expected Result
  What do you expect to happen as a result of the reproduction steps?

  ### Actual Behavior
  What currently happens as a result of the reproduction steps?

  ```
  \(diagnosticMessages)
  ```

  ### Even Better
  Is your project open sourced? If yes, can you point us to your repository?
  If not, is it possible to make a small project that fails the Travis CI?
  If not, can you create a gist with your sample code for us?
  """
}
