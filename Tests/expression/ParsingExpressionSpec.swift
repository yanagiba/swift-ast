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

func specExpression() {
  let parser = Parser()

  describe("Parse identifier expression") {
    $0.it("should return an identifier expression") {
      parser.setupTestCode("foo")
      guard let expr = try? parser.parseExpression() else {
        throw failure("Failed in getting an expression.")
      }
      guard expr is IdentifierExpression else {
        throw failure("Failed in getting an identifier expression.")
      }
    }
  }

  describe("Parse literal expression") {
    let testLiteralExpressions = [
      "nil",
      "1",
      "1.23",
      "\"foo\"",
      "\"\\(1 + 2)\"",
      "true",
      "[1, 2, 3]",
      "[1: true, 2: false, 3: true, 4: false]",
      "__FILE__"
    ]
    for testLiteral in testLiteralExpressions {
      $0.it("should return an identifier expression") {
        parser.setupTestCode(testLiteral)
        guard let expr = try? parser.parseExpression() else {
          throw failure("Failed in getting an expression.")
        }
        guard expr is LiteralExpression else {
          throw failure("Failed in getting a literal expression.")
        }
      }
    }
  }
}
