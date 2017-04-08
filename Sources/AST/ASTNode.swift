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

import Source

public class ASTNode {
  public private(set) var lexicalParent: ASTNode? = nil
  public private(set) var sourceRange: SourceRange = .INVALID

  public var textDescription: String {
    guard sourceRange.isValid else {
      return "<<invalid>>"
    }
    return ""
  }

  public func setLexicalParent(_ node: ASTNode) {
    lexicalParent = node
  }

  public func setSourceRange(_ sourceRange: SourceRange) {
    self.sourceRange = sourceRange
  }
}

extension ASTNode : ASTNodeContext, ASTTextRepresentable, SourceLocatable {
}
