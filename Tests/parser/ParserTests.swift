/*
   Copyright 2015-2016 Ryuichi Saito, LLC

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

@testable import source
@testable import ast
@testable import parser

extension Parser {
  func parse(_ text: String) -> (astContext: ASTContext, errors: [String]) {
    return parse(source: getTestSourceFile(text))
  }

  func setupTestCode(_ text: String) {
    let lexer = Lexer()
    let lexicalContext = lexer.lex(source: getTestSourceFile(text))
    reversedTokens = lexicalContext.tokens.reversed()
    consumedTokens = [TokenWithLocation]()
    shiftToken()
  }

  private func getTestSourceFile(_ text: String) -> SourceFile {
    return SourceFile(path: "test/parser", content: text)
  }
}

extension Statement {
  var testSourceRangeDescription: String {
    return "\(sourceRange.start.path)[\(sourceRange.start.line):\(sourceRange.start.column)-\(sourceRange.end.line):\(sourceRange.end.column)]"
  }
}

class ParserTests: XCTestCase {
  let parser = Parser()

  func testParseEmptyFile() {
    let (astContext, errors) = parser.parse("")
    XCTAssertEqual(errors.count, 0)
    XCTAssertEqual(astContext.topLevelDeclaration.testSourceRangeDescription, "<unknown>[0:0-0:0]")
    XCTAssertEqual(astContext.topLevelDeclaration.statements.count, 0)
  }

  func testParserShouldSkipStatementSeparators() {
    let testSeparators = [";", "\n", "\r", "\r\n", ";;;", "\n\n\n", "  \n   "]
    for testSeparator in testSeparators {
      let (astContext, errors) = parser.parse("import ast\(testSeparator)import ast")
      XCTAssertEqual(errors.count, 0)
      let nodes = astContext.topLevelDeclaration.statements
      XCTAssertEqual(nodes.count, 2)
      guard let node1 = nodes[0] as? ImportDeclaration, node2 = nodes[1] as? ImportDeclaration else {
        XCTFail("Nodes are not ImportDeclaration.")
        return
      }
      XCTAssertEqual(node1.module, "ast")
      XCTAssertEqual(node2.module, "ast")
    }
  }

  func testParserShouldEmitErrorsWithMissingSeparators() {
    let (astContext, errors) = parser.parse("import foo import bar")
    XCTAssertEqual(errors.count, 1)
    XCTAssertEqual(errors[0], "Statements must be separated by line breaks or semicolons.")
    XCTAssertEqual(astContext.topLevelDeclaration.testSourceRangeDescription, "test/parser[1:1-1:22]")
    let nodes = astContext.topLevelDeclaration.statements
    XCTAssertEqual(nodes.count, 2)
    guard let node1 = nodes[0] as? ImportDeclaration, node2 = nodes[1] as? ImportDeclaration else {
      XCTFail("Nodes are not ImportDeclaration.")
      return
    }
    XCTAssertEqual(node1.module, "foo")
    XCTAssertEqual(node1.testSourceRangeDescription, "test/parser[1:1-1:11]")
    XCTAssertEqual(node2.module, "bar")
    XCTAssertEqual(node2.testSourceRangeDescription, "test/parser[1:12-1:22]")
  }
}
