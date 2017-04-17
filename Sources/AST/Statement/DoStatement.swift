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


public class DoStatement : ASTNode, Statement {
  public struct CatchClause {
    public let pattern: Pattern?
    public let whereExpression: Expression?
    public let codeBlock: CodeBlock

    public init(
      pattern: Pattern? = nil,
      whereExpression: Expression? = nil,
      codeBlock: CodeBlock
    ) {
      self.pattern = pattern
      self.whereExpression = whereExpression
      self.codeBlock = codeBlock
    }
  }
  public let codeBlock: CodeBlock
  public let catchClauses: [CatchClause]

  public init(codeBlock: CodeBlock, catchClauses: [CatchClause] = []) {
    self.codeBlock = codeBlock
    self.catchClauses = catchClauses
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    return (["do \(codeBlock.textDescription)"] +
      catchClauses.map({ $0.textDescription })).joined(separator: " ")
  }
}

extension DoStatement.CatchClause : ASTTextRepresentable {
  public var textDescription: String {
    var patternText = ""
    if let pattern = pattern {
      patternText = " \(pattern.textDescription)"
    }
    var whereText = ""
    if let whereExpr = whereExpression {
      whereText = " where \(whereExpr.textDescription)"
    }
    return "catch\(patternText)\(whereText) \(codeBlock.textDescription)"
  }
}
