/*
   Copyright 2015-2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import XCTest

@testable import Lexer
@testable import Source

class LexerKeywordTests: XCTestCase {
  let keywordMapping: [(keyword: String, kind: Token.Kind)] = [
    ("as", .as),
    ("associativity", .associativity),
    ("break", .break),
    ("catch", .catch),
    ("case", .case),
    ("class", .class),
    ("continue", .continue),
    ("convenience", .convenience),
    ("default", .default),
    ("defer", .defer),
    ("deinit", .deinit),
    ("didSet", .didSet),
    ("do", .do),
    ("dynamic", .dynamic),
    ("enum", .enum),
    ("extension", .extension),
    ("else", .else),
    ("fallthrough", .fallthrough),
    ("fileprivate", .fileprivate),
    ("final", .final),
    ("for", .for),
    ("func", .func),
    ("get", .get),
    ("guard", .guard),
    ("if", .if),
    ("import", .import),
    ("in", .in),
    ("indirect", .indirect),
    ("infix", .infix),
    ("init", .init),
    ("inout", .inout),
    ("internal", .internal),
    ("is", .is),
    ("lazy", .lazy),
    ("let", .let),
    ("left", .left),
    ("mutating", .mutating),
    ("nil", .nil),
    ("none", .none),
    ("nonmutating", .nonmutating),
    ("open", .open),
    ("operator", .operator),
    ("optional", .optional),
    ("override", .override),
    ("postfix", .postfix),
    ("prefix", .prefix),
    ("private", .private),
    ("protocol", .protocol),
    ("precedence", .precedence),
    ("public", .public),
    ("repeat", .repeat),
    ("required", .required),
    ("rethrows", .rethrows),
    ("return", .return),
    ("right", .right),
    ("safe", .safe),
    ("self", .self),
    ("set", .set),
    ("static", .static),
    ("struct", .struct),
    ("subscript", .subscript),
    ("super", .super),
    ("switch", .switch),
    ("throw", .throw),
    ("throws", .throws),
    ("try", .try),
    ("typealias", .typealias),
    ("unowned", .unowned),
    ("unsafe", .unsafe),
    ("var", .var),
    ("weak", .weak),
    ("where", .where),
    ("while", .while),
    ("willSet", .willSet),
    ("Any", .Any),
    ("Self", .Self),
    ("Type", .Type),
    ("Protocol", .Protocol),
  ]

  func testKeywords() {
    keywordMapping.forEach { k in
      lexAndTest(k.keyword) { t in
        XCTAssertEqual(t, k.kind)
      }
    }
  }

  static var allTests = [
    ("testKeywords", testKeywords),
  ]
}
