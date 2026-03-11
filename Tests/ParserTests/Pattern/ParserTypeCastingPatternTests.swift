/*
   Copyright 2017, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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
@testable import Diagnostic

class ParserTypeCastingPatternTests: XCTestCase {
  func testIsPattern() {
    parsePatternAndTest("is Foo", "is Foo", forPatternMatching: true, testClosure: { pttrn in
      guard let typeCastingPattern = pttrn as? TypeCastingPattern,
        case .is(let type) = typeCastingPattern.kind else {
        XCTFail("Failed in parsing a type-casting pattern.")
        return
      }

      XCTAssertTrue(type is TypeIdentifier)
      XCTAssertEqual(type.textDescription, "Foo")
    })
  }

  func testIsPatternOnlyAvilableInSwitchCase() {
    var capturedError: Error?
    parsePatternAndTest("is Foo", "", errorClosure: { capturedError = $0 })
    guard let _ = capturedError as? DiagnosticStopper else {
      XCTFail("Expected 'is Foo' to be rejected outside switch-case pattern matching")
      return
    }
  }

  func testAsPattern() {
    parsePatternAndTest("foo   as   Bar", "foo as Bar", testClosure: { pttrn in
      guard let typeCastingPattern = pttrn as? TypeCastingPattern,
        case let .as(pattern, type) = typeCastingPattern.kind else {
        XCTFail("Failed in parsing a type-casting pattern.")
        return
      }

      XCTAssertTrue(pattern is IdentifierPattern)
      XCTAssertEqual(pattern.textDescription, "foo")
      XCTAssertTrue(type is TypeIdentifier)
      XCTAssertEqual(type.textDescription, "Bar")
    })
  }

  func testSourceRange() {
    parsePatternAndTest("is Foo", "is Foo", forPatternMatching: true, testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 7))
    })
    parsePatternAndTest("foo   as   Bar", "foo as Bar", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 15))
    })
  }
}
