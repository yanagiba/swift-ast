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

class ParsingForcedValueExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseForcedValueExpression() {
    parser.setupTestCode("foo!")
    guard let forcedValueExpr = try? parser.parseForcedValueExpression() else {
      XCTFail("Failed in getting a forced value expression.")
      return
    }
    guard let idExpr = forcedValueExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testParseForcedValueExpressionThatWrapsAnotherForcedValueExpression() {
    parser.setupTestCode("foo!!")
    guard let forcedValueExpr = try? parser.parseForcedValueExpression() else {
      XCTFail("Failed in getting a forced value expression.")
      return
    }
    guard let innerForcedValueExpr = forcedValueExpr.postfixExpression as? ForcedValueExpression else {
      XCTFail("Failed in getting an inner forced value expression.")
      return
    }
    guard let idExpr = innerForcedValueExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testParseForcedValueExpressionThatWrapsAnOptionalChainingExpression() {
    parser.setupTestCode("foo?!")
    guard let forcedValueExpr = try? parser.parseForcedValueExpression() else {
      XCTFail("Failed in getting a forced value expression.")
      return
    }
    guard let optionalChainingExpression = forcedValueExpr.postfixExpression as? OptionalChainingExpression else {
      XCTFail("Failed in getting an optional chaining expression.")
      return
    }
    guard let idExpr = optionalChainingExpression.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testExclamationMarkDoesNotFollowThePostfixExpressionImmediatelyShouldReturnPostfixExpressionWithoutWrappingIntoForcedValueExpression() {
    parser.setupTestCode("foo !")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting a type.")
      return
    }
    if expr is ForcedValueExpression {
      XCTFail("Should not be a forced value expression.")
      return
    }
    guard let idExpr = expr as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }
}
