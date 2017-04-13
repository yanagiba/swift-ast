/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class ParserTupleTypeTests: XCTestCase {
  func testElementsWithTypeOnly() {
    parseTypeAndTest("()", "()")
    parseTypeAndTest("(foo)", "(foo)")
    parseTypeAndTest("(foo, bar)", "(foo, bar)")
    parseTypeAndTest("(foo, bar?, [key: value], (a) -> b, ())",
      "(foo, Optional<bar>, Dictionary<key, value>, (a) -> b, ())")
  }

  func testElementsWithName() {
    parseTypeAndTest("(foo: bar)", "(foo: bar)")
    parseTypeAndTest("(p1: foo, p2:bar?, p3   :   [key: value], p4    :(a) -> b, p5: ())",
      "(p1: foo, p2: Optional<bar>, p3: Dictionary<key, value>, p4: (a) -> b, p5: ())")
    parseTypeAndTest("(p1: @a foo, p2:bar?, p3   :   @x @y @z [key: value], p4    :(a) -> b, p5: inout ())",
      "(p1: @a foo, p2: Optional<bar>, p3: @x @y @z Dictionary<key, value>, p4: (a) -> b, p5: inout ())")
  }

  func testSourceRange() {
    parseTypeAndTest("()", "()", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 3))
    })
    parseTypeAndTest("(foo, bar)", "(foo, bar)", testClosure: { type in
      XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 11))
    })
    parseTypeAndTest(
      "(p1: @a foo, p2:bar?, p3   :   @x @y @z [key: value], p4    :(a) -> b, p5: inout ())",
      "(p1: @a foo, p2: Optional<bar>, p3: @x @y @z Dictionary<key, value>, p4: (a) -> b, p5: inout ())",
      testClosure: { type in
        XCTAssertEqual(type.sourceRange, getRange(1, 1, 1, 85))
      }
    )
  }

  static var allTests = [
    ("testElementsWithTypeOnly", testElementsWithTypeOnly),
    ("testElementsWithName", testElementsWithName),
    ("testSourceRange", testSourceRange),
  ]
}
