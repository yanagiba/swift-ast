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

func specOptionalType() {
  let parser = Parser()

  describe("Parse one optional type") {
    $0.it("should return an optional type") {
      parser.setupTestCode("foo?")
      guard let optionalType = try? parser.parseOptionalType() else {
        throw failure("Failed in getting an optional type.")
      }
      guard let typeIdentifier = optionalType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse one optional type that wraps another optional type") {
    $0.it("should return an optional type that wraps another optional type") {
      parser.setupTestCode("foo??")
      guard let optionalType = try? parser.parseOptionalType() else {
        throw failure("Failed in getting an optional type.")
      }
      guard let innerOptionalType = optionalType.type as? OptionalType else {
        throw failure("Failed in getting an inner optional type.")
      }
      guard let typeIdentifier = innerOptionalType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse one optional type that wraps an implicitly unwrapped optional type") {
    $0.it("should return an optional type that wraps an implicitly unwrapped optional type") {
      parser.setupTestCode("foo!?")
      guard let optionalType = try? parser.parseOptionalType() else {
        throw failure("Failed in getting an optional type.")
      }
      guard let implicitlyUnwrappedOptionalType = optionalType.type as? ImplicitlyUnwrappedOptionalType else {
        throw failure("Failed in getting an implicitly unwrapped optional type.")
      }
      guard let typeIdentifier = implicitlyUnwrappedOptionalType.type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }

  describe("Parse ? doesn't follow the type immediately") {
    $0.it("should return the type directly without wrapping into an optional type") {
      parser.setupTestCode("foo ?")
      guard let type = try? parser.parseType() else {
        throw failure("Failed in getting a type.")
      }
      if type is OptionalType {
        throw failure("Should not be an optional type.")
      }
      guard let typeIdentifier = type as? TypeIdentifier else {
        throw failure("Failed in getting a type identifier.")
      }
      try expect(typeIdentifier.names.count) == 1
      try expect(typeIdentifier.names[0]) == "foo"
    }
  }
}
