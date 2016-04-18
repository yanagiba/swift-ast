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

public class SuperclassExpression: PrimaryExpression {
  public enum Kind: String {
    case Method
    case Subscript
    case Initializer
  }

  public let kind: Kind
  public let methodIdentifier: Identifier
  public let subscriptExpressions: [Expression]

  private init(kind: Kind, methodIdentifier: Identifier = "", subscriptExpressions: [Expression] = []) {
    self.kind = kind
    self.methodIdentifier = methodIdentifier
    self.subscriptExpressions = subscriptExpressions
  }

  public class func makeSuperclassMethodExpression(_ methodIdentifier: Identifier) -> SuperclassExpression {
    return SuperclassExpression(kind: .Method, methodIdentifier: methodIdentifier)
  }

  public class func makeSuperclassSubscriptExpression(_ subscriptExpressions: [Expression]) -> SuperclassExpression {
    return SuperclassExpression(kind: .Subscript, subscriptExpressions: subscriptExpressions)
  }

  public class func makeSuperclassInitializerExpression() -> SuperclassExpression {
    return SuperclassExpression(kind: .Initializer)
  }
}
