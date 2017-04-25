/*
   Copyright 2015-2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public struct SourceLocation {
  public let path: String
  public let line: Int
  public let column: Int

  public init(path: String, line: Int, column: Int) {
    self.path = path
    self.line = line
    self.column = column
  }
}

extension SourceLocation : Equatable {
  static public func ==(lhs: SourceLocation, rhs: SourceLocation) -> Bool {
    return lhs.path == rhs.path && lhs.line == rhs.line && lhs.column == rhs.column
  }
}

extension SourceLocation : Hashable {
  public var hashValue: Int {
    return path.hashValue ^ line.hashValue ^ column.hashValue
  }
}

extension SourceLocation {
  public static let DUMMY = SourceLocation(path: "dummy", line: 0, column: 0)
  public static let INVALID =
    SourceLocation(path: "invalid", line: -1, column: -1)

  public var isValid: Bool {
    return path != "invalid" && path != "dummy" && line > 0 && column > 0
  }
}

extension SourceLocation : CustomStringConvertible {
  public var description: String {
    return "\(path):\(line):\(column)"
  }
}
