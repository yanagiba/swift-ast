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


public class IfStatement : ASTNode, Statement {
  public enum ElseClause {
    case `else`(CodeBlock)
    indirect case elseif(IfStatement)
  }

  public let conditionList: ConditionList
  public let codeBlock: CodeBlock
  public let elseClause: ElseClause?

  public init(
    conditionList: ConditionList,
    codeBlock: CodeBlock,
    elseClause: ElseClause? = nil
  ) {
    self.conditionList = conditionList
    self.codeBlock = codeBlock
    self.elseClause = elseClause
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    var elseText = ""
    if let elseClause = elseClause {
      elseText = " \(elseClause.textDescription)"
    }
    return "if \(conditionList.textDescription) \(codeBlock.textDescription)\(elseText)"
  }
}

extension IfStatement.ElseClause : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .else(let codeBlock):
      return "else \(codeBlock.textDescription)"
    case .elseif(let ifStmt):
      return "else \(ifStmt.textDescription)"
    }
  }
}
