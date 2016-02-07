/*
   Copyright 2015 Ryuichi Saito, LLC

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

specCanary()
specLexer()
specParser()

// tests for types
specTypeIdentifier()
specArrayType()
specDictionaryType()
specFunctionType()
specOptionalType()
specImplicitlyUnwrappedOptionalType()
specProtocolCompositionType()
specMetatypeType()
specTupleType()
specType()

// tests for generics
specGenericParameterClause()
specGenericArgumentClause()

// tests for expressions
specIdentifierExpression()
specLiteralExpression()
specSelfExpression()
specSuperclassExpression()
specClosureExpression()
specImplicitMemberExpression()
specParenthesizedExpression()
specWildcardExpression()
specPostfixOperatorExpression()
specExpression()

// tests for parsing declarations
specParsingImportDeclaration()
specParsingEnumDeclaration()
specParsingTypeAliasDeclaration()
