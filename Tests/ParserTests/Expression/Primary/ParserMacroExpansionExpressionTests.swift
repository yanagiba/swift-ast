/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

class ParserMacroExpansionExpressionTests: XCTestCase {
  func testSimpleMacro() {
    parseExpressionAndTest("#stringify(x)", "#stringify(x)", testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "stringify")
      XCTAssertNil(macroExpr.genericArgumentClause)
      XCTAssertNotNil(macroExpr.argumentClause)
      XCTAssertEqual(macroExpr.argumentClause?.count, 1)
      XCTAssertNil(macroExpr.trailingClosure)
    })
  }

  func testExternalMacro() {
    parseExpressionAndTest(
      "#externalMacro(module: \"M\", type: \"T\")",
      "#externalMacro(module: \"M\", type: \"T\")",
      testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "externalMacro")
      XCTAssertNil(macroExpr.genericArgumentClause)
      XCTAssertNotNil(macroExpr.argumentClause)
      XCTAssertEqual(macroExpr.argumentClause?.count, 2)
      XCTAssertNil(macroExpr.trailingClosure)
    })
  }

  func testEmptyArgsMacro() {
    parseExpressionAndTest("#myMacro()", "#myMacro()", testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "myMacro")
      XCTAssertNil(macroExpr.genericArgumentClause)
      XCTAssertNotNil(macroExpr.argumentClause)
      XCTAssertEqual(macroExpr.argumentClause?.count, 0)
      XCTAssertNil(macroExpr.trailingClosure)
    })
  }

  func testGenericMacro() {
    parseExpressionAndTest("#myMacro<Int>(value)", "#myMacro<Int>(value)", testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "myMacro")
      XCTAssertNotNil(macroExpr.genericArgumentClause)
      XCTAssertNotNil(macroExpr.argumentClause)
      XCTAssertEqual(macroExpr.argumentClause?.count, 1)
      XCTAssertNil(macroExpr.trailingClosure)
    })
  }

  func testBareMacro() {
    parseExpressionAndTest("#myMacro", "#myMacro", testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "myMacro")
      XCTAssertNil(macroExpr.genericArgumentClause)
      XCTAssertNil(macroExpr.argumentClause)
      XCTAssertNil(macroExpr.trailingClosure)
    })
  }

  func testSourceRange() {
    parseExpressionAndTest("#stringify(x)", "#stringify(x)", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 14))
    })
    parseExpressionAndTest("#myMacro()", "#myMacro()", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 11))
    })
    parseExpressionAndTest("#myMacro", "#myMacro", testClosure: { expr in
      XCTAssertEqual(expr.sourceRange, getRange(1, 1, 1, 9))
    })
  }

  func testMacroWithTrailingClosure() {
    parseExpressionAndTest("#myMacro { body }", "#myMacro { body }", testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "myMacro")
      XCTAssertNil(macroExpr.argumentClause)
      XCTAssertNotNil(macroExpr.trailingClosure)
      XCTAssertTrue(macroExpr.additionalTrailingClosures.isEmpty)
    })
  }

  func testMacroWithMultipleArgs() {
    parseExpressionAndTest(
      "#assert(x > 0, \"must be positive\")",
      "#assert(x > 0, \"must be positive\")",
      testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "assert")
      XCTAssertEqual(macroExpr.argumentClause?.count, 2)
    })
  }

  func testMacroWithLabeledArgs() {
    parseExpressionAndTest(
      "#externalMacro(module: \"SwiftSyntaxMacros\", type: \"StringifyMacro\")",
      "#externalMacro(module: \"SwiftSyntaxMacros\", type: \"StringifyMacro\")",
      testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "externalMacro")
      XCTAssertEqual(macroExpr.argumentClause?.count, 2)
    })
  }

  func testMacroWithArgsAndTrailingClosure() {
    parseExpressionAndTest(
      "#Preview(\"My View\") { Text(\"Hello\") }",
      "#Preview(\"My View\") { Text(\"Hello\") }",
      testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "Preview")
      XCTAssertEqual(macroExpr.argumentClause?.count, 1)
      XCTAssertNotNil(macroExpr.trailingClosure)
    })
  }

  func testMacroWithGenericAndArgs() {
    parseExpressionAndTest(
      "#convert<String>(value: 42)",
      "#convert<String>(value: 42)",
      testClosure: { expr in
      guard let macroExpr = expr as? MacroExpansionExpression else {
        XCTFail("Failed in getting a macro expansion expression")
        return
      }
      XCTAssertEqual(macroExpr.macroName, "convert")
      XCTAssertNotNil(macroExpr.genericArgumentClause)
      XCTAssertEqual(macroExpr.argumentClause?.count, 1)
    })
  }
}
