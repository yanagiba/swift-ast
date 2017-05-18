/*
   Copyright 2015 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public struct SourceRange {
  // Note: range := [start..<end)
  public let start: SourceLocation
  public let end: SourceLocation

  public init(start: SourceLocation, end: SourceLocation) {
    self.start = start
    self.end = end
  }
}

extension SourceRange : Equatable {
  static public func ==(lhs: SourceRange, rhs: SourceRange) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
  }
}

extension SourceRange : Hashable {
  public var hashValue: Int {
    return start.hashValue ^ end.hashValue
  }
}

extension SourceRange {
  public static let EMPTY = SourceRange(start: .DUMMY, end: .DUMMY)
  public static let INVALID = SourceRange(start: .INVALID, end: .INVALID)

  public var isValid: Bool {
    return start.isValid || end.isValid
  }
}

extension SourceRange : CustomStringConvertible {
  public var description: String {
    return "\(start.path):\(start.line):\(start.column)-\(end.line):\(end.column)"
  }
}
