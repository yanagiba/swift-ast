/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

extension Collection where Iterator.Element == Statement {
  func ttyASTPrint(indentation: Int) -> String {
    return self.map({ $0.ttyASTPrint(indentation: indentation) }).joined(separator: "\n")
  }
}

extension Statement {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case let expr as TTYASTPrintExpression:
      return String(indentation: indentation) + expr.ttyASTPrint(indentation: indentation)
    case let representable as TTYASTPrintRepresentable:
      return representable.ttyASTPrint(indentation: indentation)
    default:
      return String(indentation: indentation) + textDescription
    }
  }
}

extension CompilerControlStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return textDescription
  }
}

extension DeferStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "defer \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension DoStatement.CatchClause : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    var patternText = ""
    if let pattern = pattern {
      patternText = " \(pattern.textDescription)"
    }
    var whereText = ""
    if let whereExpr = whereExpression {
      whereText = " where \(whereExpr.textDescription)"
    }
    return "catch\(patternText)\(whereText) \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension DoStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      (["do \(codeBlock.ttyASTPrint(indentation: indentation))"] +
        catchClauses.map({ $0.ttyASTPrint(indentation: indentation) })).joined(separator: " ")
  }
}

extension ForInStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    var descr = "for"
    if item.isCaseMatching {
      descr += " case"
    }
    descr += " \(item.matchingPattern.textDescription) in \(collection.textDescription) "
    if let whereClause = item.whereClause {
      descr += "where \(whereClause.textDescription) "
    }
    descr += codeBlock.ttyASTPrint(indentation: indentation)
    return String(indentation: indentation) + descr
  }
}

extension GuardStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) + "guard \(conditionList.textDescription) else \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension IfStatement.ElseClause : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .else(let codeBlock):
      return "else \(codeBlock.ttyASTPrint(indentation: indentation))"
    case .elseif(let ifStmt):
      return "else \(ifStmt.ttyASTPrintWithoutHeadIndentation(indentation: indentation))"
    }
  }
}

extension IfStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) + ttyASTPrintWithoutHeadIndentation(indentation: indentation)
  }

  fileprivate func ttyASTPrintWithoutHeadIndentation(indentation: Int) -> String {
    var elseText = ""
    if let elseClause = elseClause {
      elseText = " \(elseClause.ttyASTPrint(indentation: indentation))"
    }
    return "if \(conditionList.textDescription) \(codeBlock.ttyASTPrint(indentation: indentation))\(elseText)"
  }
}

extension RepeatWhileStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "repeat \(codeBlock.ttyASTPrint(indentation: indentation)) while \(conditionExpression.textDescription)"
  }
}

extension SwitchStatement.Case : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case let .case(itemList, stmts):
      let itemListText = itemList.map({ $0.textDescription }).joined(separator: ", ")
      return String(indentation: indentation) + "case \(itemListText):\n\(stmts.ttyASTPrint(indentation: indentation + 1))"
    case .default(let stmts):
      return String(indentation: indentation) + "default:\n\(stmts.ttyASTPrint(indentation: indentation + 1))"
    }
  }
}

extension SwitchStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    var casesDescr = "{}"
    if !cases.isEmpty {
      let casesText = cases.map({ $0.ttyASTPrint(indentation: indentation) }).joined(separator: "\n")
      casesDescr = "{\n\(casesText)\n\(String(indentation: indentation))}"
    }
    return String(indentation: indentation) +
      "switch \(expression.textDescription) \(casesDescr)"
  }
}

extension WhileStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "while \(conditionList.textDescription) \(codeBlock.ttyASTPrint(indentation: indentation))"
  }
}

extension LabeledStatement : TTYASTPrintRepresentable {
  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "\(labelName): \(statement.ttyASTPrint(indentation: indentation))"
  }
}
