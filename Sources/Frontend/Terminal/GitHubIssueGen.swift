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
import AST
import Parser
import Source
import Diagnostic

func runGitHubIssueGen(for filePaths: [String]) -> Int32 {
  guard filePaths.count == 1 else {
    print("⛔️")
    print("You provide \(filePaths.count) files for GitHub issue generation.")
    print("Please run GitHub issue model once for each file respectively.")
    return 0
  }

  let outputPath = "swift-ast_github_issue_\(getCurrentDateString()).md"

  let filePath = filePaths[0]
  do {
    let sourceFile = try SourceReader.read(at: filePath)
    print("🙈")
    print("Don't see any problems here.")
  } catch SourceError.cannotReadFile(let absolutePath) {
    let content = genForFilePathIssues(
      filePath: filePath, absolutePath: absolutePath)
    flush(content, to: outputPath)
  } catch {

  }

  return 0
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

    print("🎉")
    print("Please copy the content from")
    print(path.colored(with: .yellow))
    print("and submit a GitHub issue")
    print("Please \("censor".colored(with: .red)) its content by following Code of Conduct")
    print("(http://contributor-covenant.org/version/1/4/)")
  }
  catch {
    print("🤦")
    print("Couldn't save to the file, so I am going to dump the content to the console:")
    print("------".colored(with: .yellow))
    print(content)
    print("------".colored(with: .yellow))
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
  var content = ""
  content += "### Issue Summary\n"
  content += "[Insert a brief but thorough description of the issue]\n"
  content += "\n"
  content += "I tried to invoke `swift-ast` with the command:\n"
  content += "`swift-ast \(filePath)`\n"
  content += "\n"
  content += "And it interprets the path and converts it to:\n"
  content += "`\(absolutePath)`\n"
  content += "\n"
  content += "Then `swift-ast` couldn't read from that path.\n"
  content += "\n"
  content += "### Environment\n"
  content += "- OS Info: \(getOSInfo())\n"
  content += "- Yanagiba/swift-ast version: \(Version.current.library)\n"
  content += "\n"
  return content
}
