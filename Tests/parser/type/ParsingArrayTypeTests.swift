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

class ParsingArrayTypeTests: XCTestCase {
  let parser = Parser()

  func testParseArrayTypeWithOneDimension() {
    parser.setupTestCode("[foo.bar]")
    guard let arrayType = try? parser.parseArrayType() else {
      XCTFail("Failed in getting an array type.")
      return
    }
    guard let typeIdentifier = arrayType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 2)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
    XCTAssertEqual(typeIdentifier.names[1], "bar")
  }

  func testParseArrayTypeWithTwoDimensions() {
    parser.setupTestCode("[[foo]]")
    guard let arrayType = try? parser.parseArrayType() else {
      XCTFail("Failed in getting an array type.")
      return
    }
    guard let innerArrayType = arrayType.type as? ArrayType else {
      XCTFail("Failed in getting an inner array type.")
      return
    }
    guard let typeIdentifier = innerArrayType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
  }

  func testParseArrayTypeWithThreeDimensions() {
    parser.setupTestCode("[[[Int]]]")
    guard let arrayType = try? parser.parseArrayType() else {
      XCTFail("Failed in getting an array type.")
      return
    }
    guard let innerArrayType = arrayType.type as? ArrayType else {
      XCTFail("Failed in getting an inner array type.")
      return
    }
    guard let innerInnerArrayType = innerArrayType.type as? ArrayType else {
      XCTFail("Failed in getting an inner inner array type.")
      return
    }
    guard let typeIdentifier = innerInnerArrayType.type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "Int")
  }

  func testParseArrayTypeWithDictionaryType() {
    parser.setupTestCode("[[a: b]]")
    guard let arrayType = try? parser.parseArrayType() else {
      XCTFail("Failed in getting an array type.")
      return
    }
    guard let dictType = arrayType.type as? DictionaryType else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    guard let keyType = dictType.keyType as? TypeIdentifier, valueType = dictType.valueType as? TypeIdentifier else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(keyType.names.count, 1)
    XCTAssertEqual(keyType.names[0], "a")
    XCTAssertEqual(valueType.names.count, 1)
    XCTAssertEqual(valueType.names[0], "b")
  }
}
