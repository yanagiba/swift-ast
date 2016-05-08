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

class ParsingTypeTests: XCTestCase {
  let parser = Parser()

  func testParseTypeWithIllBeginningToken() {
    parser.setupTestCode(";")
    do {
      try parser.parseType()
    } catch {
      return
    }
    XCTFail("Failed in throwing errors.")
  }

  func testParseTypeIdentifier() {
    parser.setupTestCode("foo.bar.a.b.c")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
  }

  func testParseArrayType() {
    parser.setupTestCode("[foo]")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is ArrayType else {
      XCTFail("Failed in getting an array type.")
      return
    }
  }

  func testParseDictionaryType() {
    parser.setupTestCode("[String: Int]")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is DictionaryType else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
  }

  func testParseOptionalType() {
    parser.setupTestCode("Int?")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
  }

  func testParseImplicitlyUnwrappedOptionalType() {
    parser.setupTestCode("Int!")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is ImplicitlyUnwrappedOptionalType else {
      XCTFail("Failed in getting an implicitly unwrapped optional type.")
      return
    }
  }

  func testParseFunctionType() {
    parser.setupTestCode("String -> Int")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is FunctionType else {
      XCTFail("Failed in getting a function type.")
      return
    }
  }

  func testParseProtocolCompositionType() {
    parser.setupTestCode("protocol<ProtocolA, ProtocolB>")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is ProtocolCompositionType else {
      XCTFail("Failed in getting a protocol composition type.")
      return
    }
  }

  func testParseMetatypeType() {
    parser.setupTestCode("UIKit.UITableViewDataSource.Protocol")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is MetatypeType else {
      XCTFail("Failed in getting a metatype type.")
      return
    }
  }

  func testParseTupleType() {
    parser.setupTestCode("(String, Int, Double)")
    guard let type = try? parser.parseType() else {
      XCTFail("Failed in getting a type.")
      return
    }
    guard type is TupleType else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
  }
}
