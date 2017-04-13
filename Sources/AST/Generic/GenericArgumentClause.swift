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

import Source

public struct GenericArgumentClause {
  public let argumentList: [Type]
  public var sourceRange: SourceRange = .EMPTY

  public init(argumentList: [Type]) {
    self.argumentList = argumentList
  }
}

extension GenericArgumentClause : ASTTextRepresentable {
  public var textDescription: String {
    return "<\(argumentList.map({ $0.textDescription }).joined(separator: ", "))>"
  }
}

extension GenericArgumentClause : SourceLocatable {
}
