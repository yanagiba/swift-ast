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

import Foundation

enum TTYColor : Int {
  case black
  case red
  case green
  case yellow
  case blue
  case magenta
  case cyan
  case white

  case `default`
}

extension String {
  init(indentation: Int) {
    self.init(repeating: "  ", count: indentation)
  }

  static let indent = String(indentation: 1)

  var indent: String {
    return components(separatedBy: .newlines)
      .map { String.indent + $0 }
      .joined(separator: "\n")
  }

  func colored(with color: TTYColor = .default) -> String {
    let defaultColor = "\u{001B}[0m"
    switch color {
    case .default:
      return "\(defaultColor)\(self)\(defaultColor)"
    default:
      return "\u{001B}[\(30 + color.rawValue)m\(self)\(defaultColor)"
    }
  }

  var adjustedForPWD: String {
    let pwd = FileManager.default.currentDirectoryPath
    guard hasPrefix(pwd) else {
      return self
    }

    return substring(from: index(startIndex, offsetBy: pwd.characters.count+1))
  }
}
