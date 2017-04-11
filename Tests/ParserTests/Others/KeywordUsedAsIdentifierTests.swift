/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class KeywordUsedAsIdentifierTests: XCTestCase {
  func testKeywordUsedInTupleType() {
    let result = parse("let a: (_: String, self: Int, protocol: Double)")
    XCTAssertEqual(result.statements[0].textDescription, "let a: (_: String, self: Int, protocol: Double)")
  }

  func testKeywordUsedInFunctionType() {
    let result = parse("let a: (_: String, self: Int, protocol: Double) -> Any")
    XCTAssertEqual(result.statements[0].textDescription, "let a: (_: String, self: Int, protocol: Double) -> Any")
  }

  func testKeywordUsedInSelfExpression() {
    let result = parse("let a = self.protocol, b = self.for")
    XCTAssertEqual(result.statements[0].textDescription, "let a = self.protocol, b = self.for")
  }

  func testKeywordUsedInClosureExpressionParameterName() {
    let result = parse("self.do { (protocol, _, nil) in }")
    XCTAssertEqual(result.statements[0].textDescription, "self.do { (protocol, _, nil) in }")
  }

  func testKeywordUsedInImplicitMemberExpression() {
    let result = parse("return .protocol")
    XCTAssertEqual(result.statements[0].textDescription, "return .protocol")
  }

  func testKeywordUsedInTupleExpression() {
    let result = parse("let a = (1, _: 2, protocol: 3, _: _, func: _)")
    XCTAssertEqual(result.statements[0].textDescription, "let a = (1, _: 2, protocol: 3, _: _, func: _)")
  }

  func testKeywordUsedInExplicitMemberExpression() {
    let result = parse("let a = foo.willSet(protocol:_:for:in:);let b = bar.inout")
    XCTAssertEqual(result.statements[0].textDescription, "let a = foo.willSet(protocol:_:for:in:)")
    XCTAssertEqual(result.statements[1].textDescription, "let b = bar.inout")
  }

  func testKeywordUsedInEnumCasePattern() {
    let result = parse("enum HTTPMEthod: String { case get = \"GET\" }")
    XCTAssertEqual(result.statements[0].textDescription, "enum HTTPMEthod: String {\ncase get = \"GET\"\n}")
  }

  func testKeywordUsedInSwitchCase() {
    let result = parse(
      "switch foo {",
      "case .as: break",
      "case .associativity: break",
      "case .break: break",
      "case .catch: break",
      "case .case: break",
      "case .class: break",
      "case .continue: break",
      "case .convenience: break",
      "case .default: break",
      "case .defer: break",
      "case .deinit: break",
      "case .didSet: break",
      "case .do: break",
      "case .dynamic: break",
      "case .dynamicType: break",
      "case .enum: break",
      "case .extension: break",
      "case .else: break",
      "case .fallthrough: break",
      "case .fileprivate: break",
      "case .final: break",
      "case .for: break",
      "case .func: break",
      "case .get: break",
      "case .guard: break",
      "case .if: break",
      "case .import: break",
      "case .in: break",
      "case .indirect: break",
      "case .infix: break",
      "case .init: break",
      "case .inout: break",
      "case .internal: break",
      "case .is: break",
      "case .lazy: break",
      "case .let: break",
      "case .left: break",
      "case .mutating: break",
      "case .nil: break",
      "case .none: break",
      "case .nonmutating: break",
      "case .open: break",
      "case .operator: break",
      "case .optional: break",
      "case .override: break",
      "case .postfix: break",
      "case .prefix: break",
      "case .private: break",
      "case .protocol: break",
      "case .precedence: break",
      "case .public: break",
      "case .repeat: break",
      "case .required: break",
      "case .rethrows: break",
      "case .return: break",
      "case .right: break",
      "case .safe: break",
      "case .self: break",
      "case .set: break",
      "case .static: break",
      "case .struct: break",
      "case .subscript: break",
      "case .super: break",
      "case .switch: break",
      "case .throw: break",
      "case .throws: break",
      "case .try: break",
      "case .typealias: break",
      "case .unowned: break",
      "case .unsafe: break",
      "case .var: break",
      "case .weak: break",
      "case .where: break",
      "case .while: break",
      "case .willSet: break",
      "case .Any: break",
      "case .Protocol: break",
      "case .Self: break",
      "case .Type: break",
      "}")
    XCTAssertEqual(result.statements.count, 1)
  }

  func testKeywordUsedInTuplePattern() {
    let result = parse("switch foo {case .as(_:Int,protocol:_,in:Any?): break}")
    XCTAssertEqual(result.statements[0].textDescription, "switch foo {\ncase .as(_: Int, protocol: _, in: Any?):\nbreak\n}")
  }

  func testKeywordUsedInFunctionCall() {
    let result = parse("let stripped = get(in: .whitespacesAndNewlines)")
    XCTAssertEqual(result.statements[0].textDescription, "let stripped = get(in: .whitespacesAndNewlines)")
  }

  func testKeywordUsedInFunctionDecl() {
    let result = parse("func get(for p: Any, _ in: Any, at: Any)")
    XCTAssertEqual(result.statements[0].textDescription, "func get(for p: Any, _ in: Any, at: Any)")
  }

  func testKeywordUsedInConstantDecl() {
    let keywords = ["set", "get", "left", "right", "open"]
    for keyword in keywords {
      let result = parse("let \(keyword)")
      XCTAssertEqual(result.statements[0].textDescription, "let \(keyword)")
    }
  }

  static var allTests = [
    ("testKeywordUsedInTupleType", testKeywordUsedInTupleType),
    ("testKeywordUsedInFunctionType", testKeywordUsedInFunctionType),
    ("testKeywordUsedInSelfExpression", testKeywordUsedInSelfExpression),
    ("testKeywordUsedInClosureExpressionParameterName", testKeywordUsedInClosureExpressionParameterName),
    ("testKeywordUsedInImplicitMemberExpression", testKeywordUsedInImplicitMemberExpression),
    ("testKeywordUsedInTupleExpression", testKeywordUsedInTupleExpression),
    ("testKeywordUsedInExplicitMemberExpression", testKeywordUsedInExplicitMemberExpression),
    ("testKeywordUsedInEnumCasePattern", testKeywordUsedInEnumCasePattern),
    ("testKeywordUsedInSwitchCase", testKeywordUsedInSwitchCase),
    ("testKeywordUsedInTuplePattern", testKeywordUsedInTuplePattern),
    ("testKeywordUsedInFunctionCall", testKeywordUsedInFunctionCall),
    ("testKeywordUsedInFunctionDecl", testKeywordUsedInFunctionDecl),
    ("testKeywordUsedInConstantDecl", testKeywordUsedInConstantDecl),
  ]
}
