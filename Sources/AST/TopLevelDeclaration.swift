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

public class TopLevelDeclaration : ASTNode {
  public let statements: [Statement]

  public init(statements: [Statement] = []) {
    self.statements = statements
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
    return statements.textDescription
  }
}
