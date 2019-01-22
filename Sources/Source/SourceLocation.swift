/*
   Copyright 2015-2016 Ryuichi Laboratories and the Yanagiba project contributors

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

public struct SourceLocation: Equatable, Hashable {
  public let identifier: String
  public let line: Int
  public let column: Int

  @available(*, deprecated, message: "Use `identifier` instead.")
  public var path: String {
    return identifier
  }

  public init(identifier: String, line: Int, column: Int) {
    self.identifier = identifier
    self.line = line
    self.column = column
  }

  @available(*, deprecated, message: "Use `init(identifier:line:column:)` instead.")
  public init(path: String, line: Int, column: Int) {
    self.identifier = path
    self.line = line
    self.column = column
  }
}


extension SourceLocation {
  public static let DUMMY = SourceLocation(identifier: "dummy", line: 0, column: 0)
  public static let INVALID =
    SourceLocation(identifier: "invalid", line: -1, column: -1)

  public var isValid: Bool {
    return identifier != "invalid" && identifier != "dummy" && line > 0 && column > 0
  }
}

extension SourceLocation : CustomStringConvertible {
  public var description: String {
    return "\(identifier):\(line):\(column)"
  }
}
