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

class GenericOpeningChevronTests: XCTestCase {
  func testArgumentOpeningChevronImmediatelyFollow() {
    let result = parse("let a: Array<Array<Int>>")
    XCTAssertEqual(result.statements[0].textDescription, "let a: Array<Array<Int>>")
  }

  func testArgumentOpeningChevronNoNeedImmediatelyFollow() {
    let result = parse("let a: Array <Array <Int> >")
    XCTAssertEqual(result.statements[0].textDescription, "let a: Array<Array<Int>>")
  }

  func testParameterOpeningChevronImmediatelyFollow() {
    let result = parse("func simpleMax<T: Comparable>(_ x: T, _ y: T) -> T")
    XCTAssertEqual(result.statements[0].textDescription, "func simpleMax<T: Comparable>(_ x: T, _ y: T) -> T")
  }

  func testParameterOpeningChevronNoNeedImmediatelyFollow() {
    let result = parse("func simpleMax <T: Comparable>(_ x: T, _ y: T) -> T")
    XCTAssertEqual(result.statements[0].textDescription, "func simpleMax<T: Comparable>(_ x: T, _ y: T) -> T")
  }

  static var allTests = [
    ("testArgumentOpeningChevronImmediatelyFollow", testArgumentOpeningChevronImmediatelyFollow),
    ("testArgumentOpeningChevronNoNeedImmediatelyFollow", testArgumentOpeningChevronNoNeedImmediatelyFollow),
    ("testParameterOpeningChevronImmediatelyFollow", testParameterOpeningChevronImmediatelyFollow),
    ("testParameterOpeningChevronNoNeedImmediatelyFollow", testParameterOpeningChevronNoNeedImmediatelyFollow),
  ]
}
