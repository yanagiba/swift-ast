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

class ParsingSuperclassExpressionTests: XCTestCase {
  let parser = Parser()

  func testParseSuperclassMethodExpression() {
    parser.setupTestCode("super.foo")
    guard let superExpr = try? parser.parseSuperclassExpression() else {
      XCTFail("Failed in getting a superclass expression.")
      return
    }
    guard case let superExprKind = superExpr.kind where superExprKind == .Method else  {
      XCTFail("Failed in getting a superclass method expression.")
      return
    }
    XCTAssertEqual(superExpr.methodIdentifier, "foo")
    XCTAssertTrue(superExpr.subscriptExpressions.isEmpty)
  }

  func testParseSuperclassSubscriptExpression() {
    parser.setupTestCode("super[0]")
    guard let superExpr = try? parser.parseSuperclassExpression() else {
      XCTFail("Failed in getting a superclass expression.")
      return
    }
    guard case let superExprKind = superExpr.kind where superExprKind == .Subscript else  {
      XCTFail("Failed in getting a superclass subscript expression.")
      return
    }
    XCTAssertEqual(superExpr.methodIdentifier, "")
    XCTAssertEqual(superExpr.subscriptExpressions.count, 1)
  }

  func testParseSuperclassSubscriptExpressionWithExpressionList() {
    parser.setupTestCode("super[0, 1, 5]")
    guard let superExpr = try? parser.parseSuperclassExpression() else {
      XCTFail("Failed in getting a superclass expression.")
      return
    }
    guard case let superExprKind = superExpr.kind where superExprKind == .Subscript else  {
      XCTFail("Failed in getting a superclass subscript expression.")
      return
    }
    XCTAssertEqual(superExpr.methodIdentifier, "")
    XCTAssertEqual(superExpr.subscriptExpressions.count, 3)
  }

  func testParseSuperclassExpressionWithExpressionListThasHasVariables() {
    parser.setupTestCode("super [ foo, 0, bar, 1, 5 ] ")
    guard let superExpr = try? parser.parseSuperclassExpression() else {
      XCTFail("Failed in getting a superclass expression.")
      return
    }
    guard case let superExprKind = superExpr.kind where superExprKind == .Subscript else  {
      XCTFail("Failed in getting a superclass subscript expression.")
      return
    }
    XCTAssertEqual(superExpr.methodIdentifier, "")
    XCTAssertEqual(superExpr.subscriptExpressions.count, 5)
  }

  func testParseSuperclassInitializerExpression() {
    parser.setupTestCode("super.init")
    guard let superExpr = try? parser.parseSuperclassExpression() else {
      XCTFail("Failed in getting a superclass expression.")
      return
    }
    guard case let superExprKind = superExpr.kind where superExprKind == .Initializer else  {
      XCTFail("Failed in getting a superclass initializer expression.")
      return
    }
    XCTAssertEqual(superExpr.methodIdentifier, "")
    XCTAssertTrue(superExpr.subscriptExpressions.isEmpty)
  }
}
