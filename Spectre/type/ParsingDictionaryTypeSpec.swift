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

import Spectre

@testable import parser
@testable import ast

func specDictionaryType() {
  let parser = Parser()

  describe("Parse a dictionary type") {
    $0.it("should return that dictionary type") {
      parser.setupTestCode("[foo: bar]")
      guard let dictType = try? parser.parseDictionaryType() else {
        throw failure("Failed in getting a dictionary type.")
      }
      guard let keyType = dictType.keyType as? TypeIdentifier, valueType = dictType.valueType as? TypeIdentifier else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(keyType.names.count) == 1
      try expect(keyType.names[0]) == "foo"
      try expect(valueType.names.count) == 1
      try expect(valueType.names[0]) == "bar"
    }
  }

  describe("Parse a dictionary type with dictionary type as key type and value type") {
    $0.it("should return that dictionary type with key type dictionary and value type dictionary") {
      parser.setupTestCode("[[a: b]: [x: y]]")
      guard let dictType = try? parser.parseDictionaryType() else {
        throw failure("Failed in getting a dictionary type.")
      }
      guard let keyType = dictType.keyType as? DictionaryType, valueType = dictType.valueType as? DictionaryType else {
        throw failure("Failed in getting dictionary types.")
      }

      guard let
        keyKeyType = keyType.keyType as? TypeIdentifier,
        keyValueType = keyType.valueType as? TypeIdentifier,
        valueKeyType = valueType.keyType as? TypeIdentifier,
        valueValueType = valueType.valueType as? TypeIdentifier
      else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(keyKeyType.names.count) == 1
      try expect(keyKeyType.names[0]) == "a"
      try expect(keyValueType.names.count) == 1
      try expect(keyValueType.names[0]) == "b"
      try expect(valueKeyType.names.count) == 1
      try expect(valueKeyType.names[0]) == "x"
      try expect(valueValueType.names.count) == 1
      try expect(valueValueType.names[0]) == "y"
    }
  }

  describe("Parse a dictionary type with array type as key type and value type") {
    $0.it("should return that dictionary type with key type array and value type array") {
      parser.setupTestCode("[[a]: [b]]")
      guard let dictType = try? parser.parseDictionaryType() else {
        throw failure("Failed in getting a dictionary type.")
      }
      guard let keyType = dictType.keyType as? ArrayType, valueType = dictType.valueType as? ArrayType else {
        throw failure("Failed in getting array types.")
      }

      guard let
        keyArrayType = keyType.type as? TypeIdentifier,
        valueArrayType = valueType.type as? TypeIdentifier
      else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(keyArrayType.names.count) == 1
      try expect(keyArrayType.names[0]) == "a"
      try expect(valueArrayType.names.count) == 1
      try expect(valueArrayType.names[0]) == "b"
    }
  }
}
