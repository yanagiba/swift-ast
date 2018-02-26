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

public class TypeIdentifier : TypeBase {
  public struct TypeName {
    public let name: Identifier
    public let genericArgumentClause: GenericArgumentClause?

    public init(
      name: Identifier, genericArgumentClause: GenericArgumentClause? = nil
    ) {
      self.name = name
      self.genericArgumentClause = genericArgumentClause
    }
  }

  public let names: [TypeName]

  public init(names: [TypeName] = []) {
    self.names = names
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    return names
      .map({ "\($0.name)\($0.genericArgumentClause?.textDescription ?? "")" })
      .joined(separator: ".")
  }
}
