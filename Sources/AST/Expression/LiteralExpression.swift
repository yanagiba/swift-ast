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

public class DictionaryEntry {
  public let key: Expression
  public let value: Expression

  public init(key: Expression, value: Expression) {
    self.key = key
    self.value = value
  }
}

extension DictionaryEntry : ASTTextRepresentable {
  public var textDescription: String {
    return "\(key.textDescription): \(value.textDescription)"
  }
}

public class LiteralExpression : ASTNode, PrimaryExpression {
  public enum Kind {
    case `nil`
    case boolean(Bool)
    case integer(Int, String)
    case floatingPoint(Double, String)
    case staticString(String, String)
    case interpolatedString([Expression], String)
    case array([Expression])
    case dictionary([DictionaryEntry])
  }

  public let kind: Kind

  public init(kind: Kind) {
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case .nil:
      return "nil"
    case .boolean(let bool):
      return bool ? "true" : "false"
    case let .integer(_, rawText):
      return rawText
    case let .floatingPoint(_, rawText):
      return rawText
    case let .staticString(_, rawText):
      return rawText
    case let .interpolatedString(_, rawText):
      return rawText
    case .array(let exprs):
      return "[\(exprs.textDescription)]"
    case .dictionary(let entries):
      if entries.isEmpty {
        return "[:]"
      }
      let dictText = entries.map({ $0.textDescription }).joined(separator: ", ")
      return "[\(dictText)]"
    }
  }
}
