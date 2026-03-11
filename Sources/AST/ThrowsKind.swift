/*
   Copyright 2016, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public enum ThrowsKind {
  case nothrowing
  case throwing
  case typedThrowing(Type)
  case rethrowing
}

extension ThrowsKind : Equatable {
  public static func == (lhs: ThrowsKind, rhs: ThrowsKind) -> Bool {
    switch (lhs, rhs) {
    case (.nothrowing, .nothrowing):
      return true
    case (.throwing, .throwing):
      return true
    case (.rethrowing, .rethrowing):
      return true
    case (.typedThrowing(let lhsType), .typedThrowing(let rhsType)):
      return lhsType.textDescription == rhsType.textDescription
    default:
      return false
    }
  }
}

extension ThrowsKind : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .nothrowing:
      return ""
    case .throwing:
      return "throws"
    case .typedThrowing(let type):
      return "throws(\(type.textDescription))"
    case .rethrowing:
      return "rethrows"
    }
  }
}
