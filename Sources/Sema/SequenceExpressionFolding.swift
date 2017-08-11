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

public struct SequenceExpressionFolding {
  private let _foldingVisitor = FoldingVisitor()

  public init() {}

  public func fold(_ collection: ASTUnitCollection) {
    return collection.forEach(fold)
  }

  private func fold(_ unit: ASTUnit) {
    do {
      _ = try _foldingVisitor.traverse(unit.translationUnit)
    } catch {}
  }

  private class FoldingVisitor : ASTVisitor {
    func visit(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
      for i in topLevelDecl.statements.indices {
        if let seqExpr = topLevelDecl.statements[i] as? SequenceExpression {
          let foldedExpr = foldSequenceExpression(seqExpr)
          topLevelDecl.replaceStatement(at: i, with: foldedExpr)
        }
      }

      return true
    }
  }
}

private func foldElements(
  _ elements: [SequenceExpression.Element],
  forBinaryOperators biOps: [String]
) -> [SequenceExpression.Element] {
  guard elements.count >= 3 else {
    return elements
  }

  var resultElements: [SequenceExpression.Element] = []

  var i = 0
  while i < elements.count {
    let e = elements[i]
    if case .binaryOperator(let op) = e,
      biOps.contains(op),
      case .expression(let lhs)? = resultElements.last,
      case .expression(let rhs) = elements[i+1]
    {
      resultElements.removeLast()
      let biOpExpr = BinaryOperatorExpression(
        binaryOperator: op,
        leftExpression: lhs,
        rightExpression: rhs)
      biOpExpr.setSourceRange(lhs.sourceRange.start, rhs.sourceRange.end)
      resultElements.append(.expression(biOpExpr))
      i += 1
    } else {
      resultElements.append(e)
    }
    i += 1
  }

  return resultElements
}

private func foldSequenceExpression(_ seqExpr: SequenceExpression) -> Expression {
  // Start with brutal hardcoding approach

  var resultElements = foldElements(seqExpr.elements,
    forBinaryOperators: ["<<", ">>"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["*", "&*", "/", "%", "&"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["+", "&+", "-", "&-", "|", "^"])
  resultElements = foldElements(resultElements, forBinaryOperators: ["...", "..<"])
  resultElements = foldElements(resultElements, forBinaryOperators: ["??"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["<", "<=", ">", ">=", "==", "!=", "===", "!==", "~=",])
  resultElements = foldElements(resultElements, forBinaryOperators: ["&&"])
  resultElements = foldElements(resultElements, forBinaryOperators: ["||"])
  resultElements = foldElements(resultElements,
    forBinaryOperators: ["*=", "/=", "%=", "+=", "-=", "<<=", ">>=", "&=", "^=", "|=",])

  guard resultElements.count == 1,
    case .expression(let resultExpr) = resultElements[0]
  else {
    fatalError("Failed in folding sequence expression `\(seqExpr)`.")
  }

  return resultExpr
}
