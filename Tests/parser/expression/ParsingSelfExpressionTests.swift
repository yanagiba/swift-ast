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

class ParsingSelfExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseBasicSelfExpression() {
    parser.setupTestCode("self")
    guard let selfExpr = try? parser.parseSelfExpression() else {
      XCTFail("Failed in getting a self expression.")
      return
    }
    guard case let selfExprKind = selfExpr.kind where selfExprKind == .Self else  {
      XCTFail("Failed in getting a basic self expression.")
      return
    }
    XCTAssertEqual(selfExpr.methodIdentifier, "")
    XCTAssertTrue(selfExpr.subscriptExpressions.isEmpty)
  }

  func testParseSelfMethodExpression() {
    parser.setupTestCode("self.foo")
    guard let selfExpr = try? parser.parseSelfExpression() else {
      XCTFail("Failed in getting a self expression.")
      return
    }
    guard case let selfExprKind = selfExpr.kind where selfExprKind == .Method else  {
      XCTFail("Failed in getting a self method expression.")
      return
    }
    XCTAssertEqual(selfExpr.methodIdentifier, "foo")
    XCTAssertTrue(selfExpr.subscriptExpressions.isEmpty)
  }

  func testParseSelfSubscriptExpression() {
    parser.setupTestCode("self[0]")
    guard let selfExpr = try? parser.parseSelfExpression() else {
      XCTFail("Failed in getting a self expression.")
      return
    }
    guard case let selfExprKind = selfExpr.kind where selfExprKind == .Subscript else  {
      XCTFail("Failed in getting a self subscript expression.")
      return
    }
    XCTAssertEqual(selfExpr.methodIdentifier, "")
    XCTAssertEqual(selfExpr.subscriptExpressions.count, 1)
  }

  func testParseSelfSubscriptExpressionWithExpressionList() {
    parser.setupTestCode("self[0, 1, 5]")
    guard let selfExpr = try? parser.parseSelfExpression() else {
      XCTFail("Failed in getting a self expression.")
      return
    }
    guard case let selfExprKind = selfExpr.kind where selfExprKind == .Subscript else  {
      XCTFail("Failed in getting a self subscript expression.")
      return
    }
    XCTAssertEqual(selfExpr.methodIdentifier, "")
    XCTAssertEqual(selfExpr.subscriptExpressions.count, 3)
  }

  func testParseSelfSubscriptExpressionWithExpressionListThatHasVariables() {
    parser.setupTestCode("self [ foo, 0, bar, 1, 5 ] ")
    guard let selfExpr = try? parser.parseSelfExpression() else {
      XCTFail("Failed in getting a self expression.")
      return
    }
    guard case let selfExprKind = selfExpr.kind where selfExprKind == .Subscript else  {
      XCTFail("Failed in getting a self subscript expression.")
      return
    }
    XCTAssertEqual(selfExpr.methodIdentifier, "")
    XCTAssertEqual(selfExpr.subscriptExpressions.count, 5)
  }

  func testParseSelfInitializerExpression() {
    parser.setupTestCode("self.init")
    guard let selfExpr = try? parser.parseSelfExpression() else {
      XCTFail("Failed in getting a self expression.")
      return
    }
    guard case let selfExprKind = selfExpr.kind where selfExprKind == .Initializer else  {
      XCTFail("Failed in getting a self initializer expression.")
      return
    }
    XCTAssertEqual(selfExpr.methodIdentifier, "")
    XCTAssertTrue(selfExpr.subscriptExpressions.isEmpty)
  }
}
