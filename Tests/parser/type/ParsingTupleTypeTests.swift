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

class ParsingTupleTypeTests: XCTestCase {
  let parser = Parser()

  func testParseTupleTypeWithNoElement() {
    parser.setupTestCode("()")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 0)
  }

  func testParseTupleTypeWithOneElement() {
    parser.setupTestCode("(foo)")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 1)
    XCTAssertNil(tupleType.elements[0].name)
    guard let typeIdentifier = tupleType.elements[0].type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "foo")
    XCTAssertEqual(tupleType.elements[0].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[0].isInOutParameter)
  }

  func testParseTupleTypeWithTwoElements() {
    parser.setupTestCode("(foo, bar)")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 2)
    XCTAssertNil(tupleType.elements[0].name)
    XCTAssertNil(tupleType.elements[1].name)
    guard let typeIdentifier1 = tupleType.elements[0].type as? TypeIdentifier, typeIdentifier2 = tupleType.elements[1].type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier1.names.count, 1)
    XCTAssertEqual(typeIdentifier1.names[0], "foo")
    XCTAssertEqual(typeIdentifier2.names.count, 1)
    XCTAssertEqual(typeIdentifier2.names[0], "bar")
    XCTAssertEqual(tupleType.elements[0].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[0].isInOutParameter)
    XCTAssertEqual(tupleType.elements[1].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[1].isInOutParameter)
  }

  func testParseTupleTypeWithMultipleElements() {
    parser.setupTestCode("(foo, bar?, [key: value], a -> b, ())")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 5)
    XCTAssertNil(tupleType.elements[0].name)
    guard tupleType.elements[0].type is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertNil(tupleType.elements[1].name)
    guard tupleType.elements[1].type is OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
    XCTAssertNil(tupleType.elements[2].name)
    guard tupleType.elements[2].type is DictionaryType else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    XCTAssertNil(tupleType.elements[3].name)
    guard tupleType.elements[3].type is FunctionType else {
      XCTFail("Failed in getting a function type.")
      return
    }
    XCTAssertNil(tupleType.elements[4].name)
    guard tupleType.elements[4].type is TupleType else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
  }

  func testParseTupleTypeWithMultipleElementsThatSomeHaveAttributesAndSomeHaveInoutParameters() {
    parser.setupTestCode("(@a @b @c inout foo, bar?, inout [key: value], @test a -> b, ())")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 5)
    XCTAssertNil(tupleType.elements[0].name)
    XCTAssertEqual(tupleType.elements[0].attributes.count, 3)
    XCTAssertEqual(tupleType.elements[0].attributes[0].name, "a")
    XCTAssertEqual(tupleType.elements[0].attributes[1].name, "b")
    XCTAssertEqual(tupleType.elements[0].attributes[2].name, "c")
    XCTAssertTrue(tupleType.elements[0].isInOutParameter)
    guard tupleType.elements[0].type is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertNil(tupleType.elements[1].name)
    XCTAssertEqual(tupleType.elements[1].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[1].isInOutParameter)
    guard tupleType.elements[1].type is OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
    XCTAssertNil(tupleType.elements[2].name)
    XCTAssertEqual(tupleType.elements[2].attributes.count, 0)
    XCTAssertTrue(tupleType.elements[2].isInOutParameter)
    guard tupleType.elements[2].type is DictionaryType else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    XCTAssertNil(tupleType.elements[3].name)
    XCTAssertEqual(tupleType.elements[3].attributes.count, 1)
    XCTAssertEqual(tupleType.elements[3].attributes[0].name, "test")
    XCTAssertFalse(tupleType.elements[3].isInOutParameter)
    guard tupleType.elements[3].type is FunctionType else {
      XCTFail("Failed in getting a function type.")
      return
    }
    XCTAssertNil(tupleType.elements[4].name)
    XCTAssertEqual(tupleType.elements[4].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[4].isInOutParameter)
    guard tupleType.elements[4].type is TupleType else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
  }

  func testParseTupleTypeWithOneNamedElement() {
    parser.setupTestCode("(foo: bar)")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 1)
    XCTAssertEqual(tupleType.elements[0].name, "foo")
    guard let typeIdentifier = tupleType.elements[0].type as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.names.count, 1)
    XCTAssertEqual(typeIdentifier.names[0], "bar")
    XCTAssertEqual(tupleType.elements[0].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[0].isInOutParameter)
  }

  func testParseTupleTypeWithMultipleElementsWithNames() {
    parser.setupTestCode("(p1: foo, p2:bar?, p3   :   [key: value], p4    :a -> b, p5: ())")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 5)
    XCTAssertEqual(tupleType.elements[0].name, "p1")
    guard tupleType.elements[0].type is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(tupleType.elements[1].name, "p2")
    guard tupleType.elements[1].type is OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
    XCTAssertEqual(tupleType.elements[2].name, "p3")
    guard tupleType.elements[2].type is DictionaryType else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    XCTAssertEqual(tupleType.elements[3].name, "p4")
    guard tupleType.elements[3].type is FunctionType else {
      XCTFail("Failed in getting a function type.")
      return
    }
    XCTAssertEqual(tupleType.elements[4].name, "p5")
    guard tupleType.elements[4].type is TupleType else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
  }

  func testParseTupleTypeWithNamesAndAttributesThatSomeHaveInputParameters() {
    parser.setupTestCode("(inout p1: @a foo, p2:bar?, p3   :   @x @y @z [key: value], inout p4    :a -> b, p5: ())")
    guard let tupleType = try? parser.parseTupleType() else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
    XCTAssertEqual(tupleType.elements.count, 5)
    XCTAssertEqual(tupleType.elements[0].name, "p1")
    XCTAssertEqual(tupleType.elements[0].attributes.count, 1)
    XCTAssertEqual(tupleType.elements[0].attributes[0].name, "a")
    XCTAssertTrue(tupleType.elements[0].isInOutParameter)
    guard tupleType.elements[0].type is TypeIdentifier else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(tupleType.elements[1].name, "p2")
    XCTAssertEqual(tupleType.elements[1].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[1].isInOutParameter)
    guard tupleType.elements[1].type is OptionalType else {
      XCTFail("Failed in getting an optional type.")
      return
    }
    XCTAssertEqual(tupleType.elements[2].name, "p3")
    XCTAssertEqual(tupleType.elements[2].attributes.count, 3)
    XCTAssertEqual(tupleType.elements[2].attributes[0].name, "x")
    XCTAssertEqual(tupleType.elements[2].attributes[1].name, "y")
    XCTAssertEqual(tupleType.elements[2].attributes[2].name, "z")
    XCTAssertFalse(tupleType.elements[2].isInOutParameter)
    guard tupleType.elements[2].type is DictionaryType else {
      XCTFail("Failed in getting a dictionary type.")
      return
    }
    XCTAssertEqual(tupleType.elements[3].name, "p4")
    XCTAssertEqual(tupleType.elements[3].attributes.count, 0)
    XCTAssertTrue(tupleType.elements[3].isInOutParameter)
    guard tupleType.elements[3].type is FunctionType else {
      XCTFail("Failed in getting a function type.")
      return
    }
    XCTAssertEqual(tupleType.elements[4].name, "p5")
    XCTAssertEqual(tupleType.elements[4].attributes.count, 0)
    XCTAssertFalse(tupleType.elements[4].isInOutParameter)
    guard tupleType.elements[4].type is TupleType else {
      XCTFail("Failed in getting a tuple type.")
      return
    }
  }
}
