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
@testable import Parser

class ParserForInStatementTests: XCTestCase {
  func testItemInCollection() {
    parseStatementAndTest("for i in aCollection { print(i) }",
      "for i in aCollection {\nprint(i)\n}",
      testClosure: { stmt in
      guard let forInStmt = stmt as? ForInStatement else {
        XCTFail("Failed in parsing a for-in statement.")
        return
      }
      XCTAssertFalse(forInStmt.item.isCaseMatching)
      XCTAssertTrue(forInStmt.item.matchingPattern is IdentifierPattern)
      XCTAssertEqual(forInStmt.item.matchingPattern.textDescription, "i")
      XCTAssertTrue(forInStmt.collection is IdentifierExpression)
      XCTAssertEqual(forInStmt.collection.textDescription, "aCollection")
      XCTAssertNil(forInStmt.item.whereClause)
      XCTAssertEqual(forInStmt.codeBlock.statements.count, 1)
      XCTAssertTrue(forInStmt.codeBlock.statements[0] is FunctionCallExpression)
      XCTAssertEqual(forInStmt.codeBlock.statements[0].textDescription, "print(i)")
    })
  }

  func testCaseMatching() {
    parseStatementAndTest("for case i in aCollection {}",
      "for case i in aCollection {}",
      testClosure: { stmt in
      guard let forInStmt = stmt as? ForInStatement else {
        XCTFail("Failed in parsing a for-in statement.")
        return
      }
      XCTAssertTrue(forInStmt.item.isCaseMatching)
      XCTAssertTrue(forInStmt.item.matchingPattern is IdentifierPattern)
      XCTAssertEqual(forInStmt.item.matchingPattern.textDescription, "i")
      XCTAssertTrue(forInStmt.collection is IdentifierExpression)
      XCTAssertEqual(forInStmt.collection.textDescription, "aCollection")
      XCTAssertNil(forInStmt.item.whereClause)
      XCTAssertTrue(forInStmt.codeBlock.statements.isEmpty)
    })
  }

  func testWhereClause() {
    parseStatementAndTest("for (k, v) in [1: true, 0: false] where v {}",
      "for (k, v) in [1: true, 0: false] where v {}",
      testClosure: { stmt in
      guard let forInStmt = stmt as? ForInStatement else {
        XCTFail("Failed in parsing a for-in statement.")
        return
      }
      XCTAssertFalse(forInStmt.item.isCaseMatching)
      XCTAssertTrue(forInStmt.item.matchingPattern is TuplePattern)
      XCTAssertEqual(forInStmt.item.matchingPattern.textDescription, "(k, v)")
      XCTAssertTrue(forInStmt.collection is LiteralExpression)
      XCTAssertEqual(forInStmt.collection.textDescription, "[1: true, 0: false]")
      XCTAssertNotNil(forInStmt.item.whereClause)
      XCTAssertEqual(forInStmt.item.whereClause?.textDescription, "v")
      XCTAssertTrue(forInStmt.codeBlock.statements.isEmpty)
    })
  }

  func testEnumerate() {
    parseStatementAndTest("for (index, it) in enumerate([]) {}",
      "for (index, it) in enumerate([]) {}",
      testClosure: { stmt in
      guard let forInStmt = stmt as? ForInStatement else {
        XCTFail("Failed in parsing a for-in statement.")
        return
      }
      XCTAssertFalse(forInStmt.item.isCaseMatching)
      XCTAssertTrue(forInStmt.item.matchingPattern is TuplePattern)
      XCTAssertEqual(forInStmt.item.matchingPattern.textDescription, "(index, it)")
      XCTAssertTrue(forInStmt.collection is FunctionCallExpression)
      XCTAssertEqual(forInStmt.collection.textDescription, "enumerate([])")
      XCTAssertNil(forInStmt.item.whereClause)
      XCTAssertTrue(forInStmt.codeBlock.statements.isEmpty)
    })
  }

  func testRange() {
    parseStatementAndTest("for e in 0..<9 {}",
      "for e in 0 ..< 9 {}",
      testClosure: { stmt in
      guard let forInStmt = stmt as? ForInStatement else {
        XCTFail("Failed in parsing a for-in statement.")
        return
      }
      XCTAssertFalse(forInStmt.item.isCaseMatching)
      XCTAssertTrue(forInStmt.item.matchingPattern is IdentifierPattern)
      XCTAssertEqual(forInStmt.item.matchingPattern.textDescription, "e")
      XCTAssertTrue(forInStmt.collection is BinaryOperatorExpression)
      XCTAssertEqual(forInStmt.collection.textDescription, "0 ..< 9")
      XCTAssertNil(forInStmt.item.whereClause)
      XCTAssertTrue(forInStmt.codeBlock.statements.isEmpty)
    })
  }

  func testSourceRange() {
    parseStatementAndTest(
      "for i in aCollection { print(i) }",
      "for i in aCollection {\nprint(i)\n}",
      testClosure: { stmt in
        XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 34))
      }
    )
  }

  static var allTests = [
    ("testItemInCollection", testItemInCollection),
    ("testCaseMatching", testCaseMatching),
    ("testWhereClause", testWhereClause),
    ("testEnumerate", testEnumerate),
    ("testRange", testRange),
    ("testSourceRange", testSourceRange),
  ]
}
