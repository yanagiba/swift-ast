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

func specDynamicTypeExpression() {
  let parser = Parser()

  describe("Parse a dynamic type expression") {
    $0.it("should return a dynamic type expression") {
      parser.setupTestCode("foo.dynamicType")
      guard let initExpr = try? parser.parseDynamicTypeExpression() else {
        throw failure("Failed in getting a dynamic type expression.")
      }
      guard let idExpr = initExpr.postfixExpression as? IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
      try expect(idExpr.identifier) == "foo"
    }
  }
}
