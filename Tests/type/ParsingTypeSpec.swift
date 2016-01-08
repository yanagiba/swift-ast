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

func specType() {
  let parser = Parser()

  describe("Parse type with ill beginning token") {
    $0.it("should throw error") {
      parser.setupTestCode(";")
      try expect(parser.parseType()).toThrow()
    }
  }

  describe("Parse type identifier") {
    $0.it("should return a type identifier") {
      parser.setupTestCode("foo.bar.a.b.c")
      guard let type = try? parser.parseType() else {
        throw failure("Failed in getting a type.")
      }
      guard type is TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
    }
  }

  describe("Parse an array type") {
    $0.it("should return an array type") {
      parser.setupTestCode("[foo]")
      guard let type = try? parser.parseType() else {
        throw failure("Failed in getting a type.")
      }
      guard type is ArrayType else {
        throw failure("Failed in getting an array type.")
      }
    }
  }

  describe("Parse a dictionary type") {
    $0.it("should return a dictionary type") {
      parser.setupTestCode("[String: Int]")
      guard let type = try? parser.parseType() else {
        throw failure("Failed in getting a type.")
      }
      guard type is DictionaryType else {
        throw failure("Failed in getting a dictionary type.")
      }
    }
  }
}
