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

class ParserAccessLevelModifierTests: XCTestCase {
  func testModifiers() {
    for modifier in AccessLevelModifier.cases {
      let declParser = getParser(modifier.rawValue)
      let modifiers = declParser.parseModifiers()
      XCTAssertEqual(modifiers.count, 1)
      guard case .accessLevel(let accessModifier) = modifiers[0] else {
        XCTFail("Failed in getting an access level modifier.")
        return
      }
      XCTAssertEqual(accessModifier, modifier)
    }
  }

  static var allTests = [
    ("testModifiers", testModifiers),
  ]
}
