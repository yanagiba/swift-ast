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

public extension Token.Kind /* named identifier */ {
  var structName: String? { // TODO: the entire thing requires additional cleaning-up and refactorings
    switch self {
    case .identifier(let id):
      return id
    case .Type:
      return "Type"
    case .Protocol:
      return "Protocol"
    default:
      return nil
    }
  }

  var namedIdentifierOrWildcard: String? {
    if self == .underscore {
      return "_"
    }
    return namedIdentifier
  }

  var namedIdentifier: String? {
    switch self {
    case .identifier(let name):
      return name
    case .as:
      return "as"
    case .associativity:
      return "associativity"
    case .break:
      return "break"
    case .catch:
      return "catch"
    case .case:
      return "case"
    case .class:
      return "class"
    case .continue:
      return "continue"
    case .convenience:
      return "convenience"
    case .default:
      return "default"
    case .defer:
      return "defer"
    case .deinit:
      return "deinit"
    case .didSet:
      return "didSet"
    case .do:
      return "do"
    case .dynamic:
      return "dynamic"
    case .enum:
      return "enum"
    case .extension:
      return "extension"
    case .else:
      return "else"
    case .fallthrough:
      return "fallthrough"
    case .fileprivate:
      return "fileprivate"
    case .final:
      return "final"
    case .for:
      return "for"
    case .func:
      return "func"
    case .get:
      return "get"
    case .guard:
      return "guard"
    case .if:
      return "if"
    case .import:
      return "import"
    case .in:
      return "in"
    case .indirect:
      return "indirect"
    case .infix:
      return "infix"
    case .init:
      return "init"
    case .inout:
      return "inout"
    case .internal:
      return "internal"
    case .is:
      return "is"
    case .lazy:
      return "lazy"
    case .let:
      return "let"
    case .left:
      return "left"
    case .mutating:
      return "mutating"
    case .nil:
      return "nil"
    case .none:
      return "none"
    case .nonmutating:
      return "nonmutating"
    case .open:
      return "open"
    case .operator:
      return "operator"
    case .optional:
      return "optional"
    case .override:
      return "override"
    case .postfix:
      return "postfix"
    case .prefix:
      return "prefix"
    case .private:
      return "private"
    case .protocol:
      return "protocol"
    case .precedence:
      return "precedence"
    case .public:
      return "public"
    case .repeat:
      return "repeat"
    case .required:
      return "required"
    case .rethrows:
      return "rethrows"
    case .return:
      return "return"
    case .right:
      return "right"
    case .safe:
      return "safe"
    case .self:
      return "self"
    case .set:
      return "set"
    case .static:
      return "static"
    case .struct:
      return "struct"
    case .subscript:
      return "subscript"
    case .super:
      return "super"
    case .switch:
      return "switch"
    case .throw:
      return "throw"
    case .throws:
      return "throws"
    case .try:
      return "try"
    case .typealias:
      return "typealias"
    case .unowned:
      return "unowned"
    case .unsafe:
      return "unsafe"
    case .var:
      return "var"
    case .weak:
      return "weak"
    case .where:
      return "where"
    case .while:
      return "while"
    case .willSet:
      return "willSet"
    case .Any:
      return "Any"
    case .Protocol:
      return "Protocol"
    case .Self:
      return "Self"
    case .Type:
      return "Type"
    default:
      return nil
    }
  }
}
