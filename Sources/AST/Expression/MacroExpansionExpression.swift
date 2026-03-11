/*
   Copyright 2026 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public class MacroExpansionExpression : ASTNode, PrimaryExpression {
  public let macroName: String
  public let genericArgumentClause: GenericArgumentClause?
  public private(set) var argumentClause: [FunctionCallExpression.Argument]?
  public let trailingClosure: ClosureExpression?
  public let additionalTrailingClosures: [(Identifier, ClosureExpression)]

  public init(
    macroName: String,
    genericArgumentClause: GenericArgumentClause? = nil,
    argumentClause: [FunctionCallExpression.Argument]? = nil,
    trailingClosure: ClosureExpression? = nil,
    additionalTrailingClosures: [(Identifier, ClosureExpression)] = []
  ) {
    self.macroName = macroName
    self.genericArgumentClause = genericArgumentClause
    self.argumentClause = argumentClause
    self.trailingClosure = trailingClosure
    self.additionalTrailingClosures = additionalTrailingClosures
  }

  // MARK: - Node Mutations

  public func replaceArgument(at index: Int, with argument: FunctionCallExpression.Argument) {
    guard index >= 0 && index < (argumentClause?.count ?? 0) else { return }
    argumentClause?[index] = argument
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    var result = "#\(macroName)"
    if let genericArgumentClause = genericArgumentClause {
      result += genericArgumentClause.textDescription
    }
    if let argumentClause = argumentClause {
      let argumentsText = argumentClause.map({ $0.textDescription }).joined(separator: ", ")
      result += "(\(argumentsText))"
    }
    if let trailingClosure = trailingClosure {
      result += " \(trailingClosure.textDescription)"
    }
    for (label, closure) in additionalTrailingClosures {
      result += " \(label): \(closure.textDescription)"
    }
    return result
  }
}
