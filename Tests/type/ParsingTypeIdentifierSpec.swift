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

func specTypeIdentifier() {
  let parser = Parser()

  describe("Parse type identifier with one name") {
    $0.it("should return that name") {
      parser.setupTestCode("foo")
      guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.namedTypes.count) == 1
      try expect(typeIdentifier.namedTypes[0].name) == "foo"
      try expect(typeIdentifier.namedTypes[0].generic).to.beNil()
    }
  }

  describe("Parse type identifier with multiple names") {
    $0.it("should return those names") {
      parser.setupTestCode("foo.bar.a.b.c")
      guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.namedTypes.count) == 5
      try expect(typeIdentifier.namedTypes[0].name) == "foo"
      try expect(typeIdentifier.namedTypes[0].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[1].name) == "bar"
      try expect(typeIdentifier.namedTypes[1].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[2].name) == "a"
      try expect(typeIdentifier.namedTypes[2].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[3].name) == "b"
      try expect(typeIdentifier.namedTypes[3].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[4].name) == "c"
      try expect(typeIdentifier.namedTypes[4].generic).to.beNil()
    }
  }

  describe("Parse type identifier with multiple names with white spaces") {
    $0.it("should return those names and ignore the white spaces") {
      parser.setupTestCode("foo    .     bar.a    .    b      .    c")
      guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.namedTypes.count) == 5
      try expect(typeIdentifier.namedTypes[0].name) == "foo"
      try expect(typeIdentifier.namedTypes[0].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[1].name) == "bar"
      try expect(typeIdentifier.namedTypes[1].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[2].name) == "a"
      try expect(typeIdentifier.namedTypes[2].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[3].name) == "b"
      try expect(typeIdentifier.namedTypes[3].generic).to.beNil()
      try expect(typeIdentifier.namedTypes[4].name) == "c"
      try expect(typeIdentifier.namedTypes[4].generic).to.beNil()
    }
  }

  describe("Parse type identifier with generic") {
    $0.it("should return a type name with a generic argument clause") {
      parser.setupTestCode("A<B>")
      guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.namedTypes.count) == 1
      let namedType = typeIdentifier.namedTypes[0]
      try expect(namedType.name) == "A"
      guard let generic = namedType.generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic.types.count) == 1
      guard let genericTypeIdentifier = generic.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(genericTypeIdentifier.names.count) == 1
      try expect(genericTypeIdentifier.names[0]) == "B"
    }
  }

  describe("Parse type identifier with several names and generics") {
    $0.it("should return type names with generic argument clauses") {
      parser.setupTestCode("A<B>.C<D>.E<F>")
      guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.namedTypes.count) == 3

      try expect(typeIdentifier.namedTypes[0].name) == "A"
      guard let generic0 = typeIdentifier.namedTypes[0].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic0.types.count) == 1
      guard let generic0TypeIdentifier = generic0.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic0TypeIdentifier.names.count) == 1
      try expect(generic0TypeIdentifier.names[0]) == "B"

      try expect(typeIdentifier.namedTypes[1].name) == "C"
      guard let generic1 = typeIdentifier.namedTypes[1].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic1.types.count) == 1
      guard let generic1TypeIdentifier = generic1.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic1TypeIdentifier.names.count) == 1
      try expect(generic1TypeIdentifier.names[0]) == "D"

      try expect(typeIdentifier.namedTypes[2].name) == "E"
      guard let generic2 = typeIdentifier.namedTypes[2].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic2.types.count) == 1
      guard let generic2TypeIdentifier = generic2.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic2TypeIdentifier.names.count) == 1
      try expect(generic2TypeIdentifier.names[0]) == "F"
    }
  }

  describe("Parse type identifier with several names and other type identifiers embedded inside generics") {
    $0.it("should return type names with generic argument clauses that other type identifiers that has generic argument clauses") {
      parser.setupTestCode("A<B>.C<D<X<Y<Z>>>>.E<F>")
      guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.namedTypes.count) == 3

      try expect(typeIdentifier.namedTypes[0].name) == "A"
      guard let generic0 = typeIdentifier.namedTypes[0].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic0.types.count) == 1
      guard let generic0TypeIdentifier = generic0.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic0TypeIdentifier.names.count) == 1
      try expect(generic0TypeIdentifier.names[0]) == "B"

      try expect(typeIdentifier.namedTypes[1].name) == "C"
      guard let generic1 = typeIdentifier.namedTypes[1].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic1.types.count) == 1
      guard let generic1TypeIdentifier = generic1.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic1TypeIdentifier.namedTypes.count) == 1
      try expect(generic1TypeIdentifier.namedTypes[0].name) == "D"
      guard let generic11 = generic1TypeIdentifier.namedTypes[0].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic11.types.count) == 1
      guard let generic11TypeIdentifier = generic11.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic11TypeIdentifier.namedTypes.count) == 1
      try expect(generic11TypeIdentifier.namedTypes[0].name) == "X"
      guard let generic111 = generic11TypeIdentifier.namedTypes[0].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic111.types.count) == 1
      guard let generic111TypeIdentifier = generic111.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic111TypeIdentifier.namedTypes.count) == 1
      try expect(generic111TypeIdentifier.namedTypes[0].name) == "Y"
      guard let generic1111 = generic111TypeIdentifier.namedTypes[0].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic1111.types.count) == 1
      guard let generic1111TypeIdentifier = generic1111.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic1111TypeIdentifier.namedTypes.count) == 1
      try expect(generic1111TypeIdentifier.namedTypes[0].name) == "Z"

      try expect(typeIdentifier.namedTypes[2].name) == "E"
      guard let generic2 = typeIdentifier.namedTypes[2].generic else {
        throw failure("Failed in getting a generic argument clause")
      }
      try expect(generic2.types.count) == 1
      guard let generic2TypeIdentifier = generic2.types[0] as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier inside the generic argument clause")
      }
      try expect(generic2TypeIdentifier.names.count) == 1
      try expect(generic2TypeIdentifier.names[0]) == "F"
    }
  }
}
