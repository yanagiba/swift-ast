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

public struct OptionalPattern {
  // Note: per definition, optional-pattern -> identifier-pattern?
  // in this case, identifier-pattern won't have a type annotation,
  // so it is equivalent to an identifier. So here, instead of wrapping
  // an identifier-pattern, we simply wrap an identifier.
  public let identifier: Identifier

  public init(identifier: Identifier) {
    self.identifier = identifier
  }
}

extension OptionalPattern : Pattern {
  public var textDescription: String {
    return "\(identifier)?"
  }
}