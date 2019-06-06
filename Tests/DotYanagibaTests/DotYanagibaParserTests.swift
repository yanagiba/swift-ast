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

class DotYanagibaParserTests : XCTestCase {
  let parser = DotYanagibaParser()

  func testIntOption() {
    let result = parser.parse(content: """
    abc:
      a: 1
      b: 2
      c: 3
      b: 4
    """)
    guard let abc = result.modules["abc"] else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(abc.options["a"], DotYanagiba.Module.Option.int(1))
    XCTAssertEqual(abc.options["b"], DotYanagiba.Module.Option.int(4))
    XCTAssertEqual(abc.options["c"], DotYanagiba.Module.Option.int(3))
    XCTAssertNil(abc.options["d"])
    XCTAssertNil(result.modules["xyz"])
  }

  func testStringOption() {
    let result = parser.parse(content: """
    abc:
      a: a
      b: b
      c: c
      b: d
    """)
    guard let abc = result.modules["abc"] else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(abc.options["a"], DotYanagiba.Module.Option.string("a"))
    XCTAssertEqual(abc.options["b"], DotYanagiba.Module.Option.string("d"))
    XCTAssertEqual(abc.options["c"], DotYanagiba.Module.Option.string("c"))
    XCTAssertNil(abc.options["d"])
    XCTAssertNil(result.modules["xyz"])
  }

  func testListIntOption() {
    let result = parser.parse(content: """
    abc:
      list:
        - 1
        - 2
        - 3
    """)
    guard let abc = result.modules["abc"] else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(abc.options["list"], DotYanagiba.Module.Option.listInt([1, 2, 3]))
  }

  func testListStringOption() {
    let result = parser.parse(content: """
    abc:
      list:
        - a
        - b
        - c
    """)
    guard let abc = result.modules["abc"] else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(abc.options["list"], DotYanagiba.Module.Option.listString(["a", "b", "c"]))
  }

  func testDictIntOption() {
    let result = parser.parse(content: """
    abc:
      dict:
        - a: 1
        - b: 2
        - c: 3
    """)
    guard let abc = result.modules["abc"],
      let dict = abc.options["dict"],
      case .dictInt(let dictInt) = dict
    else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(dictInt["a"], 1)
    XCTAssertEqual(dictInt["b"], 2)
    XCTAssertEqual(dictInt["c"], 3)
  }

  func testDictStringOption() {
    let result = parser.parse(content: """
    abc:
      dict:
        - a: a
        - b: b
        - c: c
    """)
    guard let abc = result.modules["abc"],
      let dict = abc.options["dict"],
      case .dictString(let dictString) = dict
    else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(dictString["a"], "a")
    XCTAssertEqual(dictString["b"], "b")
    XCTAssertEqual(dictString["c"], "c")
  }

  func testMultiModules() {
    let result = parser.parse(content: """
    abc:
      a: 1
      b: 2
      c: 3
      b: 4
    xyz:
      a: a
      b: b
      c: c
      b: d
    """)

    guard let abc = result.modules["abc"] else {
      XCTFail("Failed in getting configurations for `abc` module.")
      return
    }
    XCTAssertEqual(abc.options["a"], DotYanagiba.Module.Option.int(1))
    XCTAssertEqual(abc.options["b"], DotYanagiba.Module.Option.int(4))
    XCTAssertEqual(abc.options["c"], DotYanagiba.Module.Option.int(3))
    XCTAssertNil(abc.options["d"])

    guard let xyz = result.modules["xyz"] else {
      XCTFail("Failed in getting configurations for `xyz` module.")
      return
    }
    XCTAssertEqual(xyz.options["a"], DotYanagiba.Module.Option.string("a"))
    XCTAssertEqual(xyz.options["b"], DotYanagiba.Module.Option.string("d"))
    XCTAssertEqual(xyz.options["c"], DotYanagiba.Module.Option.string("c"))
    XCTAssertNil(xyz.options["d"])

    XCTAssertNil(result.modules["foobar"])
  }

  static var allTests = [
    ("testIntOption", testIntOption),
    ("testStringOption", testStringOption),
    ("testListIntOption", testListIntOption),
    ("testListStringOption", testListStringOption),
    ("testDictIntOption", testDictIntOption),
    ("testDictStringOption", testDictStringOption),
    ("testMultiModules", testMultiModules),
  ]
}
