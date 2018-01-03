/*
   Copyright 2016-2018 Ryuichi Laboratories and the Yanagiba project contributors

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

public class ClosureExpression : ASTNode, PrimaryExpression {
  public struct Signature {
    public struct CaptureItem {
      public enum Specifier : String {
        case weak
        case unowned
        case unownedSafe = "unowned(safe)"
        case unownedUnsafe = "unowned(unsafe)"
      }

      public let specifier: Specifier?
      public let expression: Expression

      public init(specifier: Specifier? = nil, expression: Expression) {
        self.specifier = specifier
        self.expression = expression
      }
    }

    public enum ParameterClause {
      public struct Parameter {
        public let name: Identifier
        public let typeAnnotation: TypeAnnotation?
        public let isVarargs: Bool

        public init(
          name: Identifier,
          typeAnnotation: TypeAnnotation? = nil,
          isVarargs: Bool = false
        ) {
          self.name = name
          self.typeAnnotation = typeAnnotation
          self.isVarargs = isVarargs
        }
      }

      case parameterList([Parameter])
      case identifierList(IdentifierList)
    }

    public let captureList: [CaptureItem]?
    public let parameterClause: ParameterClause?
    public let canThrow: Bool
    public let functionResult: FunctionResult?

    public init(captureList: [CaptureItem]) {
      self.captureList = captureList
      self.parameterClause = nil
      self.canThrow = false
      self.functionResult = nil
    }

    public init(
      captureList: [CaptureItem]? = nil,
      parameterClause: ParameterClause,
      canThrow: Bool = false,
      functionResult: FunctionResult? = nil
    ) {
      self.captureList = captureList
      self.parameterClause = parameterClause
      self.canThrow = canThrow
      self.functionResult = functionResult
    }
  }

  public let signature: Signature?
  public private(set) var statements: Statements?

  public init(signature: Signature? = nil, statements: Statements? = nil) {
    self.signature = signature
    self.statements = statements
  }

  // MARK: - Node Mutations

  public func replaceStatement(at index: Int, with statement: Statement) {
    guard index >= 0 && index < (statements?.count ?? 0) else { return }
    statements?[index] = statement
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    var signatureText = ""
    var stmtsText = ""

    if let signature = signature {
      signatureText = " \(signature.textDescription) in"
      if statements == nil {
        stmtsText = " "
      }
    }

    if let stmts = statements {
      if signature == nil && stmts.count == 1 {
        stmtsText = " \(stmts.textDescription) "
      } else {
        stmtsText = "\n\(stmts.textDescription)\n"
      }
    }

    return "{\(signatureText)\(stmtsText)}"
  }
}

extension ClosureExpression.Signature.CaptureItem.Specifier : ASTTextRepresentable {
  public var textDescription: String {
    return rawValue
  }
}

extension ClosureExpression.Signature.CaptureItem : ASTTextRepresentable {
  public var textDescription: String {
    let exprText = expression.textDescription
    guard let specifier = specifier else {
      return exprText
    }
    return "\(specifier.textDescription) \(exprText)"
  }
}

extension ClosureExpression.Signature.ParameterClause.Parameter : ASTTextRepresentable {
  public var textDescription: String {
    var paramText = name.textDescription
    if let typeAnnotation = typeAnnotation {
      paramText += typeAnnotation.textDescription
      if isVarargs {
        paramText += "..."
      }
    }
    return paramText
  }
}

extension ClosureExpression.Signature.ParameterClause : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .parameterList(let params):
      return "(\(params.map({ $0.textDescription }).joined(separator: ", ")))"
    case .identifierList(let idList):
      return idList.textDescription
    }
  }
}

extension ClosureExpression.Signature : ASTTextRepresentable {
  public var textDescription: String {
    var signatureText = [String]()
    if let captureList = captureList {
      signatureText.append("[\(captureList.map({ $0.textDescription }).joined(separator: ", "))]")
    }
    if let parameterClause = parameterClause {
      signatureText.append(parameterClause.textDescription)
    }
    if canThrow {
      signatureText.append("throws")
    }
    if let funcResult = functionResult {
      signatureText.append(funcResult.textDescription)
    }
    return signatureText.joined(separator: " ")
  }
}
