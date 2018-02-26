/*
   Copyright 2015-2018 Ryuichi Laboratories and the Yanagiba project contributors

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
  var structName: NamedIdentifier? {
    switch self {
    case let .identifier(id, backticked):
      return backticked ? .backtickedName(id) : .name(id)
    case .Type:
      return .name("Type")
    case .Protocol:
      return .name("Protocol")
    default:
      return nil
    }
  }

  var namedIdentifierOrWildcard: NamedIdentifier? {
    if self == .underscore {
      return .wildcard
    }
    return namedIdentifier
  }

  var namedIdentifier: NamedIdentifier? {
    switch self {
    case let .identifier(id, backticked):
      return backticked ? .backtickedName(id) : .name(id)
    case .as:
      return .name("as")
    case .associativity:
      return .name("associativity")
    case .break:
      return .name("break")
    case .catch:
      return .name("catch")
    case .case:
      return .name("case")
    case .class:
      return .name("class")
    case .continue:
      return .name("continue")
    case .convenience:
      return .name("convenience")
    case .default:
      return .name("default")
    case .defer:
      return .name("defer")
    case .deinit:
      return .name("deinit")
    case .didSet:
      return .name("didSet")
    case .do:
      return .name("do")
    case .dynamic:
      return .name("dynamic")
    case .enum:
      return .name("enum")
    case .extension:
      return .name("extension")
    case .else:
      return .name("else")
    case .fallthrough:
      return .name("fallthrough")
    case .fileprivate:
      return .name("fileprivate")
    case .final:
      return .name("final")
    case .for:
      return .name("for")
    case .func:
      return .name("func")
    case .get:
      return .name("get")
    case .guard:
      return .name("guard")
    case .if:
      return .name("if")
    case .import:
      return .name("import")
    case .in:
      return .name("in")
    case .indirect:
      return .name("indirect")
    case .infix:
      return .name("infix")
    case .init:
      return .name("init")
    case .inout:
      return .name("inout")
    case .internal:
      return .name("internal")
    case .is:
      return .name("is")
    case .lazy:
      return .name("lazy")
    case .let:
      return .name("let")
    case .left:
      return .name("left")
    case .mutating:
      return .name("mutating")
    case .nil:
      return .name("nil")
    case .none:
      return .name("none")
    case .nonmutating:
      return .name("nonmutating")
    case .open:
      return .name("open")
    case .operator:
      return .name("operator")
    case .optional:
      return .name("optional")
    case .override:
      return .name("override")
    case .postfix:
      return .name("postfix")
    case .prefix:
      return .name("prefix")
    case .private:
      return .name("private")
    case .protocol:
      return .name("protocol")
    case .precedence:
      return .name("precedence")
    case .public:
      return .name("public")
    case .repeat:
      return .name("repeat")
    case .required:
      return .name("required")
    case .rethrows:
      return .name("rethrows")
    case .return:
      return .name("return")
    case .right:
      return .name("right")
    case .safe:
      return .name("safe")
    case .self:
      return .name("self")
    case .set:
      return .name("set")
    case .static:
      return .name("static")
    case .struct:
      return .name("struct")
    case .subscript:
      return .name("subscript")
    case .super:
      return .name("super")
    case .switch:
      return .name("switch")
    case .throw:
      return .name("throw")
    case .throws:
      return .name("throws")
    case .try:
      return .name("try")
    case .typealias:
      return .name("typealias")
    case .unowned:
      return .name("unowned")
    case .unsafe:
      return .name("unsafe")
    case .var:
      return .name("var")
    case .weak:
      return .name("weak")
    case .where:
      return .name("where")
    case .while:
      return .name("while")
    case .willSet:
      return .name("willSet")
    case .Any:
      return .name("Any")
    case .Protocol:
      return .name("Protocol")
    case .Self:
      return .name("Self")
    case .Type:
      return .name("Type")
    default:
      return nil
    }
  }
}
