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

import Source

public struct PatternInitializer {
  public let pattern: Pattern
  public let initializerExpression: Expression?

  public init(pattern: Pattern, initializerExpression: Expression? = nil) {
    self.pattern = pattern
    self.initializerExpression = initializerExpression
  }
}

extension PatternInitializer : SourceLocatable {
  public var sourceRange: SourceRange {
    guard let initExpr = initializerExpression else {
      return pattern.sourceRange
    }
    return SourceRange(
      start: pattern.sourceLocation, end: initExpr.sourceRange.end)
  }
}

extension PatternInitializer : ASTTextRepresentable {
  public var textDescription: String {
    let pttrnText = pattern.textDescription
    guard let initExpr = initializerExpression else {
      return pttrnText
    }
    return "\(pttrnText) = \(initExpr.textDescription)"
  }
}
