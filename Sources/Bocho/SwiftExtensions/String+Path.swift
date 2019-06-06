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

import Foundation

public extension String {
  var truncatedPath: String {
    return truncatedPath()
  }

  func truncatedPath(
    currentDirectoryPath currentDirectory: String = FileManager.default.currentDirectoryPath
  ) -> String {
    // Note: one extra character is truncated after the prefix
    guard hasPrefix(currentDirectory) else {
      return self
    }

    return String(self[index(startIndex, offsetBy: currentDirectory.count+1)...])
  }

  var absolutePath: String {
    return absolutePath()
  }

  func absolutePath(
    currentDirectoryPath currentDirectory: String = FileManager.default.currentDirectoryPath
  ) -> String {
    if self.hasPrefix("/") {
      return self
    }

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
    return String(absolutePath[absolutePath.index(after: absolutePath.startIndex)...])
  }

  var parentPath: String {
    return parentPath()
  }

  func parentPath(
    currentDirectoryPath currentDirectory: String = FileManager.default.currentDirectoryPath
  ) -> String {
    var components = absolutePath(currentDirectoryPath: currentDirectory).split(separator: "/")
    components.removeLast()
    return "/" + components.map(String.init).joined(separator: "/")
  }
}

public extension Collection where Iterator.Element == String {
  var commonPathPrefix: String {
    var shortestPath: String?
    var length = Int.max

    for path in self {
      if path.count < length {
        length = path.count
        shortestPath = path
      }
    }

    guard var commonPrefix = shortestPath else {
      return ""
    }

    var endIndex = commonPrefix.endIndex
    for path in self {
      while !commonPrefix.isEmpty && !path.hasPrefix(commonPrefix) {
        endIndex = commonPrefix.index(before: endIndex)
        commonPrefix = String(commonPrefix[..<endIndex])
      }
    }

    return commonPrefix
  }
}
