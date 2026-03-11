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

@testable import Diagnostic
@testable import Source

private let recordSnapshots: Bool = {
  switch ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"]?.lowercased() {
  case "1", "true", "yes":
    return true
  default:
    return false
  }
}()

private final class DiagnosticCollector: DiagnosticConsumer {
  var diagnostics: [Diagnostic] = []

  func consume(diagnostics: [Diagnostic]) {
    self.diagnostics = diagnostics
  }
}

func testIntegration(
  _ resourceName: String,
  _ testName: String,
  decolor: Bool = true,
  convertor convert: (SourceFile, DiagnosticPool) -> String
) {
  let integrationPath = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path
  let testTarget = "\(resourceName)/\(testName)"
  let testPath = "\(integrationPath)/\(testTarget)"
  let sourcePath = "\(testPath).source"
  let resultPath = "\(testPath).result"

  guard let sourceContent = try? String(contentsOfFile: sourcePath, encoding: .utf8) else {
    XCTFail("Missing source file: \(sourcePath)")
    return
  }

  let sourceFile = SourceFile(
    path: "\(testTarget)Tests.swift", content: sourceContent)
  let diagnosticPool = DiagnosticPool()
  var result = convert(sourceFile, diagnosticPool)

  let collector = DiagnosticCollector()
  diagnosticPool.report(withConsumer: collector)
  if !collector.diagnostics.isEmpty && !result.hasPrefix("error: failed in parsing") {
    let rendered = collector.diagnostics.map { "\($0)" }.joined(separator: "\n")
    result = (result.isEmpty ? "" : result + "\n") + "error: unexpected diagnostics\n\(rendered)"
  }

  if decolor {
    result = result.replacingOccurrences(of: "\u{001B}[0m", with: "")
    for i in 0..<10 {
      result = result.replacingOccurrences(of: "\u{001B}[\(30+i)m", with: "")
    }
  }

  if recordSnapshots {
    let existingContent = try? String(contentsOfFile: resultPath, encoding: .utf8)
    if existingContent == result {
      return
    }
    do {
      try result.write(toFile: resultPath, atomically: true, encoding: .utf8)
      XCTFail("Recorded snapshot for \(testName) at \(resultPath)")
    } catch {
      XCTFail("Failed to record snapshot for \(testName) at \(resultPath): \(error)")
    }
    return
  }

  guard let resultContent = try? String(contentsOfFile: resultPath, encoding: .utf8) else {
    XCTFail(
      "Missing snapshot: \(resultPath)\n"
      + "Run with RECORD_SNAPSHOTS=1 to generate it."
    )
    return
  }

  XCTAssertEqual(result, resultContent)
}
