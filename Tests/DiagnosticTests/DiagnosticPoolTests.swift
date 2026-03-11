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

@testable import Source
@testable import Diagnostic

fileprivate struct DiagnosticTestKind : DiagnosticKind {
  let testKind: String

  init(testKind: String) {
    self.testKind = testKind
  }

  var diagnosticMessage: String {
    return testKind
  }
}

fileprivate struct SourceTestLocation : SourceLocatable {
  var sourceRange: SourceRange = .INVALID
}

class DiagnosticPoolTests : XCTestCase {
  var diagnosticPool = DiagnosticPool()

  override func setUp() {
    super.setUp()
    diagnosticPool.clear()
  }

  fileprivate func retrieveDiagnostics() -> [Diagnostic] {
    class DiagnosticTestConsumer : DiagnosticConsumer {
      var diagnostics: [Diagnostic] = []

      func consume(diagnostics: [Diagnostic]) {
        self.diagnostics = diagnostics
      }
    }

    let diagnosticConsumer = DiagnosticTestConsumer()
    diagnosticPool.report(withConsumer: diagnosticConsumer)
    return diagnosticConsumer.diagnostics
  }

  func testAppendFatal() {
    _ = diagnosticPool.appendFatal(
      kind: DiagnosticTestKind(testKind: "fatal"),
      sourceLocatable: SourceTestLocation())
    let diagnostics = retrieveDiagnostics()

    XCTAssertEqual(diagnostics.count, 1)
  }

  func testAppendError() {
    do {
      try diagnosticPool.appendError(
        kind: DiagnosticTestKind(testKind: "error"),
        sourceLocatable: SourceTestLocation())
      let diagnostics = retrieveDiagnostics()

      XCTAssertEqual(diagnostics.count, 1)
    } catch {
      XCTFail("One error shouldn't stop.")
    }
  }

  func testAppendTooManyErrors() {
    do {
      for _ in 0..<10 {
        try diagnosticPool.appendError(
          kind: DiagnosticTestKind(testKind: "error"),
          sourceLocatable: SourceTestLocation())
      }

      XCTFail("Expect to get exception for too many errors.")
    } catch {
      let diagnostics = retrieveDiagnostics()

      XCTAssertEqual(diagnostics.count, 10)
    }
  }

  func testAppendWarning() {
    do {
      try diagnosticPool.appendWarning(
        kind: DiagnosticTestKind(testKind: "warning"),
        sourceLocatable: SourceTestLocation())
      let diagnostics = retrieveDiagnostics()

      XCTAssertEqual(diagnostics.count, 1)
    } catch {
      XCTFail("One warning shouldn't stop.")
    }
  }

  func testAppendTooManyWarnings() {
    do {
      for _ in 0..<50 {
        try diagnosticPool.appendWarning(
          kind: DiagnosticTestKind(testKind: "warning"),
          sourceLocatable: SourceTestLocation())
      }

      XCTFail("Expect to get exception for too many warnings.")
    } catch {
      let diagnostics = retrieveDiagnostics()

      XCTAssertEqual(diagnostics.count, 50)
    }
  }

  func testRestoreFromCheckpoint() {
    XCTAssertFalse(diagnosticPool.restore(fromCheckpoint: ""))
  }
}
