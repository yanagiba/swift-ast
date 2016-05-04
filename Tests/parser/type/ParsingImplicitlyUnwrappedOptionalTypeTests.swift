/*
   Copyright 2016 Ryuichi Saito, LLC

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

@testable import parser
@testable import ast

class ParsingImplicitlyUnwrappedOptionalTypeTests: XCTestCase {
  let parser = Parser()

  func testParseImplicitlyUnwrappedOptionalType() {
    parser.setupTestCode("foo!")
    guard let implicitlyUnwrappedOptionalType = try? parser.parseImplicitlyUnwrappedOptionalType() else {
      XCTFail("Failed in getting an implicitly unwrapped optional type.")
      return
    }
    guard let typeIdentifier = implicitlyUnwrappedOptionalType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testParseImplicitlyUnwrappedOptionalTypeThatWrapsAnotherImplicitlyUnwrappedOptionalType() {
    parser.setupTestCode("foo!!")
    guard let implicitlyUnwrappedOptionalType = try? parser.parseImplicitlyUnwrappedOptionalType() else {
      XCTFail("Failed in getting an implicitly unwrapped optional type.")
      return
    }
    guard let innerImplicitlyUnwrappedOptionalType = implicitlyUnwrappedOptionalType.type as? ImplicitlyUnwrappedOptionalType else {
      XCTFail("Failed in getting an inner implicitly unwrapped optional type.")
      return
    }
    guard let typeIdentifier = innerImplicitlyUnwrappedOptionalType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testParseImplicitlyUnwrappedOptionalTypeThatWrapsAnOptionalType() {
    parser.setupTestCode("foo?!")
    guard let implicitlyUnwrappedOptionalType = try? parser.parseImplicitlyUnwrappedOptionalType() else {
      XCTFail("Failed in getting an implicitly unwrapped optional type.")
      return
    }
    guard let optionalType = implicitlyUnwrappedOptionalType.type as? OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
    guard let typeIdentifier = optionalType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testExclamationMarkDoesNotFollowTheTypeImmeidatelyShouldNotReturnParseImplicitlyUnwrappedOptionalType() {
    parser.setupTestCode("foo !")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    if type is ImplicitlyUnwrappedOptionalType {
      XCTFail("Should not be an implicitly unwrapped optional type.")
      return
    }
    guard let typeIdentifier = type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }
}
