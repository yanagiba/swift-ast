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

extension Statement {
  var ttyPrint: String {
    switch self {
    case let ttyAstPrintRepresentable as TTYASTPrintRepresentable:
      return ttyAstPrintRepresentable.ttyPrint
    default:
      return textDescription
    }
  }
}

extension Collection where Iterator.Element == Statement {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return self.map({ $0.ttyPrint }).joined(separator: "\n")
  }
}

extension CompilerControlStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return textDescription
  }
}

extension DeferStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "defer \(codeBlock.ttyPrint)"
  }
}

extension DoStatement.CatchClause : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    var patternText = ""
    if let pattern = pattern {
      patternText = " \(pattern.textDescription)"
    }
    var whereText = ""
    if let whereExpr = whereExpression {
      whereText = " where \(whereExpr.textDescription)"
    }
    return "catch\(patternText)\(whereText) \(codeBlock.ttyPrint)"
  }
}

extension DoStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      (["do \(codeBlock.ttyPrint)"] +
        catchClauses.map({ $0.ttyPrint })).joined(separator: " ")
  }
}

extension ForInStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    var descr = "for"
    if item.isCaseMatching {
      descr += " case"
    }
    descr += " \(item.matchingPattern.textDescription) in \(collection.textDescription) "
    if let whereClause = item.whereClause {
      descr += "where \(whereClause.textDescription) "
    }
    descr += codeBlock.ttyPrint
    return String(indentation: indentation) + descr
  }
}

extension GuardStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) + "guard \(conditionList.textDescription) else \(codeBlock.ttyPrint)"
  }
}

extension IfStatement.ElseClause : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    switch self {
    case .else(let codeBlock):
      return "else \(codeBlock.ttyPrint)"
    case .elseif(let ifStmt):
      return "else \(ifStmt.ttyASTPrintWithoutHeadIndentation(indentation: indentation))"
    }
  }
}

extension IfStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) + ttyASTPrintWithoutHeadIndentation(indentation: indentation)
  }

  fileprivate func ttyASTPrintWithoutHeadIndentation(indentation: Int) -> String {
    var elseText = ""
    if let elseClause = elseClause {
      elseText = " \(elseClause.ttyPrint)"
    }
    return "if \(conditionList.textDescription) \(codeBlock.ttyPrint)\(elseText)"
  }
}

extension RepeatWhileStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "repeat \(codeBlock.ttyPrint) while \(conditionExpression.textDescription)"
  }
}

extension SwitchStatement.Case : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

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
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    var casesDescr = "{}"
    if !cases.isEmpty {
      let casesText = cases.map({ $0.ttyPrint }).joined(separator: "\n")
      casesDescr = "{\n\(casesText)\n\(String(indentation: indentation))}"
    }
    return String(indentation: indentation) +
      "switch \(expression.textDescription) \(casesDescr)"
  }
}

extension WhileStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "while \(conditionList.textDescription) \(codeBlock.ttyPrint)"
  }
}

extension LabeledStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return ttyASTPrint(indentation: 0)
  }

  func ttyASTPrint(indentation: Int) -> String {
    return String(indentation: indentation) +
      "\(labelName): \(statement.ttyPrint)"
  }
}
