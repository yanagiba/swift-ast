/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

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

@testable import Bocho

class DotYanagibaMergeTests : XCTestCase {
  let parser = DotYanagibaParser()

  func testCombine() {
    let result1 = parser.parse(content: """
    abc:
      a: 1
    """)

    let result2 = parser.parse(content: """
    abc:
      b: 2
    xyz:
      a: a
      b: b
    """)

    let result = DotYanagiba.merge(result1, with: result2)

    guard let abc = result.modules["abc"] else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(abc.options["a"], DotYanagiba.Module.Option.int(1))
    XCTAssertEqual(abc.options["b"], DotYanagiba.Module.Option.int(2))

    guard let xyz = result.modules["xyz"] else {
      XCTFail("Failed in getting configurations for `xyz` module.")
      return
    }
    XCTAssertEqual(xyz.options["a"], DotYanagiba.Module.Option.string("a"))
    XCTAssertEqual(xyz.options["b"], DotYanagiba.Module.Option.string("b"))
  }

  func testResolve() {
    let result1 = parser.parse(content: """
    abc:
      a: 1
    xyz:
      a: 3
      b: b
    """)

    let result2 = parser.parse(content: """
    abc:
      a: 2
      c: 4
    xyz:
      a: a
    """)

    let result12 = DotYanagiba.merge(result1, with: result2)
    XCTAssertEqual(result12.modules["abc"]?.options["a"], DotYanagiba.Module.Option.int(2))
    XCTAssertEqual(result12.modules["abc"]?.options["c"], DotYanagiba.Module.Option.int(4))
    XCTAssertEqual(result12.modules["xyz"]?.options["a"], DotYanagiba.Module.Option.string("a"))
    XCTAssertEqual(result12.modules["xyz"]?.options["b"], DotYanagiba.Module.Option.string("b"))

    let result21 = DotYanagiba.merge(result2, with: result1)
    XCTAssertEqual(result21.modules["abc"]?.options["a"], DotYanagiba.Module.Option.int(1))
    XCTAssertEqual(result12.modules["abc"]?.options["c"], DotYanagiba.Module.Option.int(4))
    XCTAssertEqual(result21.modules["xyz"]?.options["a"], DotYanagiba.Module.Option.int(3))
    XCTAssertEqual(result21.modules["xyz"]?.options["b"], DotYanagiba.Module.Option.string("b"))
  }

  static var allTests = [
    ("testCombine", testCombine),
    ("testResolve", testResolve),
  ]
}
