/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public indirect enum CompilationCondition {
  // Platform conditions
  case os(String)
  case arch(String)
  case swift(String, String)           // (operator, version) e.g. (">=", "5.5")
  case compiler(String, String)        // (operator, version) e.g. ("<", "6.0")
  case canImport(String)               // import path e.g. "Foundation.Networking"
  case hasFeature(String)              // feature name e.g. "ExistentialAny"
  case targetEnvironment(String)       // e.g. "simulator", "macCatalyst"

  // Logical conditions
  case identifier(String)
  case booleanLiteral(Bool)
  case not(CompilationCondition)
  case and(CompilationCondition, CompilationCondition)
  case or(CompilationCondition, CompilationCondition)
  case parenthesized(CompilationCondition)
}

extension CompilationCondition : CustomStringConvertible {
  public var description: String { textDescription }

  public var textDescription: String {
    switch self {
    case .os(let name):
      return "os(\(name))"
    case .arch(let name):
      return "arch(\(name))"
    case .swift(let op, let version):
      return "swift(\(op)\(version))"
    case .compiler(let op, let version):
      return "compiler(\(op)\(version))"
    case .canImport(let path):
      return "canImport(\(path))"
    case .hasFeature(let feature):
      return "hasFeature(\(feature))"
    case .targetEnvironment(let env):
      return "targetEnvironment(\(env))"
    case .identifier(let name):
      return name
    case .booleanLiteral(let value):
      return value ? "true" : "false"
    case .not(let condition):
      return "!\(condition.textDescription)"
    case .and(let lhs, let rhs):
      return "\(lhs.textDescription) && \(rhs.textDescription)"
    case .or(let lhs, let rhs):
      return "\(lhs.textDescription) || \(rhs.textDescription)"
    case .parenthesized(let condition):
      return "(\(condition.textDescription))"
    }
  }
}
