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

class ParsingOptionalChainingExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseOptionalChainingExpression() {
    parser.setupTestCode("foo?")
    guard let optionalChainingExpr = try? parser.parseOptionalChainingExpression() else {
      XCTFail("Failed in getting an optional chaining expression.")
      return
    }
    guard let idExpr = optionalChainingExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testParseOptionalChainingExpressionThatWrapsAnotherOptionalChainingExpression() {
    parser.setupTestCode("foo??")
    guard let optionalChainingExpr = try? parser.parseOptionalChainingExpression() else {
      XCTFail("Failed in getting an optional chaining expression.")
      return
    }
    guard let innerOptionalChainingExpr = optionalChainingExpr.postfixExpression as? OptionalChainingExpression else {
      XCTFail("Failed in getting an inner optional chaining expression.")
      return
    }
    guard let idExpr = innerOptionalChainingExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testParseOptionalChainingExpressionThatWrapsForcedValueExpression() {
    parser.setupTestCode("foo!?")
    guard let optionalChainingExpr = try? parser.parseOptionalChainingExpression() else {
      XCTFail("Failed in getting an optional chaining expression.")
      return
    }
    guard let forcedValueExpr = optionalChainingExpr.postfixExpression as? ForcedValueExpression else {
      XCTFail("Failed in getting a forced value expression.")
      return
    }
    guard let idExpr = forcedValueExpr.postfixExpression as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }

  func testQuestionMarkDoesNotFollowPostixExpressionImmediatelyShouldReturnThePostfixExpressionWithoutWrappingIntoOptionalChainingExpression() {
    parser.setupTestCode("foo ?")
    guard let expr = try? parser.parseExpression() else {
      XCTFail("Failed in getting a type.")
      return
    }
    if expr is OptionalChainingExpression {
      XCTFail("Should not be an optional chaining expression.")
      return
    }
    guard let idExpr = expr as? IdentifierExpression else {
      XCTFail("Failed in getting an identifier expression.")
      return
    }
    XCTAssertEqual(idExpr.identifier, "foo")
  }
}
