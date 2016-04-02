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

func specTypeCastingOperatorExpression() {
  let parser = Parser()

  describe("Parse type-casting operator expressions") {
    $0.it("should return an identifier expression") {
      let testTypeCasts: [String: TypeCastingOperatorExpression.Kind] = [
        "is": .Is,
        "as": .As,
        "as?": .OptionalAs,
        "as!": .ForcedAs
      ]
      for (testTypeCast, testCastKind) in testTypeCasts {
        let testCode = "foo \(testTypeCast) bar"
        parser.setupTestCode(testCode)
        guard let typeCastingOpExpr = try? parser.parseTypeCastingOperatorExpression() else {
          throw failure("Failed in getting a type-casting operator expression for code `\(testCode)`.")
        }
        try expect(typeCastingOpExpr.kind) == testCastKind
        try expect(typeCastingOpExpr.expression is IdentifierExpression).to.beTrue()
        try expect(typeCastingOpExpr.type is TypeIdentifier).to.beTrue()
      }
    }
  }
}
