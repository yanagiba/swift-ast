/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public struct SourceReader {
  static public func read(at path: String) throws -> SourceFile {
    let absolutePath = path.absolutePath
    guard let content = try? absolutePath.readFile() else {
      throw SourceError.cannotReadFile(absolutePath)
    }
    return SourceFile(path: absolutePath, content: content)
  }
}

fileprivate extension String {
  var absolutePath: String {
    if self.hasPrefix("/") {
      return self
    }

    let currentDirectory = FileManager.default.currentDirectoryPath
    var pathHead = NSString(string: currentDirectory).pathComponents.filter { $0 != "." }
    if pathHead.count > 1 && pathHead.last == "/" {
      pathHead.removeLast()
    }
    var pathTail = NSString(string: self).pathComponents.filter { $0 != "." }
    if pathTail.count > 1 && pathTail.last == "/" {
      pathTail.removeLast()
    }

    while pathTail.first == ".." {
      pathTail.removeFirst()
      if !pathHead.isEmpty {
        pathHead.removeLast()
      }

      if pathHead.isEmpty || pathTail.isEmpty {
        break
      }
    }

    let absolutePath = pathHead.joined(separator: "/") + "/" + pathTail.joined(separator: "/")
    return absolutePath.substring(from: absolutePath.index(absolutePath.startIndex, offsetBy: 1))
  }

  func readFile() throws -> String {
    return try String(contentsOfFile: self, encoding: .utf8)
  }
}
