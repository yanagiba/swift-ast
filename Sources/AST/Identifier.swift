/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public enum Identifier {
  case name(String)
  case backtickedName(String)
  case wildcard
}

extension Identifier : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .name(let n):
      return n
    case .backtickedName(let n):
      return "`\(n)`"
    case .wildcard:
      return "_"
    }
  }
}

extension Identifier {
  public func isSyntacticallyEqual(to id: Identifier) -> Bool {
    switch (self, id) {
    case let (.name(lhs), .name(rhs)): return lhs == rhs
    case let (.backtickedName(lhs), .backtickedName(rhs)): return lhs == rhs
    case (.wildcard, .wildcard): return true
    default: return false
    }
  }
}
