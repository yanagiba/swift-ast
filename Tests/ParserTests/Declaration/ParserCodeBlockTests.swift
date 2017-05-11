/*
   Copyright 2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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
@testable import Parser

class ParserCodeBlockTests: XCTestCase {
  func testSimpleCase() {
    let declParser = getParser("{a = 1\nb = 2\na>b ? a+1:b\nfoo()}")
    do {
      let codeBlock = try declParser.parseCodeBlock()
      XCTAssertEqual(codeBlock.textDescription, "{\na = 1\nb = 2\na > b ? a + 1 : b\nfoo()\n}")
      let stmts = codeBlock.statements
      XCTAssertEqual(stmts.count, 4)
      XCTAssertTrue(stmts[0] is AssignmentOperatorExpression)
      XCTAssertTrue(stmts[1] is AssignmentOperatorExpression)
      XCTAssertTrue(stmts[2] is TernaryConditionalOperatorExpression)
      XCTAssertTrue(stmts[3] is FunctionCallExpression)
    } catch {
      XCTFail("Failed in parsing a code block declaration.")
    }
  }

  func testSourceRange() {
    let declParser = getParser("{import A\nimport B}")
    do {
      let codeBlock = try declParser.parseCodeBlock()
      XCTAssertEqual(codeBlock.textDescription, "{\nimport A\nimport B\n}")
      XCTAssertEqual(codeBlock.sourceRange, getRange(1, 1, 2, 10))
    } catch {
      XCTFail("Failed in parsing a code block declaration.")
    }
  }

  func testLexicalParent() {
    let declParser = getParser("{import A\nimport B}")
    do {
      let codeBlock = try declParser.parseCodeBlock()
      XCTAssertEqual(codeBlock.textDescription, "{\nimport A\nimport B\n}")
      XCTAssertNil(codeBlock.lexicalParent)
      for stmt in codeBlock.statements {
        XCTAssertTrue(stmt.lexicalParent === codeBlock)
      }
    } catch {
      XCTFail("Failed in parsing a code block declaration.")
    }
  }

  static var allTests = [
    ("testSimpleCase", testSimpleCase),
    ("testSourceRange", testSourceRange),
    ("testLexicalParent", testLexicalParent),
  ]
}
