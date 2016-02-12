/*
   Copyright 2016 Ryuichi Saito, LLC

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

public class FunctionCallExpression: PostfixExpression {
  public enum Kind: String {
    case Parenthesized
    case Closure
  }

  public let kind: Kind
  public let postfixExpression: PostfixExpression
  public let parenthesizedExpression: ParenthesizedExpression?
  public let trailingClosure: ClosureExpression?

  private init(
    kind: Kind,
    postfixExpression: PostfixExpression,
    parenthesizedExpression: ParenthesizedExpression?,
    trailingClosure: ClosureExpression?) {
    self.kind = kind
    self.postfixExpression = postfixExpression
    self.parenthesizedExpression = parenthesizedExpression
    self.trailingClosure = trailingClosure
  }

  public class func makeParenthesizedFunctionCallExpression(
    postfixExpression: PostfixExpression, _ parenthesizedExpression: ParenthesizedExpression) -> FunctionCallExpression {
    return FunctionCallExpression(
      kind: .Parenthesized,
      postfixExpression: postfixExpression,
      parenthesizedExpression: parenthesizedExpression,
      trailingClosure: nil)
  }

  public class func makeClosureFunctionCallExpression(
    postfixExpression: PostfixExpression,
    _ parenthesizedExpression: ParenthesizedExpression?,
    _ trailingClosure: ClosureExpression) -> FunctionCallExpression {
    return FunctionCallExpression(
      kind: .Closure,
      postfixExpression: postfixExpression,
      parenthesizedExpression: parenthesizedExpression,
      trailingClosure: trailingClosure)
  }
}
