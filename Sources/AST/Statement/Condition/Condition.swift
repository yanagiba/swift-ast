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

public enum Condition {
  case expression(Expression)
  case availability(AvailabilityCondition)
  case `case`(Pattern, Expression) // case condition
  case `let`(Pattern, Expression) // optional-binding condition
  case `var`(Pattern, Expression) // optional-binding condition
}

extension Condition : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .expression(let expr):
      return expr.textDescription
    case .availability(let availabilityCondition):
      return availabilityCondition.textDescription
    case let .case(pattern, expr):
      return "case \(pattern) = \(expr)"
    case let .let(pattern, expr):
      return "let \(pattern) = \(expr)"
    case let .var(pattern, expr):
      return "var \(pattern) = \(expr)"
    }
  }
}
