/*
   Copyright 2016-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

public class TopLevelDeclaration : ASTNode, ASTUnit {
  public let statements: Statements
  public let comments: CommentSet
  public let shebang: Shebang?

  public init(statements: Statements = [], comments: CommentSet = [], shebang: Shebang? = nil) {
    self.statements = statements
    self.comments = comments
    self.shebang = shebang
  }

  // MARK: - ASTUnit

  public var translationUnit: TopLevelDeclaration {
    return self
  }

  // MARK: - ASTNodeContext

  override public var sourceRange: SourceRange {
    if statements.isEmpty {
      return .EMPTY
    }
    let firstStmt = statements[0]
    let lastStmt = statements[statements.count - 1]
    return SourceRange(
      start: firstStmt.sourceRange.start, end: lastStmt.sourceRange.end)
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let shebangLine = shebang.map({ "#!\($0.interpreterDirective)\n\n" }) ?? ""
    return shebangLine + statements.textDescription
  }
}
