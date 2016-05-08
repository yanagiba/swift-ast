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

class ParsingTryOperatorExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseTryOperatorExpression() {
    let testStrings: [String: TryOperatorExpression.Kind] = [
      "try": .Try,
      "try?": .OptionalTry,
      "try!": .ForcedTry
    ]
    for (testString, testKind) in testStrings {
      let testCode = "\(testString) foo"
      parser.setupTestCode(testCode)
      guard let tryOpExpr = try? parser.parseTryOperatorExpression() else {
        XCTFail("Failed in getting a try operator expression for code `\(testCode)`.")
        return
      }
      XCTAssertEqual(tryOpExpr.kind, testKind)
      XCTAssertTrue(tryOpExpr.expression is IdentifierExpression)
    }
  }
}
