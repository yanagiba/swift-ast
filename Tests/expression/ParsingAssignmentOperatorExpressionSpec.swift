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

func specAssignmentOperatorExpression() {
  let parser = Parser()

  let testStrings = [
    " = ",
    "= ",
    " =",
    "=",
    "        =               "
  ]

  describe("Parse assignment operator expressions") {
    $0.it("should return assignment operator expressions") {
      for testString in testStrings {
        let testCode = "foo\(testString)bar"
        parser.setupTestCode(testCode)
        guard let assignmentOpExpr = try? parser.parseAssignmentOperatorExpression() else {
          throw failure("Failed in getting an assignment operator expression for code `\(testCode)`.")
        }
        try expect(assignmentOpExpr.leftExpression is IdentifierExpression).to.beTrue()
        try expect(assignmentOpExpr.rightExpression is IdentifierExpression).to.beTrue()
      }
    }
  }

  describe("Parse assignment operator expressions with try operators") {
    $0.it("should return assignment operator expressions with try operators") {
      for testString in testStrings {
        let testCode = "try? foo\(testString)try! bar"
        parser.setupTestCode(testCode)
        guard let assignmentOpExpr = try? parser.parseAssignmentOperatorExpression() else {
          throw failure("Failed in getting an assignment operator expression for code `\(testCode)`.")
        }
        try expect(assignmentOpExpr.leftExpression is TryOperatorExpression).to.beTrue()
        try expect(assignmentOpExpr.rightExpression is TryOperatorExpression).to.beTrue()
      }
    }
  }
}
