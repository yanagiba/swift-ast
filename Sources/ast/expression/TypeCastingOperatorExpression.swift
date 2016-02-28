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

public class TypeCastingOperatorExpression: BinaryExpression {
  public enum Kind: String {
    case Is
    case As
    case OptionalAs
    case ForcedAs
  }

  public let kind: Kind
  public let expression: Expression
  public let type: Type

  public init(kind: Kind, expression: Expression, type: Type) {
    self.kind = kind
    self.expression = expression
    self.type = type
  }
}
