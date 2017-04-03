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

public struct Comment {
  public let content: String
  public let location: SourceLocation

  public init(content: String, location: SourceLocation) {
    self.content = content
    self.location = location
  }
}

extension Comment : Equatable {
  public static func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.content == rhs.content && lhs.location == rhs.location
  }
}

extension Comment : Hashable {
  public var hashValue: Int {
    return location.hashValue ^ content.hashValue
  }
}
