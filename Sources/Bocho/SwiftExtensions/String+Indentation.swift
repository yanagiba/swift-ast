/*
   Copyright 2015-2017, 2019 Ryuichi Intellectual Property
                             and the Yanagiba project contributors

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

public extension String {
  init(indentation: Int) {
    self.init(repeating: "  ", count: indentation)
  }

  static let indent = String(indentation: 1)

  var indented: String {
    return components(separatedBy: .newlines)
      .map { String.indent + $0 }
      .joined(separator: "\n")
  }

  /// Dedent a multiline string literal so its content starts at column 0.
  ///
  /// The raw text of a multiline `"""` literal includes the original source
  /// indentation.  This normalises the content to column 0 so that helpers
  /// like `.indented` can add the correct whitespace for the output context.
  var dedentedMultilineString: String {
    let stripped = drop(while: { $0 == "#" })
    guard stripped.hasPrefix("\"\"\"") else { return self }

    var lines = split(separator: "\n", omittingEmptySubsequences: false)
    guard lines.count > 1 else { return self }

    let lastLine = lines[lines.count - 1]
    let indent = lastLine.prefix(while: { $0 == " " || $0 == "\t" })
    guard !indent.isEmpty else { return self }

    for i in 1..<lines.count {
      if lines[i].hasPrefix(indent) {
        lines[i] = lines[i].dropFirst(indent.count)
      }
    }
    return lines.joined(separator: "\n")
  }
}
