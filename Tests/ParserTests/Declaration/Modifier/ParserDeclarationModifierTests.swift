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

class ParserDeclarationModifierTests: XCTestCase {
  func testModifiers() {
    let declModifiers: [String: DeclarationModifier] = [
      "class": .class,
      "convenience": .convenience,
      "dynamic": .dynamic,
      "final": .final,
      "infix": .infix,
      "lazy": .lazy,
      "optional": .optional,
      "override": .override,
      "postfix": .postfix,
      "prefix": .prefix,
      "required": .required,
      "static": .static,
      "unowned": .unowned,
      "unowned(safe)": .unownedSafe,
      "unowned(unsafe)": .unownedUnsafe,
      "weak": .weak,
    ]
    for (modiferStr, modifier) in declModifiers {
      let declParser = getParser(modiferStr)
      let modifiers = declParser.parseModifiers()
      XCTAssertEqual(modifiers.count, 1)
      XCTAssertEqual(modifiers[0], modifier)
    }
  }

  static var allTests = [
    ("testModifiers", testModifiers),
  ]
}
