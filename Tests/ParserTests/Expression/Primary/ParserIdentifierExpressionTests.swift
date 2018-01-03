/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

@testable import AST

class ParserIdentifierExpressionTests: XCTestCase {
  func testNameOnly() {
    let testClosure: (String, Expression) -> Void = { identifier, expr in
      guard let idExpr = expr as? IdentifierExpression,
        case let .identifier(id, generic) = idExpr.kind else {
        XCTFail("Failed in getting an identifier expression")
        return
      }
      ASTTextEqual(id, identifier)
      XCTAssertNil(generic)
    }
    ["foo", "bar", "backtick"].forEach { identifier in
      parseExpressionAndTest(identifier, identifier, testClosure: { expr in
        testClosure(identifier, expr)
      })
      let backtickedIdentifier = "`\(identifier)`"
      parseExpressionAndTest(backtickedIdentifier, backtickedIdentifier, testClosure: { expr in
        testClosure(backtickedIdentifier, expr)
      })
    }
  }

  func testNameWithGeneric() {
    let testClosure: (String, String, Expression) -> Void = { identifier, gnrc, expr in
      guard let idExpr = expr as? IdentifierExpression,
        case let .identifier(id, generic) = idExpr.kind else {
        XCTFail("Failed in getting an identifier expression")
        return
      }
      ASTTextEqual(id, identifier)
      XCTAssertEqual(generic?.textDescription, "<\(gnrc)>")
    }
    ["foo", "bar", "backtick"].forEach { identifier in
      ["A", "A, B, C"].forEach { generic in
        let idExpr = "\(identifier)<\(generic)>"
        parseExpressionAndTest(idExpr, idExpr, testClosure: { expr in
          testClosure(identifier, generic, expr)
        })
        let backtickedIdentifier = "`\(identifier)`"
        let backtickIdExpr = "\(backtickedIdentifier)<\(generic)>"
        parseExpressionAndTest(backtickIdExpr, backtickIdExpr, testClosure: { expr in
          testClosure(backtickedIdentifier, generic, expr)
        })
      }
    }
  }

  func testImplicitParameter() {
    let testClosure: (Int, Expression) -> Void = { idx, expr in
      guard let idExpr = expr as? IdentifierExpression,
        case let .implicitParameterName(index, generic) = idExpr.kind else {
        XCTFail("Failed in getting an identifier expression")
        return
      }
      XCTAssertEqual(index, idx)
      XCTAssertNil(generic)
    }
    (0...10).forEach { index in
      let implParam = "$\(index)"
      parseExpressionAndTest(implParam, implParam, testClosure: { expr in
        testClosure(index, expr)
      })
    }
  }

  func testImplicitParameterWithGeneric() {
    let testClosure: (Int, Expression) -> Void = { idx, expr in
      guard let idExpr = expr as? IdentifierExpression,
        case let .implicitParameterName(index, generic) = idExpr.kind else {
        XCTFail("Failed in getting an identifier expression")
        return
      }
      XCTAssertEqual(index, idx)
      XCTAssertEqual(generic?.textDescription, "<A, B, C>")
    }
    (0...10).forEach { index in
      let implParam = "$\(index)<A, B, C>"
      parseExpressionAndTest(implParam, implParam, testClosure: { expr in
        testClosure(index, expr)
      })
    }
  }

  func testSourceRange() {
    let testExprs: [(testString: String, expectedString: String, expectedEndColumn: Int)] = [
      ("foo", "foo", 4),
      ("foo<T>", "foo<T>", 7),
      ("`class`", "`class`", 8),
      ("`class`<P>", "`class`<P>", 11),
      ("$0", "$0", 3),
      ("$0<A>", "$0<A>", 6),
    ]
    for t in testExprs {
      parseExpressionAndTest(t.testString, t.expectedString, testClosure: { expr in
        XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, t.expectedEndColumn))
      })
    }
  }

  static var allTests = [
    ("testNameOnly", testNameOnly),
    ("testNameWithGeneric", testNameWithGeneric),
    ("testImplicitParameter", testImplicitParameter),
    ("testImplicitParameterWithGeneric", testImplicitParameterWithGeneric),
    ("testSourceRange", testSourceRange),
  ]
}
