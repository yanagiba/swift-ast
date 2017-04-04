/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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
@testable import LexerTests
@testable import ParserTests

class ZTests: XCTestCase {
  // Note: tests in this file should always run last,
  // so that we can debug individual tests easily

  func testCanary() {
    XCTAssertTrue(true)
  }

  func testOne() {
    parseExpressionAndTest(
      "\"\\(casesText.joined())\"",
      "\"\\(casesText.joined())\"")
    parseExpressionAndTest(
      "\"\\(casesText.joined(separator: \", \"))\"",
      "\"\\(casesText.joined(separator: \", \"))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.joined(separator: \", \")))\"",
      "\"(\\(casesText.joined(separator: \", \")))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.joined(separator: \", \"))foo)\"",
      "\"(\\(casesText.joined(separator: \", \"))foo)\"")
    parseExpressionAndTest(
      "\"(\\(casesText.map { $0.upperCased() }))\"",
      "\"(\\(casesText.map { $0.upperCased() }))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.map { $0.upperCased() }.foo))\"",
      "\"(\\(casesText.map { $0.upperCased() }.foo))\"")
    parseExpressionAndTest(
      "\"(\\(casesText.map { $0.upperCased() }.foo()))\"",
      "\"(\\(casesText.map { $0.upperCased() }.foo()))\"")
  }

  static var allTests = [
    ("testCanary", testCanary),
    ("testOne", testOne),
  ]
}
