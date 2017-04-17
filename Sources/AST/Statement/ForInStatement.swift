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

public class ForInStatement : ASTNode, Statement {
  public struct Item { // Note: not sure if this additional nesting structure would help in a long run, but I will leave it as it is, and decide this later
    public let isCaseMatching: Bool
    public let matchingPattern: Pattern
    public let whereClause: Expression?
  }
  public let item: Item
  public let collection: Expression
  public let codeBlock: CodeBlock

  public init(
    isCaseMatching: Bool = false,
    matchingPattern: Pattern,
    collection: Expression,
    whereClause: Expression? = nil,
    codeBlock: CodeBlock
  ) {
    self.item = Item(isCaseMatching: isCaseMatching,
      matchingPattern: matchingPattern, whereClause: whereClause)
    self.collection = collection
    self.codeBlock = codeBlock
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    var descr = "for"
    if item.isCaseMatching {
      descr += " case"
    }
    descr += " \(item.matchingPattern.textDescription) in \(collection.textDescription) "
    if let whereClause = item.whereClause {
      descr += "where \(whereClause.textDescription) "
    }
    descr += codeBlock.textDescription
    return descr
  }
}
