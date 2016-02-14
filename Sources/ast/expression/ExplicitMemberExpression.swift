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

public class ExplicitMemberExpression: PostfixExpression {
  public enum Kind: String {
    case Tuple
    case NamedType
  }

  public let kind: Kind
  public let postfixExpression: PostfixExpression
  public let decimalIntegerLiteralExpression: IntegerLiteralExpression?
  public let identifierExpression: IdentifierExpression?

  private init(
    kind: Kind,
    postfixExpression: PostfixExpression,
    decimalIntegerLiteralExpression: IntegerLiteralExpression?,
    identifierExpression: IdentifierExpression?) {
    self.kind = kind
    self.postfixExpression = postfixExpression
    self.decimalIntegerLiteralExpression = decimalIntegerLiteralExpression
    self.identifierExpression = identifierExpression
  }

  public class func makeTupleExplicitMemberExpression(
    postfixExpression: PostfixExpression,
    _ decimalIntegerLiteralExpression: IntegerLiteralExpression) -> ExplicitMemberExpression {
    return ExplicitMemberExpression(
      kind: .Tuple,
      postfixExpression: postfixExpression,
      decimalIntegerLiteralExpression: decimalIntegerLiteralExpression,
      identifierExpression: nil)
  }

  public class func makeNamedTypeExplicitMemberExpression(
    postfixExpression: PostfixExpression,
    _ identifierExpression: IdentifierExpression) -> ExplicitMemberExpression {
    return ExplicitMemberExpression(
      kind: .NamedType,
      postfixExpression: postfixExpression,
      decimalIntegerLiteralExpression: nil,
      identifierExpression: identifierExpression)
  }
}
