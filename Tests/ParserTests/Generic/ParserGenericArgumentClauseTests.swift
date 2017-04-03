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

@testable import Parser

class ParserGenericArgumentClauseTests: XCTestCase {
  func testSingleArgument() {
    let genericParser = getParser("<String>")
    let genericArgumentClause = genericParser.parseGenericArgumentClause()
    guard let types = genericArgumentClause?.argumentList, types.count == 1 else {
      XCTFail("Failed in getting right size of argument clause.")
      return
    }
    XCTAssertEqual(types[0].textDescription, "String")
    XCTAssertEqual(genericArgumentClause?.textDescription, "<String>")
  }

  func testMultipleArguments() {
    let genericParser = getParser("<[Int], String & Double>")
    let genericArgumentClause = genericParser.parseGenericArgumentClause()
    guard let types = genericArgumentClause?.argumentList, types.count == 2 else {
      XCTFail("Failed in getting a generic argument clause.")
      return
    }
    XCTAssertEqual(types[0].textDescription, "Array<Int>")
    XCTAssertEqual(types[1].textDescription, "protocol<String, Double>")
    XCTAssertEqual(genericArgumentClause?.textDescription, "<Array<Int>, protocol<String, Double>>")
  }

  func testEndingRightChveron() {
    let genericParser = getParser("<A<B, protocol<C, D>>>")
    let genericArgumentClause = genericParser.parseGenericArgumentClause()
    guard let types = genericArgumentClause?.argumentList, types.count == 1 else {
      XCTFail("Failed in getting right size of argument clause.")
      return
    }
    XCTAssertEqual(types[0].textDescription, "A<B, protocol<C, D>>")
    XCTAssertEqual(genericArgumentClause?.textDescription, "<A<B, protocol<C, D>>>")
  }

  func testOptionalType() {
    let genericParser = getParser("<String?>")
    let genericArgumentClause = genericParser.parseGenericArgumentClause()
    guard let types = genericArgumentClause?.argumentList, types.count == 1 else {
      XCTFail("Failed in getting right size of argument clause.")
      return
    }
    XCTAssertEqual(types[0].textDescription, "Optional<String>")
    XCTAssertEqual(genericArgumentClause?.textDescription, "<Optional<String>>")
  }

  func testUnwrappedOptionalType() {
    let genericParser = getParser("<String!>")
    let genericArgumentClause = genericParser.parseGenericArgumentClause()
    guard let types = genericArgumentClause?.argumentList, types.count == 1 else {
      XCTFail("Failed in getting right size of argument clause.")
      return
    }
    XCTAssertEqual(types[0].textDescription, "ImplicitlyUnwrappedOptional<String>")
    XCTAssertEqual(genericArgumentClause?.textDescription, "<ImplicitlyUnwrappedOptional<String>>")
  }

  static var allTests = [
    ("testSingleArgument", testSingleArgument),
    ("testMultipleArguments", testMultipleArguments),
    ("testEndingRightChveron", testEndingRightChveron),
    ("testOptionalType", testOptionalType),
    ("testUnwrappedOptionalType", testUnwrappedOptionalType),
  ]
}
