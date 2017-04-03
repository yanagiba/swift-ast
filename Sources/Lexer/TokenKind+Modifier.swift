/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

public extension Token.Kind /* modifiers */ {
  var isModifier: Bool {
    switch self {
    case .class, .convenience, .dynamic, .final, .infix, .lazy,
      .optional, .override, .postfix, .prefix, .required, .static, .unowned, .weak,
      .private, .fileprivate, .internal, .public, .open,
      .mutating, .nonmutating:
        return true
      default:
        return false
    }
  }

  static var declarationModifiers: [Token.Kind] {
    // Note: this doesn't include the access level modifiers and mutation modifiers
    return [.class, .convenience, .dynamic, .final, .infix, .lazy,
      .optional, .override, .postfix, .prefix, .required, .static, .unowned, .weak]
  }

  static var accessLevelModifiers: [Token.Kind] {
    return [.private, .fileprivate, .internal, .public, .open]
  }

  static var mutationModifiers: [Token.Kind] {
    return [.mutating, .nonmutating]
  }
}
