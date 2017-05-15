/*
   Copyright 2015-2016 Ryuichi Saito, LLC and the Yanagiba project contributors

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

@testable import Parser
@testable import Source
@testable import Lexer
@testable import AST
@testable import Diagnostic

let sourcePath = "ParserTests/ParserTests.swift"

func getRange(
  _ startLine: Int, _ startColumn: Int, _ endLine: Int, _ endColumn: Int
) -> SourceRange {
  return SourceRange(
    start: SourceLocation(path: sourcePath, line: startLine, column: startColumn),
    end: SourceLocation(path: sourcePath, line: endLine, column: endColumn))
}

func parse(_ lines: String...) -> TopLevelDeclaration {
  let content = lines.joined(separator: "\n")
  let source = SourceFile(path: sourcePath, content: content)
  do {
    return try Parser(source: source).parse()
  } catch {
    fatalError("Failed in parsing `\(content)` with error: \(error)")
  }
}

func parseAttributesAndTest(_ content: String,
  _ expectedTextDescription: String,
  testClosure: ((Attributes) -> Void)? = nil,
  errorClosure: ((Error) -> Void)? = nil) {
  let attrParser = getParser(content)

  do {
    let result = try attrParser.parseAttributes()
    XCTAssertEqual(result.textDescription, expectedTextDescription)
    if let testClosure = testClosure {
      testClosure(result)
    }
  } catch {
    if let errorClosure = errorClosure {
      errorClosure(error)
    } else {
      XCTFail("Failed in parsing attributes `\(content)` with error: \(error)")
    }
  }
}

func parseTypeAndTest(_ content: String,
  _ expectedTextDescription: String,
  testClosure: ((Type) -> Void)? = nil,
  errorClosure: ((Error) -> Void)? = nil) {
  let typeParser = getParser(content)

  do {
    let result = try typeParser.parseType()
    XCTAssertEqual(result.textDescription, expectedTextDescription)
    if let testClosure = testClosure {
      testClosure(result)
    }
  } catch {
    if let errorClosure = errorClosure {
      errorClosure(error)
    } else {
      XCTFail("Failed in parsing type `\(content)` with error: \(error)")
    }
  }
}

func parseExpressionAndTest(_ content: String,
  _ expectedTextDescription: String,
  parseTrailingClosure: Bool = true,
  testClosure: ((Expression) -> Void)? = nil,
  errorClosure: ((Error) -> Void)? = nil) {
  let expressionParser = getParser(content)

  do {
    let config = ParserExpressionConfig(parseTrailingClosure: parseTrailingClosure)
    let result = try expressionParser.parseExpression(config: config)
    XCTAssertEqual(result.textDescription, expectedTextDescription)
    if let testClosure = testClosure {
      testClosure(result)
    }
  } catch {
    if let errorClosure = errorClosure {
      errorClosure(error)
    } else {
      XCTFail("Failed in parsing expression `\(content)` with error: \(error)")
    }
  }
}

func parsePatternAndTest(_ content: String,
  _ expectedTextDescription: String,
  fromForInOrVarDecl: Bool = false,
  forPatternMatching: Bool = false,
  fromTuplePattern: Bool = false,
  testClosure: ((AST.Pattern) -> Void)? = nil,
  errorClosure: ((Error) -> Void)? = nil) {
  let patternParser = getParser(content)

  do {
    let config = ParserPatternConfig(fromForInOrVarDecl: fromForInOrVarDecl,
      forPatternMatching: forPatternMatching, fromTuplePattern: fromTuplePattern)
    let result = try patternParser.parsePattern(config: config)
    XCTAssertEqual(result.textDescription, expectedTextDescription)
    if let testClosure = testClosure {
      testClosure(result)
    }
  } catch {
    if let errorClosure = errorClosure {
      errorClosure(error)
    } else {
      XCTFail("Failed in parsing pattern `\(content)` with error: \(error)")
    }
  }
}

func parseStatementAndTest(_ content: String,
  _ expectedTextDescription: String,
  testClosure: ((Statement) -> Void)? = nil,
  errorClosure: ((Error) -> Void)? = nil) {
  let statementParser = getParser(content)

  do {
    let result = try statementParser.parseStatement()
    XCTAssertEqual(result.textDescription, expectedTextDescription)
    if let testClosure = testClosure {
      testClosure(result)
    }
  } catch {
    if let errorClosure = errorClosure {
      errorClosure(error)
    } else {
      XCTFail("Failed in parsing statement `\(content)` with error: \(error)")
    }
  }
}

func parseDeclarationAndTest(_ content: String,
  _ expectedTextDescription: String,
  testClosure: ((Declaration) -> Void)? = nil,
  errorClosure: ((Error) -> Void)? = nil) {
  let declarationParser = getParser(content)

  do {
    let result = try declarationParser.parseDeclaration()
    XCTAssertEqual(result.textDescription, expectedTextDescription)
    if let testClosure = testClosure {
      testClosure(result)
    }
  } catch {
    if let errorClosure = errorClosure {
      errorClosure(error)
    } else {
      XCTFail("Failed in parsing declaration `\(content)` with error: \(error)")
    }
  }
}

func parseProblematic(
  _ content: String,
  _ expectedDiagnosticLevel: Diagnostic.Level,
  _ expectedParserErrorKind: ParserErrorKind
) {
  class TestParserDiagnosticConsumer : DiagnosticConsumer {
    var diagnostics: [Diagnostic] = []

    func consume(diagnostics: [Diagnostic]) {
      self.diagnostics = diagnostics
    }
  }

  DiagnosticPool.shared.clear()
  do {
    _ = try getParser(content).parse()
  } catch {}

  let diagnosticConsumer = TestParserDiagnosticConsumer()
  DiagnosticPool.shared.report(withConsumer: diagnosticConsumer)
  let diagnostics = diagnosticConsumer.diagnostics
  switch diagnostics.count {
  case 0:
    XCTFail("Failed in getting any diagnostics.")
  case 1:
    let diagnostic = diagnostics[0]
    XCTAssertEqual(diagnostic.level, expectedDiagnosticLevel)
    guard let parserError = diagnostic.kind as? ParserErrorKind else {
      XCTFail("Failed in getting parser error kind.")
      return
    }
    XCTAssertEqual(parserError.diagnosticMessage,
      expectedParserErrorKind.diagnosticMessage)
  default:
    for d in diagnostics {
      print("\(d.location) \(d.level): \(d.kind.diagnosticMessage)")
    }
    XCTFail("Getting too many diagnostics (\(diagnostics.count)).")
  }
}

func getParser(_ content: String) -> Parser {
  let source = SourceFile(path: "ParserTests/ParserTests.swift", content: content)
  return Parser(source: source)
}
