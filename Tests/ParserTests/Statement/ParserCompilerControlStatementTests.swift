/*
   Copyright 2017, 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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
      guard case .os(let name) = condition else {
        XCTFail("Expected os() condition.")
        return
      }
      XCTAssertEqual(name, "macOS")
    })
    parseStatementAndTest("#if swift(>=3.1)\nreturn", "#if swift(>=3.1)")
    parseStatementAndTest("#if foo\nreturn", "#if foo")
    parseStatementAndTest("#if true\nreturn", "#if true")
    parseStatementAndTest("#if(foo)\nreturn", "#if (foo)")
    parseStatementAndTest("#if !bar\nreturn", "#if !bar")
    parseStatementAndTest("#if foo && bar\nreturn", "#if foo && bar")
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
      guard case .os(let name) = condition else {
        XCTFail("Expected os() condition.")
        return
      }
      XCTAssertEqual(name, "macOS")
    })
    parseStatementAndTest("#elseif swift(>=3.1)\nreturn", "#elseif swift(>=3.1)")
    parseStatementAndTest("#elseif foo\nreturn", "#elseif foo")
    parseStatementAndTest("#elseif true\nreturn", "#elseif true")
    parseStatementAndTest("#elseif(foo)\nreturn", "#elseif (foo)")
    parseStatementAndTest("#elseif !bar\nreturn", "#elseif !bar")
    parseStatementAndTest("#elseif foo && bar\nreturn", "#elseif foo && bar")
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

  // MARK: - Diagnostic Directives

  func testWarning() {
    parseStatementAndTest(
      "#warning(\"message\")\nreturn",
      "#warning(\"message\")",
      testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case .warning(let message) = compCtrlStmt.kind else {
        XCTFail("Failed in getting a warning directive.")
        return
      }
      XCTAssertEqual(message, "message")
    })
  }

  func testError() {
    parseStatementAndTest(
      "#error(\"something went wrong\")\nreturn",
      "#error(\"something went wrong\")",
      testClosure: { stmt in
      guard let compCtrlStmt = stmt as? CompilerControlStatement else {
        XCTFail("Failed in parsing a compiler control statement.")
        return
      }
      guard case .error(let message) = compCtrlStmt.kind else {
        XCTFail("Failed in getting an error directive.")
        return
      }
      XCTAssertEqual(message, "something went wrong")
    })
  }

  // MARK: - Structured Compilation Conditions

  func testCompilerCondition() {
    parseStatementAndTest("#if compiler(>=5.5)\nreturn", "#if compiler(>=5.5)")
    parseStatementAndTest("#if compiler(<6.0)\nreturn", "#if compiler(<6.0)")
    parseStatementAndTest(
      "#if compiler(>=5.5)\nreturn",
      "#if compiler(>=5.5)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement else {
          XCTFail("Failed in parsing a compiler control statement.")
          return
        }
        guard case .if(let condition) = compCtrlStmt.kind else {
          XCTFail("Failed in getting an if directive clause.")
          return
        }
        guard case .compiler(let op, let version) = condition else {
          XCTFail("Expected compiler() condition.")
          return
        }
        XCTAssertEqual(op, ">=")
        XCTAssertEqual(version, "5.5")
      }
    )
  }

  func testCanImportCondition() {
    parseStatementAndTest("#if canImport(Foundation)\nreturn", "#if canImport(Foundation)")
    parseStatementAndTest("#if canImport(UIKit)\nreturn", "#if canImport(UIKit)")
    parseStatementAndTest("#if canImport(SwiftUI)\nreturn", "#if canImport(SwiftUI)")
    parseStatementAndTest(
      "#if canImport(Foundation)\nreturn",
      "#if canImport(Foundation)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement else {
          XCTFail("Failed in parsing a compiler control statement.")
          return
        }
        guard case .if(let condition) = compCtrlStmt.kind else {
          XCTFail("Failed in getting an if directive clause.")
          return
        }
        guard case .canImport(let path) = condition else {
          XCTFail("Expected canImport() condition.")
          return
        }
        XCTAssertEqual(path, "Foundation")
      }
    )
  }

  func testCanImportWithSubmodule() {
    parseStatementAndTest("#if canImport(Foundation.Networking)\nreturn", "#if canImport(Foundation.Networking)")
    parseStatementAndTest(
      "#if canImport(Foundation.Networking)\nreturn",
      "#if canImport(Foundation.Networking)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .canImport(let path) = condition else {
          XCTFail("Failed to parse canImport with submodule.")
          return
        }
        XCTAssertEqual(path, "Foundation.Networking")
      }
    )
  }

  func testHasFeatureCondition() {
    parseStatementAndTest("#if hasFeature(ExistentialAny)\nreturn", "#if hasFeature(ExistentialAny)")
    parseStatementAndTest(
      "#if hasFeature(ExistentialAny)\nreturn",
      "#if hasFeature(ExistentialAny)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .hasFeature(let feature) = condition else {
          XCTFail("Failed to parse hasFeature condition.")
          return
        }
        XCTAssertEqual(feature, "ExistentialAny")
      }
    )
  }

  func testTargetEnvironmentMacCatalyst() {
    parseStatementAndTest("#if targetEnvironment(macCatalyst)\nreturn", "#if targetEnvironment(macCatalyst)")
    parseStatementAndTest(
      "#if targetEnvironment(macCatalyst)\nreturn",
      "#if targetEnvironment(macCatalyst)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .targetEnvironment(let env) = condition else {
          XCTFail("Failed to parse targetEnvironment condition.")
          return
        }
        XCTAssertEqual(env, "macCatalyst")
      }
    )
  }

  func testTargetEnvironmentSimulator() {
    parseStatementAndTest("#if targetEnvironment(simulator)\nreturn", "#if targetEnvironment(simulator)")
  }

  func testVisionOSCondition() {
    parseStatementAndTest("#if os(visionOS)\nreturn", "#if os(visionOS)")
    parseStatementAndTest(
      "#if os(visionOS)\nreturn",
      "#if os(visionOS)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .os(let name) = condition else {
          XCTFail("Failed to parse os() condition.")
          return
        }
        XCTAssertEqual(name, "visionOS")
      }
    )
  }

  func testCombinedConditions() {
    parseStatementAndTest("#if compiler(>=5.5) && canImport(SwiftUI)\nreturn", "#if compiler(>=5.5) && canImport(SwiftUI)")
    parseStatementAndTest("#if os(iOS) || os(visionOS)\nreturn", "#if os(iOS) || os(visionOS)")
    parseStatementAndTest("#if canImport(UIKit) && !os(visionOS)\nreturn", "#if canImport(UIKit) && !os(visionOS)")
    parseStatementAndTest("#if compiler(>=5.8) && hasFeature(ExistentialAny)\nreturn", "#if compiler(>=5.8) && hasFeature(ExistentialAny)")
    parseStatementAndTest(
      "#if compiler(>=6.0) && canImport(SwiftUI) && os(visionOS)\nreturn",
      "#if compiler(>=6.0) && canImport(SwiftUI) && os(visionOS)"
    )
  }

  func testStructuredCombinedCondition() {
    parseStatementAndTest(
      "#if compiler(>=5.5) && canImport(SwiftUI)\nreturn",
      "#if compiler(>=5.5) && canImport(SwiftUI)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .and(let lhs, let rhs) = condition else {
          XCTFail("Failed to parse combined condition.")
          return
        }
        guard case .compiler(let op, let version) = lhs else {
          XCTFail("Expected compiler() on lhs.")
          return
        }
        XCTAssertEqual(op, ">=")
        XCTAssertEqual(version, "5.5")
        guard case .canImport(let path) = rhs else {
          XCTFail("Expected canImport() on rhs.")
          return
        }
        XCTAssertEqual(path, "SwiftUI")
      }
    )
  }

  func testOrCondition() {
    parseStatementAndTest(
      "#if os(iOS) || os(visionOS)\nreturn",
      "#if os(iOS) || os(visionOS)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .or(let lhs, let rhs) = condition else {
          XCTFail("Failed to parse || condition.")
          return
        }
        guard case .os(let lhsName) = lhs else {
          XCTFail("Expected os() on lhs.")
          return
        }
        XCTAssertEqual(lhsName, "iOS")
        guard case .os(let rhsName) = rhs else {
          XCTFail("Expected os() on rhs.")
          return
        }
        XCTAssertEqual(rhsName, "visionOS")
      }
    )
  }

  func testNegationCondition() {
    parseStatementAndTest(
      "#if !bar\nreturn",
      "#if !bar",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .not(let inner) = condition else {
          XCTFail("Failed to parse negation condition.")
          return
        }
        guard case .identifier(let name) = inner else {
          XCTFail("Expected identifier inside negation.")
          return
        }
        XCTAssertEqual(name, "bar")
      }
    )
  }

  func testParenthesizedCondition() {
    parseStatementAndTest(
      "#if(foo)\nreturn",
      "#if (foo)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .parenthesized(let inner) = condition else {
          XCTFail("Failed to parse parenthesized condition.")
          return
        }
        guard case .identifier(let name) = inner else {
          XCTFail("Expected identifier inside parens.")
          return
        }
        XCTAssertEqual(name, "foo")
      }
    )
  }

  func testBooleanLiteralCondition() {
    parseStatementAndTest(
      "#if true\nreturn",
      "#if true",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .booleanLiteral(let value) = condition else {
          XCTFail("Failed to parse boolean condition.")
          return
        }
        XCTAssertTrue(value)
      }
    )
    parseStatementAndTest(
      "#if false\nreturn",
      "#if false",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .booleanLiteral(let value) = condition else {
          XCTFail("Failed to parse boolean false condition.")
          return
        }
        XCTAssertFalse(value)
      }
    )
  }

  func testIdentifierCondition() {
    parseStatementAndTest(
      "#if DEBUG\nreturn",
      "#if DEBUG",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .identifier(let name) = condition else {
          XCTFail("Failed to parse identifier condition.")
          return
        }
        XCTAssertEqual(name, "DEBUG")
      }
    )
  }

  func testSwiftVersionCondition() {
    parseStatementAndTest(
      "#if swift(>=3.1)\nreturn",
      "#if swift(>=3.1)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .swift(let op, let version) = condition else {
          XCTFail("Failed to parse swift() condition.")
          return
        }
        XCTAssertEqual(op, ">=")
        XCTAssertEqual(version, "3.1")
      }
    )
  }

  func testSwiftLessThanCondition() {
    parseStatementAndTest(
      "#if swift(<6.0)\nreturn",
      "#if swift(<6.0)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .swift(let op, let version) = condition else {
          XCTFail("Failed to parse swift(<) condition.")
          return
        }
        XCTAssertEqual(op, "<")
        XCTAssertEqual(version, "6.0")
      }
    )
  }

  func testArchCondition() {
    parseStatementAndTest("#if arch(arm64)\nreturn", "#if arch(arm64)")
    parseStatementAndTest(
      "#if arch(x86_64)\nreturn",
      "#if arch(x86_64)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .arch(let name) = condition else {
          XCTFail("Failed to parse arch() condition.")
          return
        }
        XCTAssertEqual(name, "x86_64")
      }
    )
  }

  func testNegationWithPlatformCondition() {
    parseStatementAndTest(
      "#if canImport(UIKit) && !os(visionOS)\nreturn",
      "#if canImport(UIKit) && !os(visionOS)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .and(let lhs, let rhs) = condition else {
          XCTFail("Failed to parse condition.")
          return
        }
        guard case .canImport(let path) = lhs else {
          XCTFail("Expected canImport on lhs.")
          return
        }
        XCTAssertEqual(path, "UIKit")
        guard case .not(let inner) = rhs, case .os(let name) = inner else {
          XCTFail("Expected !os() on rhs.")
          return
        }
        XCTAssertEqual(name, "visionOS")
      }
    )
  }

  func testTripleAndCondition() {
    parseStatementAndTest(
      "#if compiler(>=6.0) && canImport(SwiftUI) && os(visionOS)\nreturn",
      "#if compiler(>=6.0) && canImport(SwiftUI) && os(visionOS)",
      testClosure: { stmt in
        guard let compCtrlStmt = stmt as? CompilerControlStatement,
              case .if(let condition) = compCtrlStmt.kind,
              case .and(let first, let rest) = condition else {
          XCTFail("Failed to parse triple && condition.")
          return
        }
        guard case .compiler(let op, let version) = first else {
          XCTFail("Expected compiler() as first.")
          return
        }
        XCTAssertEqual(op, ">=")
        XCTAssertEqual(version, "6.0")
        // rest should be: canImport(SwiftUI) && os(visionOS)
        guard case .and(let second, let third) = rest else {
          XCTFail("Expected && for rest.")
          return
        }
        guard case .canImport(let path) = second else {
          XCTFail("Expected canImport as second.")
          return
        }
        XCTAssertEqual(path, "SwiftUI")
        guard case .os(let name) = third else {
          XCTFail("Expected os() as third.")
          return
        }
        XCTAssertEqual(name, "visionOS")
      }
    )
  }
}
