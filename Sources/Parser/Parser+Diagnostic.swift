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
    try _diagnosticPool.appendWarning(kind: kind, sourceLocatable: _lexer.look())
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
  case missingPrecedenceName
  /// operator declaration
  case expectedValidOperator
  case operatorDeclarationHasNoFixity
  case expectedOperatorNameAfterInfixOperator
  case operatorHasBody
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
  /// typealias declaration
  case missingTypealiasName
  case expectedEqualInTypealias
  /// variable/constant declaration
  case expectedAccesorName(String)
  case expectedAccesorNameCloseParenthesis(String)
  case expectedWillSetOrDidSet
  case varSetWithoutGet
  /// import declaration
  case missingModuleNameImportDecl

  // expressions
  case expectedColonAfterTrueExpr
  case expectedIdentifierForInOutExpr
  case expectedCloseSquareExprList
  case expectedParameterNameFuncCall
  case expectedCloseParenFuncCall
  case expectedArgumentLabel
  case expectedColonAfterArgumentLabel
  case expectedTupleIndexExplicitMemberExpr
  case expectedMemberNameExplicitMemberExpr
  case expectedExpr
  case expectedTupleArgumentLabel
  case expectedCloseParenTuple
  case expectedIdentifierAfterSuperDotExpr
  case expectedDotOrSubscriptAfterSuper
  case expectedIdentifierAfterSelfDotExpr
  case expectedObjectLiteralIdentifier
  case expectedKeyPathComponent
  case expectedKeyPathComponentIdentifierOrPostfix
  case expectedOpenParenKeyPathStringExpr
  case expectedCloseParenKeyPathStringExpr
  case expectedOpenParenSelectorExpr
  case expectedColonAfterPropertyKeywordSelectorExpr(String)
  case expectedCloseParenSelectorExpr
  case expectedCloseSquareDictionaryLiteral
  case expectedColonDictionaryLiteral
  case expectedCloseSquareArrayLiteral
  case expectedOpenParenPlaygroundLiteral(String)
  case expectedCloseParenPlaygroundLiteral(String)
  case expectedKeywordPlaygroundLiteral(String, String)
  case expectedExpressionPlaygroundLiteral(String, String)
  case expectedColonAfterKeywordPlaygroundLiteral(String, String)
  case expectedCommaBeforeKeywordPlaygroundLiteral(String, String)
  case extraTokenStringInterpolation
  case expectedStringInterpolation
  case newLineExpectedAtTheClosingOfMultilineStringLiteral
  case insufficientIndentationOfLineInMultilineStringLiteral
  case expectedUnownedSafeOrUnsafe
  case expectedClosureParameterName
  case expectedIdentifierAfterDot

  // generics
  case expectedRightChevron(String)
  case expectedGenericsParameterName
  case expectedGenericTypeRestriction(String)
  case expectedGenericRequirementName
  case requiresDoubleEqualForSameTypeRequirement
  case expectedRequirementDelimiter

  // patterns
  case expectedPattern
  case expectedCaseNamePattern
  case expectedTuplePatternCloseParenthesis
  case expectedIdentifierTuplePattern

  // statements
  case statementSameLineWithoutSemicolon
  case expectedOpenParenSourceLocation
  case expectedValidCompilerCtrlKeyword
  case invalidLabelOnStatement
  case expectedCaseColon
  case expectedDefaultColon
  case caseStmtWithoutBody(String)
  case expectedWhileAfterRepeatBody
  case expectedEqualInConditionalBinding
  case expectedAvailableKeyword
  case expectedOpenParenAvailabilityCondition
  case expectedAvailabilityVersionNumber
  case expectedMinorVersionAvailability
  case attributeAvailabilityPlatform
  case expectedCloseParenAvailabilityCondition
  case expectedForEachIn
  case expectedElseAfterGuard

  // types
  case expectedType
  case expectedCloseSquareArrayType
  case expectedCloseSquareDictionaryType
  case expectedCloseParenParenthesizedType
  case tupleTypeMultipleLabels
  case tupleTypeVariadicElement
  case expectedTypeInTuple
  case expectedIdentifierTypeForProtocolComposition
  case expectedLeftChevronProtocolComposition
  case expectedRightChevronProtocolComposition
  case expectedFunctionTypeArguments
  case throwsInWrongPosition(String)
  case wrongIdentifierForMetatypeType
  case lateClassRequirement
  case expectedTypeRestriction

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
    case .missingPrecedenceName:
      return "expected a precedence group name"
    case .expectedValidOperator:
      return "expected operator in an operator declaration"
    case .operatorDeclarationHasNoFixity:
      return "operator must be declared as 'prefix', 'postfix', or 'infix'"
    case .expectedOperatorNameAfterInfixOperator:
      return "expected operator name in infix operator declaration"
    case .operatorHasBody:
      return "operator should no longer be declared with body"
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
      return "expected a typealias name"
    case .expectedEqualInTypealias:
      return "expected '=' in type alias declaration"
    case .expectedAccesorName(let accessorType):
      return "expected \(accessorType) parameter name"
    case .expectedAccesorNameCloseParenthesis(let accessorType):
      return "expected ')' after \(accessorType) parameter name"
    case .expectedWillSetOrDidSet:
      return "expected 'willSet' or 'didSet' to start a willSet/didSet block"
    case .varSetWithoutGet:
      return "variable with a setter must also have a getter"
    case .missingModuleNameImportDecl:
      return "expected module name or operator in import declaration"
    case .expectedColonAfterTrueExpr:
      return "expected ':' after '? ...' in ternary expression"
    case .expectedIdentifierForInOutExpr:
      return "expected an identifier after '&'"
    case .expectedCloseSquareExprList:
      return "expected ']' in expression list"
    case .expectedParameterNameFuncCall:
      return "expected parameter name in function call"
    case .expectedCloseParenFuncCall:
      return "expected ')' to complete function-call expression"
    case .expectedArgumentLabel:
      return "expected argument label"
    case .expectedColonAfterArgumentLabel:
      return "expected ':' after argument label"
    case .expectedTupleIndexExplicitMemberExpr:
      return "expected a valid tuple index"
    case .expectedMemberNameExplicitMemberExpr:
      return "expected member name following '.'"
    case .expectedExpr:
      return "expected expression"
    case .expectedTupleArgumentLabel:
      return "expected an argument label for tuple expression"
    case .expectedCloseParenTuple:
      return "expected ')' to complete a tuple expression"
    case .expectedIdentifierAfterSuperDotExpr:
      return "expected identifier or 'init' after super '.' expression"
    case .expectedDotOrSubscriptAfterSuper:
      return "expected '.' or '[' after 'super'"
    case .expectedIdentifierAfterSelfDotExpr:
      return "expected identifier or 'init' after self '.' expression"
    case .expectedObjectLiteralIdentifier:
      return "expected a valid identifier after '#' in object literal expression"
    case .expectedKeyPathComponent:
      return "expected keypath component"
    case .expectedKeyPathComponentIdentifierOrPostfix:
      return "expected keypath component identifier or postfix following '.'"
    case .expectedOpenParenKeyPathStringExpr:
      return "expected '(' following '#keyPath'"
    case .expectedCloseParenKeyPathStringExpr:
      return "expected ')' to complete '#keyPath' expression"
    case .expectedOpenParenSelectorExpr:
      return "expected '(' following '#selector'"
    case .expectedColonAfterPropertyKeywordSelectorExpr(let accessorType):
      return "expected ':' following '\(accessorType)'"
    case .expectedCloseParenSelectorExpr:
      return "expected ')' to complete '#selector' expression"
    case .expectedCloseSquareDictionaryLiteral:
      return "expected ']' in dictionary literal expression"
    case .expectedColonDictionaryLiteral:
      return "expected ':' in dictionary literal"
    case .expectedCloseSquareArrayLiteral:
      return "expected ']' in array literal expression"
    case .expectedOpenParenPlaygroundLiteral(let magicWord):
      return "expected '(' following '#\(magicWord)'"
    case .expectedCloseParenPlaygroundLiteral(let magicWord):
      return "expected ')' to complete '#\(magicWord)' playground literal"
    case let .expectedKeywordPlaygroundLiteral(magicWord, keyword):
      return "expected keyword '\(keyword)' for '#\(magicWord)' playground literal"
    case let .expectedExpressionPlaygroundLiteral(magicWord, keyword):
      return "expected an expression of '\(keyword)' for '#\(magicWord)' playground literal"
    case let .expectedColonAfterKeywordPlaygroundLiteral(magicWord, keyword):
      return "expected ':' following '\(keyword)' for '#\(magicWord)' playground literal"
    case let .expectedCommaBeforeKeywordPlaygroundLiteral(magicWord, keyword):
      return "expected ',' before '\(keyword)' for '#\(magicWord)' playground literal"
    case .extraTokenStringInterpolation:
      return "extra tokens after interpolated string expression"
    case .expectedStringInterpolation:
      return "expected an interpolated string expression"
    case .newLineExpectedAtTheClosingOfMultilineStringLiteral:
      return "multi-line string literal closing delimiter must begin on a new line"
    case .insufficientIndentationOfLineInMultilineStringLiteral:
      return "insufficient indentation of line in multi-line string literal"
    case .expectedUnownedSafeOrUnsafe:
      return "expected 'safe' or 'unsafe' for 'unowned' specifier"
    case .expectedClosureParameterName:
      return "expected the name of a closure parameter"
    case .expectedIdentifierAfterDot:
      return "expected identifier after '.'"
    case .expectedRightChevron(let node):
      return "expected '>' to complete \(node)"
    case .expectedGenericsParameterName:
      return "expected an identifier to name generic parameter"
    case .expectedGenericTypeRestriction(let restricting):
      return "expected a class type or protocol-constrained type restricting '\(restricting)'"
    case .expectedGenericRequirementName:
      return "expected an identifier or 'Self' for generic requirement"
    case .requiresDoubleEqualForSameTypeRequirement:
      return "use '==' for same-type requirements rather than '='"
    case .expectedRequirementDelimiter:
      return "expected ':' or '==' to indicate a conformance or same-type requirement"
    case .expectedPattern:
      return "expected pattern"
    case .expectedCaseNamePattern:
      return "expected a case name following '.'"
    case .expectedTuplePatternCloseParenthesis:
      return "expected ')' at end of tuple pattern"
    case .expectedIdentifierTuplePattern:
      return "expected an identifier or '_' for tuple pattern"
    case .statementSameLineWithoutSemicolon:
      return "consecutive statements on a line must be separated by ';'"
    case .expectedOpenParenSourceLocation:
      return "expected '(' following '#sourceLocation'"
    case .expectedValidCompilerCtrlKeyword:
      return "expected a valid keyword after '#' in compiler-control statement"
    case .invalidLabelOnStatement:
      return "labels are only valid on loops, if, and switch statements"
    case .expectedCaseColon:
      return "expected ':' after case items"
    case .expectedDefaultColon:
      return "expected ':' after 'default'"
    case .caseStmtWithoutBody(let kind):
      return "'\(kind)' label in a 'switch' should have at least one executable statement"
    case .expectedWhileAfterRepeatBody:
      return "expected 'while' after body of 'repeat' statement"
    case .expectedEqualInConditionalBinding:
      return "expected '=' in conditional binding"
    case .expectedAvailableKeyword:
      return "expected '#available' in availability checking"
    case .expectedOpenParenAvailabilityCondition:
      return "expected '(' following '#available'"
    case .expectedAvailabilityVersionNumber:
      return "expected a version number for availability checking"
    case .expectedMinorVersionAvailability:
      return "expected a minor version number for availability checking"
    case .attributeAvailabilityPlatform:
      return "expected platform name or '*' for availability checking"
    case .expectedCloseParenAvailabilityCondition:
      return "expected ')' in availability checking"
    case .expectedForEachIn:
      return "expected 'in' after for-each pattern"
    case .expectedElseAfterGuard:
      return "expected 'else' after 'guard' condition"
    case .expectedType:
      return "expected type"
    case .expectedCloseSquareArrayType:
      return "expected ']' in array type"
    case .expectedCloseSquareDictionaryType:
      return "expected ']' in dictionary type"
    case .expectedCloseParenParenthesizedType:
      return "expected ')' at end of tuple list"
    case .tupleTypeMultipleLabels:
      return "tuple element cannot have two labels"
    case .tupleTypeVariadicElement:
      return "tuple element cannot be variadic"
    case .expectedTypeInTuple:
      return "expected a type for tuple element"
    case .expectedIdentifierTypeForProtocolComposition:
      return "expected an identifier type for protocol-constrained type"
    case .expectedLeftChevronProtocolComposition:
      return "expected '<' following 'protocol'"
    case .expectedRightChevronProtocolComposition:
      return "expected '>' to complete protocol-constrained type"
    case .expectedFunctionTypeArguments:
      return "expected arguments for function type"
    case .throwsInWrongPosition(let throwingKind):
      return "'\(throwingKind)' may only occur before '->'"
    case .wrongIdentifierForMetatypeType:
      return "expected 'Type' or 'Protocol' following '.' for metatype type"
    case .lateClassRequirement:
      return "'class' must come first in the requirement list"
    case .expectedTypeRestriction:
      return "expected a type in the requirement list"
    }
  }
}
