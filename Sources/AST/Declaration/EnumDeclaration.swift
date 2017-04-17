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

public class EnumDeclaration : ASTNode, Declaration {
  public struct UnionStyleEnumCase {
    public struct Case {
      public let name: Identifier
      public let tuple: TupleType?

      public init(name: Identifier, tuple: TupleType? = nil) {
        self.name = name
        self.tuple = tuple
      }
    }

    public let attributes: Attributes
    public let isIndirect: Bool
    public let cases: [Case]

    public init(
      attributes: Attributes = [], isIndirect: Bool = false, cases: [Case]
    ) {
      self.attributes = attributes
      self.isIndirect = isIndirect
      self.cases = cases
    }
  }

  public struct RawValueStyleEnumCase {
    public struct Case {
      public enum RawValueLiteral {
        case integer(Int)
        case floatingPoint(Double)
        case string(String)
        case boolean(Bool)
      }

      public let name: Identifier
      public let assignment: RawValueLiteral?

      public init(name: Identifier, assignment: RawValueLiteral? = nil) {
        self.name = name
        self.assignment = assignment
      }
    }

    public let attributes: Attributes
    public let cases: [Case]

    public init(attributes: Attributes = [], cases: [Case]) {
      self.attributes = attributes
      self.cases = cases
    }
  }

  public enum Member {
    case declaration(Declaration)
    case union(UnionStyleEnumCase)
    case rawValue(RawValueStyleEnumCase)
    case compilerControl(CompilerControlStatement)
  }

  public let attributes: Attributes
  public let accessLevelModifier: AccessLevelModifier?
  public let isIndirect: Bool
  public let name: Identifier
  public let genericParameterClause: GenericParameterClause?
  public let typeInheritanceClause: TypeInheritanceClause?
  public let genericWhereClause: GenericWhereClause?
  public let members: [Member]

  public init(
    attributes: Attributes = [],
    accessLevelModifier: AccessLevelModifier? = nil,
    isIndirect: Bool = false,
    name: Identifier,
    genericParameterClause: GenericParameterClause? = nil,
    typeInheritanceClause: TypeInheritanceClause? = nil,
    genericWhereClause: GenericWhereClause? = nil,
    members: [Member] = []
  ) {
    self.attributes = attributes
    self.accessLevelModifier = accessLevelModifier
    self.isIndirect = isIndirect
    self.name = name
    self.genericParameterClause = genericParameterClause
    self.typeInheritanceClause = typeInheritanceClause
    self.genericWhereClause = genericWhereClause
    self.members = members
  }

  // MARK: - ASTTextRepresentable

  override public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let modifierText = accessLevelModifier.map({ "\($0.textDescription) " }) ?? ""
    let indirectText = isIndirect ? "indirect " : ""
    let headText = "\(attrsText)\(modifierText)\(indirectText)enum \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.textDescription }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return "\(headText)\(neckText) {\(memberText)}"
  }
}

extension EnumDeclaration.UnionStyleEnumCase : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let indirectText = isIndirect ? "indirect " : ""
    let casesText = cases.map({ "\($0.name)\($0.tuple?.textDescription ?? "")" }).joined(separator: ", ")
    return "\(attrsText)\(indirectText)case \(casesText)"
  }
}

extension EnumDeclaration.RawValueStyleEnumCase : ASTTextRepresentable {
  public var textDescription: String {
    let attrsText = attributes.isEmpty ? "" : "\(attributes.textDescription) "
    let casesText = cases.map { c -> String in
      let assignmentText: String
      if let assignment = c.assignment {
        switch assignment {
        case .integer(let i):
          assignmentText = " = \(i)"
        case .floatingPoint(let d):
          assignmentText = " = \(d)"
        case .string(let s):
          assignmentText = " = \"\(s)\""
        case .boolean(let b):
          assignmentText = b ? " = true" : " = false"
        }
      } else {
        assignmentText = ""
      }
      return "\(c.name)\(assignmentText)"
    }
    return "\(attrsText)case \(casesText.joined(separator: ", "))"
  }
}

extension EnumDeclaration.Member : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .declaration(let decl):
      return decl.textDescription
    case .union(let enumCase):
      return enumCase.textDescription
    case .rawValue(let enumCase):
      return enumCase.textDescription
    case .compilerControl(let stmt):
      return stmt.textDescription
    }
  }
}
