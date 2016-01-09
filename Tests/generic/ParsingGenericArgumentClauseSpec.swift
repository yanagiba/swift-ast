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

func specGenericArgumentClause() {
  let parser = Parser()

  describe("Parse generic argument clause with one type") {
    $0.it("should return that name") {
      parser.setupTestCode("<String>")
      guard let genericArgumentClause = try? parser.parseGenericArgumentClause() else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClause.types.count) == 1
      guard genericArgumentClause.types[0] is TypeIdentifier else {
        throw failure("Failed in getting a type identifier")
      }
    }
  }

  describe("Parse generic argument clause with multiple types") {
    $0.it("should return those types") {
      parser.setupTestCode("<[Int], protocol<String, Double>>")
      guard let genericArgumentClause = try? parser.parseGenericArgumentClause() else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClause.types.count) == 2
      guard genericArgumentClause.types[0] is ArrayType else {
        throw failure("Failed in getting an arrayType")
      }
      guard genericArgumentClause.types[1] is ProtocolCompositionType else {
        throw failure("Failed in getting a protocolCompositionType")
      }
    }
  }

  /*
  describe("Parse generic argument clause with generic argument clauses") {
    $0.it("should return those embedded argument clauses") {
      parser.setupTestCode("<A<B<C<protocol<D, E<F<G>>>>>>>")
      guard let genericArgumentClauseA = try? parser.parseGenericArgumentClause() else {
        throw failure("Failed in getting a generic argument clause.")
      }
      try expect(genericArgumentClauseA.types.count) = 1
    }
  }
  */
}
