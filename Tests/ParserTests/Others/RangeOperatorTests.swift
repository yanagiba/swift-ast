/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

class RangeOperatorTests: XCTestCase {
  func testClosedRangeOperators() {
    parseExpressionAndTest("foo[0...1]", "foo[0 ... 1]")
    parseStatementAndTest("for i in 0...1 {}", "for i in 0 ... 1 {}")
  }

  func testHalfOpenRangeOperators() {
    parseExpressionAndTest("foo[0..<1]", "foo[0 ..< 1]")
    parseDeclarationAndTest("let a = 0 ..< 1", "let a = 0 ..< 1")
  }

  func testOneSidedRanges() {
    parseExpressionAndTest("foo[0...]", "foo[0...]")
    parseExpressionAndTest("foo[..<1]", "foo[..<1]")
    parseStatementAndTest("for i in 0... {}", "for i in 0... {}")
    parseDeclarationAndTest("let a = ..<1", "let a = ..<1")
  }

  static var allTests = [
    ("testClosedRangeOperators", testClosedRangeOperators),
    ("testHalfOpenRangeOperators", testHalfOpenRangeOperators),
    ("testOneSidedRanges", testOneSidedRanges),
  ]
}
