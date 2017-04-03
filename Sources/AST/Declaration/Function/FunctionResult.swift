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

public struct FunctionResult {
  public let attributes: Attributes
  public let type: Type

  public init(attributes: Attributes = [], type: Type) {
    self.attributes = attributes
    self.type = type
  }
}

extension FunctionResult : ASTTextRepresentable {
  public var textDescription: String {
    let typeText = type.textDescription
    if attributes.isEmpty {
      return "-> \(typeText)"
    }
    return "-> \(attributes.textDescription) \(typeText)"
  }
}
