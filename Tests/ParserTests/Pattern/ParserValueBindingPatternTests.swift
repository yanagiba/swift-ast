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

class ParserValueBindingPatternTests: XCTestCase {
  func testConstant() {
    parsePatternAndTest("let  foo", "let foo", testClosure: { pttrn in
      guard let valueBindingPattern = pttrn as? ValueBindingPattern,
        case .let(let pattern) = valueBindingPattern.kind else {
        XCTFail("Failed in parsing a value-binding pattern.")
        return
      }

      XCTAssertTrue(pattern is IdentifierPattern)
    })
  }

  func testVariable() {
    parsePatternAndTest("var    foo   :   Bar", "var foo: Bar", testClosure: { pttrn in
      guard let valueBindingPattern = pttrn as? ValueBindingPattern,
        case .var(let pattern) = valueBindingPattern.kind else {
        XCTFail("Failed in parsing a value-binding pattern.")
        return
      }

      XCTAssertTrue(pattern is IdentifierPattern)
    })
  }

  func testOptional() {
    parsePatternAndTest("let x?", "let x?")
  }

  func testSourceRange() {
    parsePatternAndTest("let  foo", "let foo", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 9))
    })
    parsePatternAndTest("var    foo   :   Bar", "var foo: Bar", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 21))
    })
    parsePatternAndTest("let x?", "let x?", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 7))
    })
  }

  static var allTests = [
    ("testConstant", testConstant),
    ("testVariable", testVariable),
    ("testOptional", testOptional),
    ("testSourceRange", testSourceRange),
  ]
}
