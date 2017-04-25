/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public class MetatypeType : TypeBase {
  public enum Kind: String {
    case type
    case `protocol`
  }

  public let referenceType: Type
  public let kind: Kind

  public init(referenceType: Type, kind: Kind) {
    self.referenceType = referenceType
    self.kind = kind
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    switch kind {
    case .type:
      return "Type<\(referenceType.textDescription)>"
    case .protocol:
      return "Protocol<\(referenceType.textDescription)>"
    }
  }
}
