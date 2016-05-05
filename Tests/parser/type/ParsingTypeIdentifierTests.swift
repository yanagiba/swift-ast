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

class ParsingTypeIdentifierTests: XCTestCase {
  let parser = Parser()

  func testParseTypeIdentifierWithOneName() {
    parser.setupTestCode("foo")
    guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.namedTypes.count, 1)
    XCTAssertEqual(typeIdentifier.namedTypes[0].name, "foo")
    XCTAssertNil(typeIdentifier.namedTypes[0].generic)
  }

  func testParseTypeIdentifierWithMutipleNames() {
    parser.setupTestCode("foo.bar.a.b.c")
    guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.namedTypes.count, 5)
    XCTAssertEqual(typeIdentifier.namedTypes[0].name, "foo")
    XCTAssertNil(typeIdentifier.namedTypes[0].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[1].name, "bar")
    XCTAssertNil(typeIdentifier.namedTypes[1].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[2].name, "a")
    XCTAssertNil(typeIdentifier.namedTypes[2].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[3].name, "b")
    XCTAssertNil(typeIdentifier.namedTypes[3].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[4].name, "c")
    XCTAssertNil(typeIdentifier.namedTypes[4].generic)
  }

  func testParseTypeIdentifierWithMultipleNamesAndWhiteSpaces() {
    parser.setupTestCode("foo    .     bar.a    .    b      .    c")
    guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.namedTypes.count, 5)
    XCTAssertEqual(typeIdentifier.namedTypes[0].name, "foo")
    XCTAssertNil(typeIdentifier.namedTypes[0].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[1].name, "bar")
    XCTAssertNil(typeIdentifier.namedTypes[1].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[2].name, "a")
    XCTAssertNil(typeIdentifier.namedTypes[2].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[3].name, "b")
    XCTAssertNil(typeIdentifier.namedTypes[3].generic)
    XCTAssertEqual(typeIdentifier.namedTypes[4].name, "c")
    XCTAssertNil(typeIdentifier.namedTypes[4].generic)
  }

  func testParseTypeIdentifierWithGeneric() {
    parser.setupTestCode("A<B>")
    guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.namedTypes.count, 1)
    let namedType = typeIdentifier.namedTypes[0]
    XCTAssertEqual(namedType.name, "A")
    guard let generic = namedType.generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic.types.count, 1)
    guard let genericTypeIdentifier = generic.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(genericTypeIdentifier.names.count, 1)
    XCTAssertEqual(genericTypeIdentifier.names[0], "B")
  }

  func testParseTypeIdentifierWithSeveralNamesAndGenerics() {
    parser.setupTestCode("A<B>.C<D>.E<F>")
    guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.namedTypes.count, 3)

    XCTAssertEqual(typeIdentifier.namedTypes[0].name, "A")
    guard let generic0 = typeIdentifier.namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic0.types.count, 1)
    guard let generic0TypeIdentifier = generic0.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic0TypeIdentifier.names.count, 1)
    XCTAssertEqual(generic0TypeIdentifier.names[0], "B")

    XCTAssertEqual(typeIdentifier.namedTypes[1].name, "C")
    guard let generic1 = typeIdentifier.namedTypes[1].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic1.types.count, 1)
    guard let generic1TypeIdentifier = generic1.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic1TypeIdentifier.names.count, 1)
    XCTAssertEqual(generic1TypeIdentifier.names[0], "D")

    XCTAssertEqual(typeIdentifier.namedTypes[2].name, "E")
    guard let generic2 = typeIdentifier.namedTypes[2].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic2.types.count, 1)
    guard let generic2TypeIdentifier = generic2.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic2TypeIdentifier.names.count, 1)
    XCTAssertEqual(generic2TypeIdentifier.names[0], "F")
  }

  func testParseTypeIdentifierWithSeveralNamesAndOtherTypeIdentifiersEmbeddedInsideGenerics() {
    parser.setupTestCode("A<B>.C<D<X<Y<Z>>>>.E<F>")
    guard let typeIdentifier = try? parser.parseTypeIdentifier() else {
      XCTFail("Failed in getting a type identifier.")
      return
    }
    XCTAssertEqual(typeIdentifier.namedTypes.count, 3)

    XCTAssertEqual(typeIdentifier.namedTypes[0].name, "A")
    guard let generic0 = typeIdentifier.namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic0.types.count, 1)
    guard let generic0TypeIdentifier = generic0.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic0TypeIdentifier.names.count, 1)
    XCTAssertEqual(generic0TypeIdentifier.names[0], "B")

    XCTAssertEqual(typeIdentifier.namedTypes[1].name, "C")
    guard let generic1 = typeIdentifier.namedTypes[1].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic1.types.count, 1)
    guard let generic1TypeIdentifier = generic1.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic1TypeIdentifier.namedTypes.count, 1)
    XCTAssertEqual(generic1TypeIdentifier.namedTypes[0].name, "D")
    guard let generic11 = generic1TypeIdentifier.namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic11.types.count, 1)
    guard let generic11TypeIdentifier = generic11.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic11TypeIdentifier.namedTypes.count, 1)
    XCTAssertEqual(generic11TypeIdentifier.namedTypes[0].name, "X")
    guard let generic111 = generic11TypeIdentifier.namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic111.types.count, 1)
    guard let generic111TypeIdentifier = generic111.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic111TypeIdentifier.namedTypes.count, 1)
    XCTAssertEqual(generic111TypeIdentifier.namedTypes[0].name, "Y")
    guard let generic1111 = generic111TypeIdentifier.namedTypes[0].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic1111.types.count, 1)
    guard let generic1111TypeIdentifier = generic1111.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic1111TypeIdentifier.namedTypes.count, 1)
    XCTAssertEqual(generic1111TypeIdentifier.namedTypes[0].name, "Z")

    XCTAssertEqual(typeIdentifier.namedTypes[2].name, "E")
    guard let generic2 = typeIdentifier.namedTypes[2].generic else {
      XCTFail("Failed in getting a generic argument clause")
      return
    }
    XCTAssertEqual(generic2.types.count, 1)
    guard let generic2TypeIdentifier = generic2.types[0] as? TypeIdentifier else {
      XCTFail("Failed in getting a type identifier inside the generic argument clause")
      return
    }
    XCTAssertEqual(generic2TypeIdentifier.names.count, 1)
    XCTAssertEqual(generic2TypeIdentifier.names[0], "F")
  }
}
