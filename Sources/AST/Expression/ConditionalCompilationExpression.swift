/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public class ConditionalCompilationExpression : ASTNode, PostfixExpression {
  public struct Clause {
    public let condition: CompilerControlStatement
    public let expression: PostfixExpression

    public init(condition: CompilerControlStatement, expression: PostfixExpression) {
      self.condition = condition
      self.expression = expression
    }
  }

  public let base: PostfixExpression
  public let clauses: [Clause]
  public let endifStatement: CompilerControlStatement

  public init(
    base: PostfixExpression,
    clauses: [Clause],
    endifStatement: CompilerControlStatement
  ) {
    self.base = base
    self.clauses = clauses
    self.endifStatement = endifStatement
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let baseText = base.textDescription
    var result = baseText
    for clause in clauses {
      result += "\n\(clause.condition.textDescription)"
      let clauseText = clause.expression.textDescription
      if clauseText.hasPrefix(baseText) {
        result += "\n" + String(clauseText.dropFirst(baseText.count))
      } else {
        result += "\n" + clauseText
      }
    }
    result += "\n\(endifStatement.textDescription)"
    return result
  }
}
