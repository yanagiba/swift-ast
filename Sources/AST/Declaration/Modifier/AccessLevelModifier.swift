/*
   Copyright 2017, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public enum AccessLevelModifier : String, CaseIterable {
  case `private` = "private"
  case privateSet = "private(set)"
  case `fileprivate` = "fileprivate"
  case fileprivateSet = "fileprivate(set)"
  case `internal` = "internal"
  case internalSet = "internal(set)"
  case `public` = "public"
  case publicSet = "public(set)"
  case `open` = "open"
  case openSet = "open(set)"
  case packageLevel = "package"
  case packageLevelSet = "package(set)"
}

extension AccessLevelModifier : ASTTextRepresentable {
  public var textDescription: String {
    return self.rawValue
  }
}
