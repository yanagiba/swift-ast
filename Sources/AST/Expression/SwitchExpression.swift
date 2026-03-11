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


public class SwitchExpression : ASTNode, PrimaryExpression {
  public private(set) var expression: ASTExpression
  public private(set) var cases: [SwitchStatement.Case]

  public init(expression: ASTExpression, cases: [SwitchStatement.Case] = []) {
    self.expression = expression
    self.cases = cases
  }

  // MARK: - Node Mutations

  public func replaceExpression(with expr: ASTExpression) {
    expression = expr
  }

  public func replaceCase(at index: Int, with newCase: SwitchStatement.Case) {
    guard index >= 0 && index < cases.count else { return }
    cases[index] = newCase
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
