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

class CLIOptionTests : XCTestCase {
  func testNoOption() {
    let option = CLIOption(["a"])
    XCTAssertEqual(option.arguments, ["a"])
    XCTAssertFalse(option.contains("a"))
    XCTAssertEqual(option.arguments, ["a"])
  }

  func testFlags() {
    let option = CLIOption(["a", "-b", "c", "--d", "e"])
    XCTAssertEqual(option.arguments, ["a", "-b", "c", "--d", "e"])
    XCTAssertTrue(option.contains("b"))
    XCTAssertTrue(option.contains("d"))
    XCTAssertTrue(option.contains("-d"))
    XCTAssertEqual(option.arguments, ["a", "-b", "c", "--d", "e"])
  }

  func testStringOptions() {
    let option = CLIOption(["a", "-b", "c", "--d", "e", "-f"])
    XCTAssertEqual(option.arguments, ["a", "-b", "c", "--d", "e", "-f"])
    XCTAssertEqual(option.readAsString("b"), "c")
    XCTAssertEqual(option.readAsString("-d"), "e")
    XCTAssertNil(option.readAsString("f"))
    XCTAssertNil(option.readAsString("g"))
    XCTAssertEqual(option.arguments, ["a", "-f"])
  }

  func testDictionaryOptions() {
    let option = CLIOption(["a", "-b", "c=1", "--d", "e1=foo,e2=bar", "-f"])
    XCTAssertEqual(option.arguments, ["a", "-b", "c=1", "--d", "e1=foo,e2=bar", "-f"])
    guard let b = option.readAsDictionary("b") else {
      XCTFail("Failed in reading option `b` as a dictionary.")
      return
    }
    XCTAssertEqual(b["c"] as? String, "1")
    guard let d = option.readAsDictionary("-d") else {
      XCTFail("Failed in reading option `d` as a dictionary.")
      return
    }
    XCTAssertEqual(d["e1"] as? String, "foo")
    XCTAssertEqual(d["e2"] as? String, "bar")
    XCTAssertNil(option.readAsDictionary("f"))
    XCTAssertNil(option.readAsDictionary("g"))
    XCTAssertEqual(option.arguments, ["a", "-f"])
  }

  static var allTests = [
    ("testNoOption", testNoOption),
    ("testFlags", testFlags),
    ("testStringOptions", testStringOptions),
    ("testDictionaryOptions", testDictionaryOptions),
  ]
}
