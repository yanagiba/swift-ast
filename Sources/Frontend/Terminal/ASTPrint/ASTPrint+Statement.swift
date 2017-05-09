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
    return self.map({ $0.ttyPrint }).joined(separator: "\n")
  }
}

extension Condition {
  var ttyPrint: String {
    switch self {
    case .expression(let expr):
      return expr.ttyPrint
    case let .case(pattern, expr):
      return "case \(pattern) = \(expr.ttyPrint)"
    case let .let(pattern, expr):
      return "let \(pattern) = \(expr.ttyPrint)"
    case let .var(pattern, expr):
      return "var \(pattern) = \(expr.ttyPrint)"
    default:
      return textDescription
    }
  }
}

extension Collection where Iterator.Element == Condition {
  var ttyPrint: String {
    return self.map({ $0.ttyPrint }).joined(separator: ", ")
  }
}

extension DeferStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "defer \(codeBlock.ttyPrint)"
  }
}

extension DoStatement.CatchClause {
  var ttyPrint: String {
    var patternText = ""
    if let pattern = pattern {
      patternText = " \(pattern.textDescription)"
    }
    var whereText = ""
    if let whereExpr = whereExpression {
      whereText = " where \(whereExpr.ttyPrint)"
    }
    return "catch\(patternText)\(whereText) \(codeBlock.ttyPrint)"
  }
}

extension DoStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return (["do \(codeBlock.ttyPrint)"] +
      catchClauses.map({ $0.ttyPrint })).joined(separator: " ")
  }
}

extension ForInStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    var descr = "for"
    if item.isCaseMatching {
      descr += " case"
    }
    descr += " \(item.matchingPattern.textDescription) in \(collection.ttyPrint) "
    if let whereClause = item.whereClause {
      descr += "where \(whereClause.ttyPrint) "
    }
    descr += codeBlock.ttyPrint
    return descr
  }
}

extension GuardStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "guard \(conditionList.ttyPrint) else \(codeBlock.ttyPrint)"
  }
}

extension IfStatement.ElseClause {
  var ttyPrint: String {
    switch self {
    case .else(let codeBlock):
      return "else \(codeBlock.ttyPrint)"
    case .elseif(let ifStmt):
      return "else \(ifStmt.ttyPrint)"
    }
  }
}

extension IfStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    var elseText = ""
    if let elseClause = elseClause {
      elseText = " \(elseClause.ttyPrint)"
    }
    return "if \(conditionList.ttyPrint) \(codeBlock.ttyPrint)\(elseText)"
  }
}

extension RepeatWhileStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "repeat \(codeBlock.ttyPrint) while \(conditionExpression.ttyPrint)"
  }
}

extension ReturnStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    if let expression = expression {
      return "return \(expression.ttyPrint)"
    }
    return "return"
  }
}

extension SwitchStatement.Case.Item {
  var ttyPrint: String {
    var whereText = ""
    if let whereExpr = whereExpression {
      whereText = " where \(whereExpr.ttyPrint)"
    }
    return "\(pattern.textDescription)\(whereText)"
  }
}

extension SwitchStatement.Case {
  var ttyPrint: String {
    switch self {
    case let .case(itemList, stmts):
      let itemListText = itemList.map({ $0.ttyPrint }).joined(separator: ", ")
      return "case \(itemListText):\n\(stmts.ttyPrint.indent)"
    case .default(let stmts):
      return "default:\n\(stmts.ttyPrint.indent)"
    }
  }
}

extension SwitchStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    var casesDescr = "{}"
    if !cases.isEmpty {
      let casesText = cases.map({ $0.ttyPrint }).joined(separator: "\n")
      casesDescr = "{\n\(casesText)\n}"
    }
    return "switch \(expression.ttyPrint) \(casesDescr)"
  }
}

extension ThrowStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "throw \(expression.ttyPrint)"
  }
}

extension WhileStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "while \(conditionList.ttyPrint) \(codeBlock.ttyPrint)"
  }
}

extension LabeledStatement : TTYASTPrintRepresentable {
  var ttyPrint: String {
    return "\(labelName): \(statement.ttyPrint)"
  }
}
