/*
   Copyright 2016 Ryuichi Saito, LLC

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

import ast
import source

extension Parser {
    /*
    - [x] enum-declaration → attributes/opt/ access-level-modifier/opt/ union-style-enum
    - [x] enum-declaration → attributes/opt/ access-level-modifier/opt/ raw-value-style-enum
    - [_] union-style-enum → `indirect`/opt/ `enum` enum-name generic-parameter-clause/opt/ type-inheritance-clause/opt/ `{` union-style-enum-members/opt/ `}`
    - [ ] union-style-enum-members → union-style-enum-member union-style-enum-members/opt/
    - [ ] union-style-enum-member → declaration | union-style-enum-case-clause
    - [ ] union-style-enum-case-clause → attributes/opt/ `indirect`/opt/ `case` union-style-enum-case-list
    - [ ] union-style-enum-case-list → union-style-enum-case | union-style-enum-case `,` union-style-enum-case-list
    - [ ] union-style-enum-case → enum-case-name tuple-type/opt/
    - [x] enum-name → identifier
    - [x] enum-case-name → identifier
    - [_] raw-value-style-enum → `enum` enum-name generic-parameter-clause/opt/ type-inheritance-clause `{` raw-value-style-enum-members `}`
    - [_] raw-value-style-enum-members → raw-value-style-enum-member raw-value-style-enum-members/opt/
    - [_] raw-value-style-enum-member → declaration | raw-value-style-enum-case-clause
    - [_] raw-value-style-enum-case-clause → attributes/opt/ `case` raw-value-style-enum-case-list
    - [x] raw-value-style-enum-case-list → raw-value-style-enum-case | raw-value-style-enum-case `,` raw-value-style-enum-case-list
    - [x] raw-value-style-enum-case → enum-case-name raw-value-assignment/opt/
    - [x] raw-value-assignment → `=` raw-value-literal
    - [_] raw-value-literal → numeric-literal | static-string-literal | boolean-literal
    - [_] error handling
    */
    func parseEnumDeclaration(
        attributes attributes: [Attribute],
        declarationModifiers: [String],
        accessLevelModifier: AccessLevel,
        startLocation: SourceLocation) throws {
        skipWhitespaces()

        var containsMissingSeparatorError = false

        guard let enumName = readIdentifier(includeContextualKeywords: true) else {
            throw ParserError.MissingIdentifier
        }
        skipWhitespaces()

        let typeInheritanceClause = try parseTypeInheritanceClause()
        let (containsClassRequirement, typeInheritance) = refineTypeInheritanceClause(typeInheritanceClause)

        if let token = currentToken, case let .Punctuator(type) = token where type == .LeftBrace {
            skipWhitespaces()

            var enumCases = [EnumCaseDelcaration]()

            parseEnumMembers: while let token = currentToken {
                switch token {
                case let .Keyword(keywordName, _):
                    if keywordName == "case" {
                        skipWhitespaces()
                        let enumCaseDecl = try parseEnumCaseDeclaration()
                        enumCases.append(enumCaseDecl)

                        try unshiftToken()
                        while let token = currentToken where token.isWhitespace() {
                            try unshiftToken()
                        }
                        do {
                            try ensureStatementSeparator(stopAtRightBrace: true)
                        }
                        catch _ {
                            containsMissingSeparatorError = true // just to delay throw this
                        } // TODO: ^ this block of code needs to be re-considered

                        if let token = currentToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .RightBrace {
                            break parseEnumMembers
                        }

                        skipWhitespaces(treatSemiAsWhitespace: true)
                        continue parseEnumMembers
                    }
                    else {
                        break parseEnumMembers
                    }
                default:
                    break parseEnumMembers
                }
            }

            if let token = currentToken, case let .Punctuator(type) = token where type == .RightBrace {
                // TODO: too nested
                var enumDeclAccessLevel = accessLevelModifier
                switch accessLevelModifier {
                case .PublicSet, .InternalSet, .PrivateSet:
                    enumDeclAccessLevel = .Default
                default: ()
                }
                let enumDecl = EnumDeclaration(
                    name: enumName,
                    cases: enumCases,
                    attributes: attributes,
                    modifiers: declarationModifiers,
                    accessLevel: enumDeclAccessLevel,
                    typeInheritance: typeInheritance)
                if let currentRange = currentRange ?? consumedTokens.last?.1 {
                    enumDecl.sourceRange = SourceRange(start: startLocation, end: currentRange.end)
                }
                topLevelCode.append(enumDecl)
                switch accessLevelModifier {
                case .PublicSet, .InternalSet, .PrivateSet:
                    throw ParserError.InvalidModifierToDeclaration(accessLevelModifier.errorDescription)
                default: ()
                }
                for modifier in declarationModifiers {
                    if modifier != "indirect" {
                        throw ParserError.InvalidModifierToDeclaration(modifier)
                    }
                }
                if containsClassRequirement {
                    throw ParserError.InvalidClassRequirement
                }
                if containsMissingSeparatorError {
                    throw ParserError.MissingSeparator
                }
            }
            else {
                // TODO: error handling
            }
        }
        else {
            // TODO: error handling
        }
    }

    private func parseEnumCaseDeclaration() throws -> EnumCaseDelcaration {
        var enumCaseElements = [EnumCaseElementDeclaration]()
        guard let enumCaseName = readIdentifier(includeContextualKeywords: true) else {
            throw ParserError.MissingIdentifier
        }
        skipWhitespaces()
        let enumCaseElementDecl = try parseRawValue(caseName: enumCaseName)
        enumCaseElements.append(enumCaseElementDecl)
        parseEnumCaseList: while let token = currentToken {
            switch token {
            case let .Punctuator(type) where type == .Comma:
                skipWhitespaces()
                guard let nextEnumCaseName = readIdentifier(includeContextualKeywords: true) else {
                    throw ParserError.MissingIdentifier
                }
                skipWhitespaces()
                let enumCaseElementDecl = try parseRawValue(caseName: nextEnumCaseName)
                enumCaseElements.append(enumCaseElementDecl)
                continue parseEnumCaseList
            default:
                break parseEnumCaseList
            }
        }
        return EnumCaseDelcaration(elements: enumCaseElements)
    }

    private func parseRawValue(caseName caseName: String) throws -> EnumCaseElementDeclaration {
        guard let token = currentToken, case let .Punctuator(type) = token where type == .Equal else {
            return EnumCaseElementDeclaration(name: caseName)
        }
        skipWhitespaces()
        guard let rawValueLiteralString = getLiteralString() else {
            throw ParserError.InternalError // TODO: better error handling
        }
        skipWhitespaces()
        return EnumCaseElementDeclaration(name: caseName, rawValue: rawValueLiteralString) // TODO: need to distinguish different types of literals
    }

    private func getLiteralString() -> String? {
        guard let token = currentToken else {
            return nil
        }
        switch token {
        case let .BinaryIntegerLiteral(literal):
            return literal
        case let .OctalIntegerLiteral(literal):
            return literal
        case let .DecimalIntegerLiteral(literal):
            return literal
        case let .HexadecimalIntegerLiteral(literal):
            return literal
        case let .DecimalFloatingPointLiteral(literal):
            return literal
        case let .HexadecimalFloatingPointLiteral(literal):
            return literal
        case let .StaticStringLiteral(literal):
            return literal
        case .TrueBooleanLiteral:
            return "true"
        case .FalseBooleanLiteral:
            return "false"
        default:
            return nil
        }
    }

    private func refineTypeInheritanceClause(types: [String]) -> (Bool, [String]) {
        var refinedTypes = [String]()
        var containsClassRequirement = false
        for type in types {
            if type == "class" {
                containsClassRequirement = true
            }
            else {
                refinedTypes.append(type)
            }
        }
        return (containsClassRequirement, refinedTypes)
    }
}
