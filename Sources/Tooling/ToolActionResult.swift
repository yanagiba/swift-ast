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

import Source
import AST

open class ToolActionResult {
  // system (0 ~ -9)
  public static let success: Int32 = 0
  public static let undefined: Int32 = -1
  // parse (-10 ~ -29)
  public static let parsingFailed: Int32 = -10
  // sema (-30 ~ ∞)
  public static let operatorPrecedenceSortingFailed: Int32 = -30
  public static let sequenceExpressionFoldingFailed: Int32 = -31

  open var exitCode: Int32 = undefined
  open var astUnitCollection: ASTUnitCollection = []
  open var unparsedSourceFiles: [SourceFile] = []

  public static func success(
    withUnitCollection collection: ASTUnitCollection
  ) -> ToolActionResult {
    let result = ToolActionResult()
    result.exitCode = success
    result.astUnitCollection = collection
    return result
  }

  public static func failedParsing(
    withSuccessUnitCollection collection: ASTUnitCollection,
    andUnparsedSourceFiles files: [SourceFile]
  ) -> ToolActionResult {
    let result = ToolActionResult()
    result.exitCode = parsingFailed
    result.astUnitCollection = collection
    result.unparsedSourceFiles = files
    return result
  }
}
