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

public struct AvailabilityCondition {
  public enum Argument {
    case major(String, Int)
    case minor(String, Int, Int)
    case patch(String, Int, Int, Int)
    case all
  }

  public let arguments: [Argument]

  public init(arguments: [Argument]) {
    self.arguments = arguments
  }
}

extension AvailabilityCondition.Argument : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case let .major(platformName, majorVersion):
      return "\(platformName) \(majorVersion)"
    case let .minor(platformName, majorVersion, minorVersion):
      return "\(platformName) \(majorVersion).\(minorVersion)"
    case let .patch(platformName, majorVersion, minorVersion, patchVersion):
      return "\(platformName) \(majorVersion).\(minorVersion).\(patchVersion)"
    case .all:
      return "*"
    }
  }
}

extension AvailabilityCondition : ASTTextRepresentable {
  public var textDescription: String {
    let argumentsText = arguments.map({ $0.textDescription }).joined(separator: ", ")
    return "#available(\(argumentsText))"
  }
}
