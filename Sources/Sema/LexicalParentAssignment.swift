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

public struct LexicalParentAssignment {
  private let _assignmentVisitor = AssignmentVisitor()

  public init() {}

  public func assign(_ collection: ASTUnitCollection) {
    return collection.forEach(assign)
  }

  private func assign(_ unit: ASTUnit) {
    do {
      _ = try _assignmentVisitor.traverse(unit.translationUnit)
      unit.translationUnit.assignedLexicalParent()
    } catch {}
  }
}

private class AssignmentVisitor : ASTVisitor {
  func visit(_ topLevelDecl: TopLevelDeclaration) throws -> Bool {
    for stmt in topLevelDecl.statements {
      if let node = stmt as? ASTNode {
        node.setLexicalParent(topLevelDecl)
      }
    }

    return true
  }

  func visit(_ codeBlock: CodeBlock) throws -> Bool {
    for stmt in codeBlock.statements {
      if let node = stmt as? ASTNode {
        node.setLexicalParent(codeBlock)
      }
    }

    return true
  }
}
