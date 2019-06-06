/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public struct DotYanagiba { // .yanagiba
  public struct Module {
    public enum Option { // various option kinds, such as String, [String], [String: Any], etc
      case int(Int)
      case string(String)
      case listInt([Int])
      case listString([String])
      case dictInt([String: Int])
      case dictString([String: String])
    }

    public let options: [String: Option]

    public init(options: [String: Option]) {
      // options for each module, for example, `enable-rules`, `report-type`, etc
      self.options = options
    }
  }

  public let modules: [String: Module]

  public init(modules: [String: Module]) { // yanagiba modules, such as `ast`, `lint`, `transform`, etc
    self.modules = modules
  }
}

extension DotYanagiba.Module.Option: Equatable {
  public static func ==(lhs: DotYanagiba.Module.Option, rhs: DotYanagiba.Module.Option) -> Bool {
    return lhs.isEqual(to: rhs)
  }

  public func isEqual(to kind: DotYanagiba.Module.Option) -> Bool {
    switch (self, kind) {
    case let (.int(lhs), .int(rhs)):
      return lhs == rhs
    case let (.string(lhs), .string(rhs)):
      return lhs == rhs
    case let (.listInt(lhs), .listInt(rhs)):
      return lhs == rhs
    case let (.listString(lhs), .listString(rhs)):
      return lhs == rhs
    case let (.dictInt(lhs), .dictInt(rhs)):
      return lhs == rhs
    case let (.dictString(lhs), .dictString(rhs)):
      return lhs == rhs
    default:
      return false
    }
  }
}
