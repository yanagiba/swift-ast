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

class LexerIdentifierTests: XCTestCase {
  let identifiers = ["foo", "_bar", "_1", "R2D2", "😃", "abc_"]

  func testIdentifiers() {
    identifiers.forEach { i in
      lexAndTest(i) { t in
        XCTAssertEqual(t, .identifier(i))
      }
    }
  }

  func testBacktickIdentifiers() {
    let backtickIdentifiers = identifiers + ["public", "true", "class"]
    backtickIdentifiers.forEach { i in
      let backtickIdentifier = "`\(i)`"
      lexAndTest(backtickIdentifier) { t in
        XCTAssertEqual(t, .identifier(i))
      }
    }
  }

  func testImplicitParameterName() {
    let decimalDigits = [0, 1, 12, 123]
    decimalDigits.forEach { d in
      let implicitParameterName = "$\(d)"
      lexAndTest(implicitParameterName) { t in
        XCTAssertEqual(t, .implicitParameterName(d))
      }
    }
  }

  static var allTests = [
    ("testIdentifiers", testIdentifiers),
    ("testBacktickIdentifiers", testBacktickIdentifiers),
    ("testImplicitParameterName", testImplicitParameterName),
  ]
}
