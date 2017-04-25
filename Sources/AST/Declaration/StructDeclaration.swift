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

public class StructDeclaration : ASTNode, Declaration {
  public enum Member {
    case declaration(Declaration)
    case compilerControl(CompilerControlStatement)
  }

  public let attributes: Attributes
  public let accessLevelModifier: AccessLevelModifier?
  public let name: Identifier
  public let genericParameterClause: GenericParameterClause?
  public let typeInheritanceClause: TypeInheritanceClause?
  public let genericWhereClause: GenericWhereClause?
  public let members: [Member]

  public init(
    attributes: Attributes = [],
    accessLevelModifier: AccessLevelModifier? = nil,
    name: Identifier,
    genericParameterClause: GenericParameterClause? = nil,
    typeInheritanceClause: TypeInheritanceClause? = nil,
    genericWhereClause: GenericWhereClause? = nil,
    members: [Member] = []
  ) {
    self.attributes = attributes
    self.accessLevelModifier = accessLevelModifier
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
    let headText = "\(attrsText)\(modifierText)struct \(name)"
    let genericParameterClauseText = genericParameterClause?.textDescription ?? ""
    let typeText = typeInheritanceClause?.textDescription ?? ""
    let whereText = genericWhereClause.map({ " \($0.textDescription)" }) ?? ""
    let neckText = "\(genericParameterClauseText)\(typeText)\(whereText)"
    let membersText = members.map({ $0.textDescription }).joined(separator: "\n")
    let memberText = members.isEmpty ? "" : "\n\(membersText)\n"
    return "\(headText)\(neckText) {\(memberText)}"
  }
}

extension StructDeclaration.Member : ASTTextRepresentable {
  public var textDescription: String {
    switch self {
    case .declaration(let decl):
      return decl.textDescription
    case .compilerControl(let stmt):
      return stmt.textDescription
    }
  }
}
