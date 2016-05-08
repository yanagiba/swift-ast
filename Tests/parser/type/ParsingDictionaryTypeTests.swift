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

class ParsingDictionaryTypeTests: XCTestCase {
  let parser = Parser()

  func testParseDictionaryType() {
    parser.setupTestCode("[foo: bar]")
    guard let dictType = try? parser.parseDictionaryType() else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    guard let keyType = dictType.keyType as? TypeIdentifier, valueType = dictType.valueType as? TypeIdentifier else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(keyType.names.count, 1)
    XCTAssertEqual(keyType.names[0], "foo")
    XCTAssertEqual(valueType.names.count, 1)
    XCTAssertEqual(valueType.names[0], "bar")
  }

  func testParseDictionaryTypeWithDictionaryTypeAsKeyTypeAndValueType() {
    parser.setupTestCode("[[a: b]: [x: y]]")
    guard let dictType = try? parser.parseDictionaryType() else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    guard let keyType = dictType.keyType as? DictionaryType, valueType = dictType.valueType as? DictionaryType else {
      XCTFail("Failed in getting dictionary types.")
      return
    }

    guard let
      keyKeyType = keyType.keyType as? TypeIdentifier,
      keyValueType = keyType.valueType as? TypeIdentifier,
      valueKeyType = valueType.keyType as? TypeIdentifier,
      valueValueType = valueType.valueType as? TypeIdentifier
    else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(keyKeyType.names.count, 1)
    XCTAssertEqual(keyKeyType.names[0], "a")
    XCTAssertEqual(keyValueType.names.count, 1)
    XCTAssertEqual(keyValueType.names[0], "b")
    XCTAssertEqual(valueKeyType.names.count, 1)
    XCTAssertEqual(valueKeyType.names[0], "x")
    XCTAssertEqual(valueValueType.names.count, 1)
    XCTAssertEqual(valueValueType.names[0], "y")
  }

  func testParseDictionaryTypeWithArrayTypeAsKeyTypeAndValueType() {
    parser.setupTestCode("[[a]: [b]]")
    guard let dictType = try? parser.parseDictionaryType() else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    guard let keyType = dictType.keyType as? ArrayType, valueType = dictType.valueType as? ArrayType else {
      XCTFail("Failed in getting array types.")
      return
    }

    guard let
      keyArrayType = keyType.type as? TypeIdentifier,
      valueArrayType = valueType.type as? TypeIdentifier
    else {
      XCTFail("Failed in getting type identifiers.")
      return
    }
    XCTAssertEqual(keyArrayType.names.count, 1)
    XCTAssertEqual(keyArrayType.names[0], "a")
    XCTAssertEqual(valueArrayType.names.count, 1)
    XCTAssertEqual(valueArrayType.names[0], "b")
  }
}
