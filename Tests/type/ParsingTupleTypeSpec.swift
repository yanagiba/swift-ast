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

func specTupleType() {
  let parser = Parser()

  describe("Parse an empty tuple") {
    $0.it("should be a tuple with no element") {
      parser.setupTestCode("()")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 0
    }
  }

  describe("Parse a tuple with one element") {
    $0.it("should be a tuple with one element") {
      parser.setupTestCode("(foo)")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 1
      try expect(tupleType.elements[0].name).to.beNil()
      guard let typeIdentifier = tupleType.elements[0].type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
      try expect(tupleType.elements[0].attributes.count) == 0
      try expect(tupleType.elements[0].isInOutParameter).to.beFalse()
    }
  }

  describe("Parse a tuple with two elements") {
    $0.it("should be a tuple with two elements") {
      parser.setupTestCode("(foo, bar)")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 2
      try expect(tupleType.elements[0].name).to.beNil()
      try expect(tupleType.elements[1].name).to.beNil()
      guard let typeIdentifier1 = tupleType.elements[0].type as? TypeIdentifier, typeIdentifier2 = tupleType.elements[1].type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier1.names.count) == 1
      try expect(typeIdentifier1.names[0]) == "foo"
      try expect(typeIdentifier2.names.count) == 1
      try expect(typeIdentifier2.names[0]) == "bar"
      try expect(tupleType.elements[0].attributes.count) == 0
      try expect(tupleType.elements[0].isInOutParameter).to.beFalse()
      try expect(tupleType.elements[1].attributes.count) == 0
      try expect(tupleType.elements[1].isInOutParameter).to.beFalse()
    }
  }

  describe("Parse a tuple with multiple elements") {
    $0.it("should be a tuple with multiple elements") {
      parser.setupTestCode("(foo, bar?, [key: value], a -> b, ())")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 5
      try expect(tupleType.elements[0].name).to.beNil()
      guard tupleType.elements[0].type is TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(tupleType.elements[1].name).to.beNil()
      guard tupleType.elements[1].type is OptionalType else {
        throw failure("Failed in getting an optional type.")
      }
      try expect(tupleType.elements[2].name).to.beNil()
      guard tupleType.elements[2].type is DictionaryType else {
        throw failure("Failed in getting a dictionary type.")
      }
      try expect(tupleType.elements[3].name).to.beNil()
      guard tupleType.elements[3].type is FunctionType else {
        throw failure("Failed in getting a function type.")
      }
      try expect(tupleType.elements[4].name).to.beNil()
      guard tupleType.elements[4].type is TupleType else {
        throw failure("Failed in getting a tuple type.")
      }
    }
  }

  describe("Parse a tuple with one named element") {
    $0.it("should be a tuple with one named element") {
      parser.setupTestCode("(foo: bar)")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 1
      try expect(tupleType.elements[0].name) == "foo"
      guard let typeIdentifier = tupleType.elements[0].type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "bar"
      try expect(tupleType.elements[0].attributes.count) == 0
      try expect(tupleType.elements[0].isInOutParameter).to.beFalse()
    }
  }

  describe("Parse a tuple with multiple elements with names") {
    $0.it("should be a tuple with multiple elements that have names") {
      parser.setupTestCode("(p1: foo, p2:bar?, p3   :   [key: value], p4    :a -> b, p5: ())")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 5
      try expect(tupleType.elements[0].name) == "p1"
      guard tupleType.elements[0].type is TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(tupleType.elements[1].name) == "p2"
      guard tupleType.elements[1].type is OptionalType else {
        throw failure("Failed in getting an optional type.")
      }
      try expect(tupleType.elements[2].name) == "p3"
      guard tupleType.elements[2].type is DictionaryType else {
        throw failure("Failed in getting a dictionary type.")
      }
      try expect(tupleType.elements[3].name) == "p4"
      guard tupleType.elements[3].type is FunctionType else {
        throw failure("Failed in getting a function type.")
      }
      try expect(tupleType.elements[4].name) == "p5"
      guard tupleType.elements[4].type is TupleType else {
        throw failure("Failed in getting a tuple type.")
      }
    }
  }

  describe("Parse a tuple with multiple elements with names and attributes, some has inout parameters") {
    $0.it("should be the complex tuple type") {
      parser.setupTestCode("(inout p1: @a foo, p2:bar?, p3   :   @x @y @z [key: value], inout p4    :a -> b, p5: ())")
      guard let tupleType = try? parser.parseTupleType() else {
        throw failure("Failed in getting a tuple type.")
      }
      try expect(tupleType.elements.count) == 5
      try expect(tupleType.elements[0].name) == "p1"
      try expect(tupleType.elements[0].attributes.count) == 1
      try expect(tupleType.elements[0].attributes[0].name) == "a"
      try expect(tupleType.elements[0].isInOutParameter).to.beTrue()
      guard tupleType.elements[0].type is TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(tupleType.elements[1].name) == "p2"
      try expect(tupleType.elements[1].attributes.count) == 0
      try expect(tupleType.elements[1].isInOutParameter).to.beFalse()
      guard tupleType.elements[1].type is OptionalType else {
        throw failure("Failed in getting an optional type.")
      }
      try expect(tupleType.elements[2].name) == "p3"
      try expect(tupleType.elements[2].attributes.count) == 3
      try expect(tupleType.elements[2].attributes[0].name) == "x"
      try expect(tupleType.elements[2].attributes[1].name) == "y"
      try expect(tupleType.elements[2].attributes[2].name) == "z"
      try expect(tupleType.elements[2].isInOutParameter).to.beFalse()
      guard tupleType.elements[2].type is DictionaryType else {
        throw failure("Failed in getting a dictionary type.")
      }
      try expect(tupleType.elements[3].name) == "p4"
      try expect(tupleType.elements[3].attributes.count) == 0
      try expect(tupleType.elements[3].isInOutParameter).to.beTrue()
      guard tupleType.elements[3].type is FunctionType else {
        throw failure("Failed in getting a function type.")
      }
      try expect(tupleType.elements[4].name) == "p5"
      try expect(tupleType.elements[4].attributes.count) == 0
      try expect(tupleType.elements[4].isInOutParameter).to.beFalse()
      guard tupleType.elements[4].type is TupleType else {
        throw failure("Failed in getting a tuple type.")
      }
    }
  }

}
