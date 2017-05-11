/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
  return [
    ///////// Attribute
    testCase(ParserAttributeTests.allTests),
    ///////// Type
    testCase(ParserArrayTypeTests.allTests),
    testCase(ParserDictinoaryTypeTests.allTests),
    testCase(ParserImplicitlyUnwrappedOptionalTypeTests.allTests),
    testCase(ParserOptionalTypeTests.allTests),
    testCase(ParserFunctionTypeTests.allTests),
    testCase(ParserMetatypeTypeTests.allTests),
    testCase(ParserProtocolCompositionTypeTests.allTests),
    testCase(ParserTupleTypeTests.allTests),
    testCase(ParserTypeIdentifierTests.allTests),
    testCase(ParserAnyTypeTests.allTests),
    testCase(ParserSelfTypeTests.allTests),
    testCase(ParserTypeInheritanceClauseTests.allTests),
    ///////// Generic
    testCase(ParserGenericArgumentClauseTests.allTests),
    testCase(ParserGenericParameterClauseTests.allTests),
    testCase(ParserGenericWhereClauseTests.allTests),
    ///////// Expression
    testCase(ParserIdentifierExpressionTests.allTests),
    testCase(ParserLiteralExpressionTests.allTests),
    testCase(ParserSelfExpressionTests.allTests),
    testCase(ParserSuperclassExpressionTests.allTests),
    testCase(ParserClosureExpressionTests.allTests),
    testCase(ParserImplicitMemberExpressionTests.allTests),
    testCase(ParserParenthesizedExpressionTests.allTests),
    testCase(ParserTupleExpressionTests.allTests),
    testCase(ParserWildcardExpressionTests.allTests),
    testCase(ParserSelectorExpressionTests.allTests),
    testCase(ParserKeyPathExpressionTests.allTests),
    testCase(ParserPostfixOperatorExpressionTests.allTests),
    testCase(ParserFunctionCallExpressionTests.allTests),
    testCase(ParserInitializerExpressionTests.allTests),
    testCase(ParserExplicitMemberExpressionTests.allTests),
    testCase(ParserPostfixSelfExpressionTests.allTests),
    testCase(ParserSubscriptExpressionTests.allTests),
    testCase(ParserForcedValueExpressionTests.allTests),
    testCase(ParserOptionalChainingExpressionTests.allTests),
    testCase(ParserPrefixOperatorExpressionTests.allTests),
    testCase(ParserInOutExpressionTests.allTests),
    testCase(ParserBinaryOperatorExpressionTests.allTests),
    testCase(ParserAssignmentOperatorExpressionTests.allTests),
    testCase(ParserTernaryConditionalOperatorExpressionTests.allTests),
    testCase(ParserTypeCastingOperatorExpressionTests.allTests),
    testCase(ParserTryOperatorExpressionTests.allTests),
    ///////// Pattern
    testCase(ParserWildcardPatternTests.allTests),
    testCase(ParserIdentifierPatternTests.allTests),
    testCase(ParserValueBindingPatternTests.allTests),
    testCase(ParserTuplePatternTests.allTests),
    testCase(ParserEnumCasePatternTests.allTests),
    testCase(ParserOptionalPatternTests.allTests),
    testCase(ParserTypeCastingPatternTests.allTests),
    testCase(ParserExpressionPatternTests.allTests),
    ///////// Statement
    testCase(ParserConditionTests.allTests),
    testCase(ParserForInStatementTests.allTests),
    testCase(ParserWhileStatementTests.allTests),
    testCase(ParserRepeatWhileStatementTests.allTests),
    testCase(ParserIfStatementTests.allTests),
    testCase(ParserGuardStatementTests.allTests),
    testCase(ParserSwitchStatementTests.allTests),
    testCase(ParserBreakStatementTests.allTests),
    testCase(ParserContinueStatementTests.allTests),
    testCase(ParserFallthroughStatementTests.allTests),
    testCase(ParserReturnStatementTests.allTests),
    testCase(ParserThrowStatementTests.allTests),
    testCase(ParserDeferStatementTests.allTests),
    testCase(ParserDoStatementTests.allTests),
    testCase(ParserLabeledStatementTests.allTests),
    testCase(ParserExpressionStatementTests.allTests),
    testCase(ParserDeclarationStatementTests.allTests),
    testCase(ParserCompilerControlStatementTests.allTests),
    ///////// Modifier
    testCase(ParserAccessLevelModifierTests.allTests),
    testCase(ParserMutationModifierTests.allTests),
    testCase(ParserDeclarationModifierTests.allTests),
    testCase(ParserDeclarationModifiersTests.allTests),
    ///////// Declaration
    testCase(ParserTopLevelDeclarationTests.allTests),
    testCase(ParserCodeBlockTests.allTests),
    testCase(ParserImportDeclarationTests.allTests),
    testCase(ParserConstantDeclarationTests.allTests),
    testCase(ParserVariableDeclarationTests.allTests),
    testCase(ParserTypealiasDeclarationTests.allTests),
    testCase(ParserFunctionDeclarationTests.allTests),
    testCase(ParserEnumDeclarationTests.allTests),
    testCase(ParserStructDeclarationTests.allTests),
    testCase(ParserClassDeclarationTests.allTests),
    testCase(ParserInitializerDeclarationTests.allTests),
    testCase(ParserDeinitializerDeclarationTests.allTests),
    testCase(ParserExtensionDeclarationTests.allTests),
    testCase(ParserSubscriptDeclarationTests.allTests),
    testCase(ParserOperatorDeclarationTests.allTests),
    testCase(ParserPrecedenceGroupDeclarationTests.allTests),
    testCase(ParserProtocolDeclarationTests.allTests),
    ///////// Others
    testCase(KeywordUsedAsIdentifierTests.allTests),
    testCase(GenericOpeningChevronTests.allTests),
    testCase(ParserErrorKindTests.allTests),
  ]
}
#endif
