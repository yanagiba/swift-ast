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

struct Char {
  let unicodeScalar: UnicodeScalar
  let role: Role
}

extension Char {
  var string: String {
    return unicodeScalar.string
  }

  var int: Int? {
    return unicodeScalar.int
  }
}

extension Char : Equatable {
  static func ==(lhs: Char, rhs: Char) -> Bool {
    return lhs.unicodeScalar == rhs.unicodeScalar && lhs.role == rhs.role
  }
}

extension Char {
  static let eof = Char(unicodeScalar: UnicodeScalar(0), role: .eof)
  static let doubleQuote = Char(unicodeScalar: "\"", role: .doubleQuote)
}
