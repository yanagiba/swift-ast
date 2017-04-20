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

class ParserCompilerControlStatementTests: XCTestCase {
  func testIf() {
    parseStatementAndTest(
      "#if os(macOS)\nreturn",
      "#if os(macOS)",
      testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case .if(let condition) = compCtrlStmt.kind else {
        XCTFail("Failed in getting an if directive clause.")
        return
      }
      XCTAssertEqual(condition, " os(macOS)")
    })
    parseStatementAndTest("#if swift(>=3.1)\nreturn", "#if swift(>=3.1)")
    parseStatementAndTest("#if foo\nreturn", "#if foo")
    parseStatementAndTest("#if true\nreturn", "#if true")
    parseStatementAndTest("#if(foo)\nreturn", "#if(foo)")
    parseStatementAndTest("#if !bar\nreturn", "#if !bar")
    parseStatementAndTest("#if foo && bar \nreturn", "#if foo && bar ")
    parseStatementAndTest("#if foo || bar\nreturn", "#if foo || bar")
  }

  func testElseif() {
    parseStatementAndTest(
      "#elseif os(macOS)\nreturn",
      "#elseif os(macOS)",
      testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case .elseif(let condition) = compCtrlStmt.kind else {
        XCTFail("Failed in getting an elseif directive clause.")
        return
      }
      XCTAssertEqual(condition, " os(macOS)")
    })
    parseStatementAndTest("#elseif swift(>=3.1)\nreturn", "#elseif swift(>=3.1)")
    parseStatementAndTest("#elseif foo\nreturn", "#elseif foo")
    parseStatementAndTest("#elseif true\nreturn", "#elseif true")
    parseStatementAndTest("#elseif(foo)\nreturn", "#elseif(foo)")
    parseStatementAndTest("#elseif !bar\nreturn", "#elseif !bar")
    parseStatementAndTest("#elseif foo && bar \nreturn", "#elseif foo && bar ")
    parseStatementAndTest("#elseif foo || bar\nreturn", "#elseif foo || bar")
  }

  func testElse() {
    parseStatementAndTest("#else\nreturn", "#else", testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case .else = compCtrlStmt.kind else {
        XCTFail("Failed in getting an else directive clause.")
        return
      }
    })
    parseStatementAndTest("#else     \nreturn", "#else")
  }

  func testEndif() {
    parseStatementAndTest("#endif\nreturn", "#endif", testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case .endif = compCtrlStmt.kind else {
        XCTFail("Failed in getting an endif directive clause.")
        return
      }
    })
    parseStatementAndTest("#endif     \nreturn", "#endif")
  }

  func testSourceLocation() {
    parseStatementAndTest(
      "#sourceLocation(file:\"file-name\",line:10)\nreturn",
      "#sourceLocation(file: \"file-name\", line: 10)",
      testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case let .sourceLocation(fileName?, lineNumber?) = compCtrlStmt.kind else {
        XCTFail("Failed in getting a line control statement.")
        return
      }
      XCTAssertEqual(fileName, "file-name")
      XCTAssertEqual(lineNumber, 10)
    })
    parseStatementAndTest(
      "#sourceLocation(file:\"file-name\")\nreturn",
      "#sourceLocation()")
    parseStatementAndTest(
      "#sourceLocation(line:10)\nreturn",
      "#sourceLocation()")
    parseStatementAndTest(
      "#sourceLocation(        )foobar\nreturn",
      "#sourceLocation()")
    parseStatementAndTest(
      "#sourceLocation(foobar)\nreturn",
      "#sourceLocation()")
  }

  func testSourceRange() {
    parseStatementAndTest("#if os(macOS)\nreturn", "#if os(macOS)", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 14))
    })
    parseStatementAndTest("#elseif os(macOS)\nreturn", "#elseif os(macOS)", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 18))
    })
    parseStatementAndTest("#endif\nreturn", "#endif", testClosure: { stmt in
      XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 7))
    })
    parseStatementAndTest("#sourceLocation(foobar)\nreturn", "#sourceLocation()", testClosure: { stmt in
      // XCTAssertEqual(stmt.sourceRange, getRange(1, 1, 1, 24))
      // TODO: we will come back to this once the source location is parsed correctly
    })
  }

  static var allTests = [
    ("testIf", testIf),
    ("testElseif", testElseif),
    ("testElse", testElse),
    ("testEndif", testEndif),
    ("testSourceLocation", testSourceLocation),
    ("testSourceRange", testSourceRange), // ^ interesting coincidence
  ]
}
