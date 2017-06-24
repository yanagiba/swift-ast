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

public class OptionalPattern : PatternBase {
  // Note: per Apple's language reference, optional-pattern -> identifier-pattern?
  // https://goo.gl/ncRCyq
  // However, in real world, we found it could take more than identifier-pattern.
  // To name a few others, it can also take
  // - wildcard-pattern
  // - enum-case-pattern
  // - tuple-pattern
  // And in all cases, these patterns won't be able to have type annotations.
  // In order to accommodate these cases,
  // we implement our optional-pattern differently.

  public enum Kind {
    case identifier(IdentifierPattern)
    case wildcard
    case enumCase(EnumCasePattern)
    case tuple(TuplePattern)
  }

  public let kind: Kind

  public init(kind: Kind) {
    // TODO: we need to make sure they don't have type annotations.
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case .identifier(let idPttrn):
      return "\(idPttrn.textDescription)?"
    case .wildcard:
      return "_?"
    case .enumCase(let enumCasePttrn):
      return "\(enumCasePttrn.textDescription)?"
    case .tuple(let tuplePttrn):
      return "\(tuplePttrn.textDescription)?"
    }
  }
}
