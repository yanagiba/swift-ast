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

func specArrayType() {
  let parser = Parser()

  describe("Parse one dimension array type") {
    $0.it("should return an array type with a type identifier") {
      parser.setupTestCode("[foo.bar]")
      guard let arrayType = try? parser.parseArrayType() else {
        throw failure("Failed in getting an array type.")
      }
      guard let typeIdentifier = arrayType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 2
      try expect(typeIdentifier.names[0]) == "foo"
      try expect(typeIdentifier.names[1]) == "bar"
    }
  }

  describe("Parse two dimensions array type") {
    $0.it("should return a two dimension array type") {
      parser.setupTestCode("[[foo]]")
      guard let arrayType = try? parser.parseArrayType() else {
        throw failure("Failed in getting an array type.")
      }
      guard let innerArrayType = arrayType.type as? ArrayType else {
        throw failure("Failed in getting an inner array type.")
      }
      guard let typeIdentifier = innerArrayType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse three dimensions array type") {
    $0.it("should return a three dimension array type") {
      parser.setupTestCode("[[[Int]]]")
      guard let arrayType = try? parser.parseArrayType() else {
        throw failure("Failed in getting an array type.")
      }
      guard let innerArrayType = arrayType.type as? ArrayType else {
        throw failure("Failed in getting an inner array type.")
      }
      guard let innerInnerArrayType = innerArrayType.type as? ArrayType else {
        throw failure("Failed in getting an inner inner array type.")
      }
      guard let typeIdentifier = innerInnerArrayType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "Int"
    }
  }

  describe("Parse an array type with dictionary type") {
    $0.it("should return that dictionary type with key type array and value type array") {
      parser.setupTestCode("[[a: b]]")
      guard let arrayType = try? parser.parseArrayType() else {
        throw failure("Failed in getting an array type.")
      }
      guard let dictType = arrayType.type as? DictionaryType else {
        throw failure("Failed in getting a dictionary type.")
      }
      guard let keyType = dictType.keyType as? TypeIdentifier, valueType = dictType.valueType as? TypeIdentifier else {
        throw failure("Failed in getting type identifiers.")
      }
      try expect(keyType.names.count) == 1
      try expect(keyType.names[0]) == "a"
      try expect(valueType.names.count) == 1
      try expect(valueType.names[0]) == "b"
    }
  }
}
