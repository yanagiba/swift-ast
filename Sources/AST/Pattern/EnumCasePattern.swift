/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public class EnumCasePattern : PatternBase {
  public let typeIdentifier: TypeIdentifier?
  public let name: Identifier
  public let tuplePattern: TuplePattern?

  public init(
    typeIdentifier: TypeIdentifier? = nil,
    name: Identifier,
    tuplePattern: TuplePattern? = nil
  ) {
    self.typeIdentifier = typeIdentifier
    self.name = name
    self.tuplePattern = tuplePattern
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    return "\(typeIdentifier?.textDescription ?? "").\(name)\(tuplePattern?.textDescription ?? "")"
  }
}
