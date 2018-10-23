/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

   Licensed under the Apache License, Version 20 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

public enum DeclarationModifier: Equatable {
  case `class`, convenience, dynamic, final, infix, lazy
  case optional, override, postfix, prefix, required, `static`
  case unowned, unownedSafe, unownedUnsafe, weak
  case accessLevel(AccessLevelModifier)
  case mutation(MutationModifier)
}

extension DeclarationModifier : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .class:
      return "class"
    case .convenience:
      return "convenience"
    case .dynamic:
      return "dynamic"
    case .final:
      return "final"
    case .infix:
      return "infix"
    case .lazy:
      return "lazy"
    case .optional:
      return "optional"
    case .override:
      return "override"
    case .postfix:
      return "postfix"
    case .prefix:
      return "prefix"
    case .required:
      return "required"
    case .static:
      return "static"
    case .unowned:
      return "unowned"
    case .unownedSafe:
      return "unowned(safe)"
    case .unownedUnsafe:
      return "unowned(unsafe)"
    case .weak:
      return "weak"
    case .accessLevel(let modifier):
      return modifier.textDescription
    case .mutation(let modifier):
      return modifier.textDescription
    }
  }
}
