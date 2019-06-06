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

class StringTTYColorTests : XCTestCase {
  func testColorTTYCode() {
    XCTAssertEqual(TTYColor.black.ttyCode, "\u{001B}[30m")
    XCTAssertEqual(TTYColor.red.ttyCode, "\u{001B}[31m")
    XCTAssertEqual(TTYColor.green.ttyCode, "\u{001B}[32m")
    XCTAssertEqual(TTYColor.yellow.ttyCode, "\u{001B}[33m")
    XCTAssertEqual(TTYColor.blue.ttyCode, "\u{001B}[34m")
    XCTAssertEqual(TTYColor.magenta.ttyCode, "\u{001B}[35m")
    XCTAssertEqual(TTYColor.cyan.ttyCode, "\u{001B}[36m")
    XCTAssertEqual(TTYColor.white.ttyCode, "\u{001B}[37m")
    XCTAssertEqual(TTYColor.default.ttyCode, "\u{001B}[0m")
  }

  func testColoredString() {
    XCTAssertEqual("abc".colored(with: .black), "\u{001B}[30mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .red), "\u{001B}[31mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .green), "\u{001B}[32mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .yellow), "\u{001B}[33mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .blue), "\u{001B}[34mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .magenta), "\u{001B}[35mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .cyan), "\u{001B}[36mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .white), "\u{001B}[37mabc\u{001B}[0m")
    XCTAssertEqual("abc".colored(with: .default), "\u{001B}[0mabc\u{001B}[0m")
  }

  static var allTests = [
    ("testColorTTYCode", testColorTTYCode),
    ("testColoredString", testColoredString),
  ]
}
