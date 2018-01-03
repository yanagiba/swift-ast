/*
   Copyright 2017-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

class ParserOptionalPatternTests: XCTestCase {
  func testIdentifierOptional() {
    parsePatternAndTest("foo?", "foo?", testClosure: { pttrn in
      guard let optionalPattern = pttrn as? OptionalPattern,
        case .identifier(let id) = optionalPattern.kind
      else {
        XCTFail("Failed in parsing an optional pattern with identifier.")
        return
      }

      ASTTextEqual(id.identifier, "foo")
      XCTAssertNil(id.typeAnnotation)
    })
  }

  func testWildcardOptional() {
    parsePatternAndTest("_?", "_?", forPatternMatching: true, testClosure: { pttrn in
      guard let optionalPattern = pttrn as? OptionalPattern,
        case .wildcard = optionalPattern.kind
      else {
        XCTFail("Failed in parsing an optional pattern with wildcard.")
        return
      }
    })
  }

  func testEnumCasePatternOptional() {
    let enumCases = [
      ".foo",
      "A.b",
      ".foo()",
      ".foo(a, b)",
      "Foo.bar(a, b)",
    ]
    for enumCaseString in enumCases {
      let optEnumCase = "\(enumCaseString)?"
      parsePatternAndTest(optEnumCase, optEnumCase, forPatternMatching: true, testClosure: { pttrn in
        guard let optionalPattern = pttrn as? OptionalPattern,
          case .enumCase(let enumCase) = optionalPattern.kind
        else {
          XCTFail("Failed in parsing an optional pattern with enum-case.")
          return
        }

        XCTAssertEqual(enumCase.textDescription, enumCaseString)
      })
    }
  }

  func testTuplePatternOptional() {
    let tuples = [
      "()",
      "(a)",
      "(a, b)",
      "(a?, b?)",
    ]
    for tupleString in tuples {
      let optTuple = "\(tupleString)?"
      parsePatternAndTest(optTuple, optTuple, forPatternMatching: true, testClosure: { pttrn in
        guard let optionalPattern = pttrn as? OptionalPattern,
          case .tuple(let tuple) = optionalPattern.kind
        else {
          XCTFail("Failed in parsing an optional pattern with enum-case.")
          return
        }

        XCTAssertEqual(tuple.textDescription, tupleString)
      })
    }
  }

  func testSourceRange() {
    parsePatternAndTest("foo?", "foo?", testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 5))
    })
    parsePatternAndTest("_?", "_?", forPatternMatching: true, testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 3))
    })
    parsePatternAndTest(".foo?", ".foo?", forPatternMatching: true, testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 6))
    })
    parsePatternAndTest("(x, y)?", "(x, y)?", forPatternMatching: true, testClosure: { pttrn in
      XCTAssertEqual(pttrn.sourceRange, getRange(1, 1, 1, 8))
    })
  }

  static var allTests = [
    ("testIdentifierOptional", testIdentifierOptional),
    ("testWildcardOptional", testWildcardOptional),
    ("testEnumCasePatternOptional", testEnumCasePatternOptional),
    ("testTuplePatternOptional", testTuplePatternOptional),
    ("testSourceRange", testSourceRange),
  ]
}
