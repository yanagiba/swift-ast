/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public class TernaryConditionalOperatorExpression : ASTNode, BinaryExpression {
  public let conditionExpression: Expression
  public let trueExpression: Expression
  public let falseExpression: Expression

  public init(
    conditionExpression: Expression,
    trueExpression: Expression,
    falseExpression: Expression
  ) {
    self.conditionExpression = conditionExpression
    self.trueExpression = trueExpression
    self.falseExpression = falseExpression
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    return "\(conditionExpression.textDescription) ? \(trueExpression.textDescription) : \(falseExpression.textDescription)"
  }
}
