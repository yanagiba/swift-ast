/*
   Copyright 2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import AST
import Parser
import Source
import Diagnostic
import Sema

open class ToolAction {
  public init() {}

  open func run(
    sourceFiles: [SourceFile],
    diagnosticConsumer: DiagnosticConsumer,
    option: ToolActionOption = ToolActionOption()
  ) -> ToolActionResult {
    var unitCollection: ASTUnitCollection = []
    var unparsedSourceFiles: [SourceFile] = []

    for sourceFile in sourceFiles {
      DiagnosticPool.shared.clear()

      let parser = Parser(source: sourceFile)
      if let topLevelDecl = try? parser.parse() {
        unitCollection.append(topLevelDecl)
      } else {
        unparsedSourceFiles.append(sourceFile)
      }

      DiagnosticPool.shared.report(withConsumer: diagnosticConsumer)
    }

    guard unparsedSourceFiles.isEmpty else {
      return .failedParsing(
        withSuccessUnitCollection: unitCollection,
        andUnparsedSourceFiles: unparsedSourceFiles)
    }

    if option.sequenceExpressionFoldingEnabled {
      let seqExprFolding = SequenceExpressionFolding()
      unitCollection = seqExprFolding.fold(unitCollection)
    }

    return .success(withUnitCollection: unitCollection)
  }
}
