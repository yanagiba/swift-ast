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

import Diagnostic

extension Parser {
  func _raiseFatal(_ kind: ParserErrorKind) -> Error {
    return _diagnosticPool.appendFatal(
      kind: kind, sourceLocatable: _lexer.look())
  }

  func _raiseError(_ kind: ParserErrorKind) throws {
    try _diagnosticPool.appendError(kind: kind, sourceLocatable: _lexer.look())
  }

  func _raiseWarning(_ kind: ParserErrorKind) throws {
    try _diagnosticPool.appendWarning(
      kind: kind, sourceLocatable: _lexer.look())
  }

  var _diagnosticPool: DiagnosticPool {
    return .shared
  }
}

public enum ParserErrorKind : DiagnosticKind {
  case dummy

  case leftBraceExpected(String)
  case rightBraceExpected(String)

  // attributes
  case missingAttributeName

  // declarations
  case badDeclaration
  /// protocol declaration
  case missingPropertyMemberName
  case missingTypeForPropertyMember
  case missingGetterSetterForPropertyMember
  case protocolPropertyMemberWithBody
  case protocolMethodMemberWithBody
  case missingProtocolSubscriptGetSetSpecifier
  case missingProtocolAssociatedTypeName
  case badProtocolMember
  case missingProtocolName
  /// precedence-group declaration
  case missingColonAfterAttributeNameInPrecedenceGroup
  case missingPrecedenceGroupRelation(String)
  case expectedBooleanAfterPrecedenceGroupAssignment
  case unknownPrecedenceGroupAttribute(String)
  case expectedPrecedenceGroupAssociativity
  case expectedPrecedenceGroupAttribute
  /// operator declaration
  case expectedValidOperator
  case operatorDeclarationHasNoFixity
  case expectedOperatorNameAfterInfixOperator
  /// subscript declaration
  case expectedArrowSubscript
  /// extension declaration
  case missingExtensionName
  /// class declaration
  case missingClassName
  /// struct declaration
  case missingStructName
  /// enum declaration
  case indirectWithRawValueStyle
  case missingTypeForRawValueEnumDeclaration
  case unionStyleMixWithRawValueStyle
  case expectedEnumDeclarationCaseMember
  case nonliteralEnumCaseRawValue
  case expectedCaseName
  case missingEnumName
  case enumExpectedAfterIndirect
  /// function declaration
  case unnamedParameter
  case expectedParameterType
  case expectedParameterOpenParenthesis
  case expectedParameterCloseParenthesis
  case duplicatedFunctionModifiers
  case missingFunctionName

  case missingTypealiasName

  public var diagnosticMessage: String {
    switch self {
    case .dummy:
      return "dummy diagnostic"
    case .missingAttributeName:
      return "expected an attribute name"
    case .leftBraceExpected(let node):
      return "expected '{' for \(node)"
    case .rightBraceExpected(let node):
      return "expected '}' for \(node)"
    case .badDeclaration:
      return "expected declaration"
    case .missingPropertyMemberName:
      return "expected a property name"
    case .missingTypeForPropertyMember:
      return "property must have an explicit type"
    case .missingGetterSetterForPropertyMember:
      return "expected get or set in a protocol property"
    case .protocolPropertyMemberWithBody:
      return "protocol properties may not have bodies"
    case .protocolMethodMemberWithBody:
      return "protocol methods may not have bodies"
    case .missingProtocolSubscriptGetSetSpecifier:
      return "subscript in protocol must have explicit { get } or { get set } specifier"
    case .missingProtocolAssociatedTypeName:
      return "expected an associated type name"
    case .badProtocolMember:
      return "expected protocol member"
    case .missingProtocolName:
      return "expected a protocol name"
    case .missingColonAfterAttributeNameInPrecedenceGroup:
      return "expected colon after attribute name in precedence group"
    case .missingPrecedenceGroupRelation(let attribute):
      return "expected name of related precedence group after '\(attribute)'"
    case .expectedBooleanAfterPrecedenceGroupAssignment:
      return "expected 'true' or 'false' after 'assignment'"
    case .unknownPrecedenceGroupAttribute(let name):
      return "'\(name)' is not a valid precedence group attribute"
    case .expectedPrecedenceGroupAssociativity:
      return "expected 'none', 'left', or 'right' after 'associativity'"
    case .expectedPrecedenceGroupAttribute:
      return "expected attribute identifier in precedence group body"
    case .expectedValidOperator:
      return "expected operator in an operator declaration"
    case .operatorDeclarationHasNoFixity:
      return "operator must be declared as 'prefix', 'postfix', or 'infix'"
    case .expectedOperatorNameAfterInfixOperator:
      return "expected operator name in infix operator declaration"
    case .expectedArrowSubscript:
      return "expected '->' for subscript declaration"
    case .missingExtensionName:
      return "expected type name in extension declaration"
    case .missingClassName:
      return "expected a class name"
    case .missingStructName:
      return "expected a struct name"
    case .enumExpectedAfterIndirect:
      return "epected 'enum' after 'indirect' for indirect enumeration declaration"
    case .indirectWithRawValueStyle:
      return "'indirect' is invalid in raw-value style enum declaration"
    case .missingTypeForRawValueEnumDeclaration:
      return "expected type for raw-value style enum declaration"
    case .unionStyleMixWithRawValueStyle:
      return "expected a raw-value style enum case"
    case .expectedEnumDeclarationCaseMember:
      return "expected a 'case' member"
    case .nonliteralEnumCaseRawValue:
      return "raw value for enum case must be a literal"
    case .expectedCaseName:
      return "expect a case name for enum declaration"
    case .missingEnumName:
      return "expected an enum name"
    case .unnamedParameter:
      return "expected parameter name followed by ':'"
    case .expectedParameterType:
      return "expected parameter type following ':'"
    case .expectedParameterOpenParenthesis:
      return "expected '(' in parameter"
    case .expectedParameterCloseParenthesis:
      return "expected ')' in parameter"
    case .duplicatedFunctionModifiers:
      return "previous 'prefix', 'postfix', or 'infix' modifier has been overrided"
    case .missingFunctionName:
      return "expected a function name"
    case .missingTypealiasName:
      return "Missing typealias declaration name"
    }
  }
}
