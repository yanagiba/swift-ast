/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

// Merry Christmas 2015! -Ryuichi

import Foundation

public struct SourceFile {
  public enum Origin {
    case file(String)
    case memory(UUID)
  }

  public let origin: Origin
  public let content: String

  public var identifier: String {
    switch origin {
    case .file(let path):
      return path
    case .memory(let uuid):
      return uuid.uuidString
    }
  }

  @available(*, deprecated, message: "Use `identifier` instead.")
  public var path: String {
    return identifier
  }

  public init(path: String, content: String) {
    self.origin = .file(path)
    self.content = content
  }

  public init(uuid: UUID = UUID(), content: String) {
    self.origin = .memory(uuid)
    self.content = content
  }
}

extension SourceFile.Origin : Equatable {
  static public func ==(lhs: SourceFile.Origin, rhs: SourceFile.Origin) -> Bool {
    switch (lhs, rhs) {
    case let (.file(lhsPath), .file(rhsPath)):
      return lhsPath == rhsPath
    case let (.memory(lhsUuid), .memory(rhsUuid)):
      return lhsUuid == rhsUuid
    default:
      return false
    }
  }
}

extension SourceFile.Origin : Hashable {
  public var hashValue: Int {
    switch self {
    case .file(let path):
      return path.hashValue
    case .memory(let uuid):
      return uuid.hashValue
    }
  }
}
