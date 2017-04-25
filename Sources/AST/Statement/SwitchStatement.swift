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


public class SwitchStatement : ASTNode, Statement {
  public enum Case {
    public struct Item {
      public let pattern: Pattern
      public let whereExpression: Expression?

      public init(pattern: Pattern, whereExpression: Expression? = nil) {
        self.pattern = pattern
        self.whereExpression = whereExpression
      }
    }

    case `case`([Item], Statements)
    case `default`(Statements)
  }
  public let expression: Expression
  public let cases: [Case]

  public init(expression: Expression, cases: [Case] = []) {
    self.expression = expression
    self.cases = cases
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    var casesDescr = "{}"
    if !cases.isEmpty {
      let casesText = cases.map({ $0.textDescription }).joined(separator: "\n")
      casesDescr = "{\n\(casesText)\n}"
    }
    return "switch \(expression.textDescription) \(casesDescr)"
  }
}

extension SwitchStatement.Case.Item : ASTTextRepresentable {
  public var textDescription: String {
    var whereText = ""
    if let whereExpr = whereExpression {
      whereText = " where \(whereExpr.textDescription)"
    }
    return "\(pattern.textDescription)\(whereText)"
  }
}

extension SwitchStatement.Case : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case let .case(itemList, stmts):
      let itemListText = itemList.map({ $0.textDescription }).joined(separator: ", ")
      return "case \(itemListText):\n\(stmts.textDescription)"
    case .default(let stmts):
      return "default:\n\(stmts.textDescription)"
    }
  }
}
