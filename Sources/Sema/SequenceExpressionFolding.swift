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
    private func fold(_ seqExpr: SequenceExpression) -> Expression {
      // Start with brutal hardcoding approach

      var multiplicationFoldedStack: [SequenceExpression.Element] = []

      var i = 0
      while i < seqExpr.elements.count {
        let e = seqExpr.elements[i]
        if case .binaryOperator(let op) = e,
          op == "*" || op == "/",
          case .expression(let lhs) = multiplicationFoldedStack.removeLast(),
          case .expression(let rhs) = seqExpr.elements[i+1]
        {
          let biOpExpr = BinaryOperatorExpression(
            binaryOperator: op,
            leftExpression: lhs,
            rightExpression: rhs)
          biOpExpr.setSourceRange(lhs.sourceRange.start, rhs.sourceRange.end)
          multiplicationFoldedStack.append(.expression(biOpExpr))
          i += 1
        } else {
          multiplicationFoldedStack.append(e)
        }
        i += 1
      }

      var additionFoldedStack: [SequenceExpression.Element] = []
      var j = 0
      while j < multiplicationFoldedStack.count {
        let e = multiplicationFoldedStack[j]
        if case .binaryOperator(let op) = e,
          op == "+" || op == "-",
          case .expression(let lhs) = additionFoldedStack.removeLast(),
          case .expression(let rhs) = multiplicationFoldedStack[j+1]
        {
          let biOpExpr = BinaryOperatorExpression(
            binaryOperator: op,
            leftExpression: lhs,
            rightExpression: rhs)
          biOpExpr.setSourceRange(lhs.sourceRange.start, rhs.sourceRange.end)
          additionFoldedStack.append(.expression(biOpExpr))
          j += 1
        } else {
          additionFoldedStack.append(e)
        }
        j += 1
      }

      guard additionFoldedStack.count == 1,
        case .expression(let resultExpr) = additionFoldedStack[0]
      else {
        return WildcardExpression()
      }

      return resultExpr
    }

    func visit(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
      for i in topLevelDecl.statements.indices {
        if let seqExpr = topLevelDecl.statements[i] as? SequenceExpression {
          let foldedExpr = fold(seqExpr)
          topLevelDecl.replaceStatement(at: i, with: foldedExpr)
        }
      }

      return true
    }
  }
}
