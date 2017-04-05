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

import XCTest

@testable import AST
@testable import Parser

class ParserDeclarationModifiersTests: XCTestCase {
  func testAllModifiers() {
    let declModifierStrs = [
      "class",
      "convenience",
      "dynamic",
      "final",
      "infix",
      "lazy",
      "optional",
      "override",
      "postfix",
      "prefix",
      "required",
      "static",
      "unowned",
      "unowned(safe)",
      "unowned(unsafe)",
      "weak",
      "mutating",
      "nonmutating",
      "private",
      "private(set)",
      "fileprivate",
      "fileprivate(set)",
      "internal",
      "internal(set)",
      "public",
      "public(set)",
      "open",
      "open(set)",
    ]
    let declModifiers: [DeclarationModifier] = [
      .class,
      .convenience,
      .dynamic,
      .final,
      .infix,
      .lazy,
      .optional,
      .override,
      .postfix,
      .prefix,
      .required,
      .static,
      .unowned,
      .unownedSafe,
      .unownedUnsafe,
      .weak,
      .mutation(.mutating),
      .mutation(.nonmutating),
      .accessLevel(.private),
      .accessLevel(.privateSet),
      .accessLevel(.fileprivate),
      .accessLevel(.fileprivateSet),
      .accessLevel(.internal),
      .accessLevel(.internalSet),
      .accessLevel(.public),
      .accessLevel(.publicSet),
      .accessLevel(.open),
      .accessLevel(.openSet),
    ]
    let testStr = declModifierStrs.joined(separator: " ")
    let declParser = getParser(testStr)
    let modifiers = declParser.parseModifiers()
    XCTAssertEqual(modifiers.count, declModifiers.count)
    for (index, modifier) in zip(modifiers.indices, modifiers) {
      XCTAssertEqual(modifier, declModifiers[index])
    }
  }

  static var allTests = [
    ("testAllModifiers", testAllModifiers),
  ]
}
