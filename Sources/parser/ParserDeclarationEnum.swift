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
    - [ ] union-style-enum → `indirect`/opt/ `enum` enum-name generic-parameter-clause/opt/ type-inheritance-clause/opt/ `{` union-style-enum-members/opt/ `}`
    - [ ] union-style-enum-members → union-style-enum-member union-style-enum-members/opt/
    - [ ] union-style-enum-member → declaration | union-style-enum-case-clause
    - [ ] union-style-enum-case-clause → attributes/opt/ `indirect`/opt/ `case` union-style-enum-case-list
    - [ ] union-style-enum-case-list → union-style-enum-case | union-style-enum-case `,` union-style-enum-case-list
    - [ ] union-style-enum-case → enum-case-name tuple-type/opt/
    - [x] enum-name → identifier
    - [ ] enum-case-name → identifier
    - [ ] raw-value-style-enum → `enum` enum-name generic-parameter-clause/opt/ type-inheritance-clause `{` raw-value-style-enum-members `}`
    - [ ] raw-value-style-enum-members → raw-value-style-enum-member raw-value-style-enum-members/opt/
    - [ ] raw-value-style-enum-member → declaration | raw-value-style-enum-case-clause
    - [ ] raw-value-style-enum-case-clause → attributes/opt/ `case` raw-value-style-enum-case-list
    - [ ] raw-value-style-enum-case-list → raw-value-style-enum-case | raw-value-style-enum-case `,` raw-value-style-enum-case-list
    - [ ] raw-value-style-enum-case → enum-case-name raw-value-assignment/opt/
    - [ ] raw-value-assignment → `=` raw-value-literal
    - [ ] raw-value-literal → numeric-literal | static-string-literal | boolean-literal
    - [_] error handling
    */
    func parseEnumDeclaration(
        attributes attributes: [Attribute],
        accessLevelModifier: AccessLevel,
        startLocation: SourceLocation) throws {
        skipWhitespaces()

        if let enumName = readIdentifier(includeContextualKeywords: true) {
            skipWhitespaces()

            if let token = currentToken, case let .Punctuator(type) = token where type == .LeftBrace {
                skipWhitespaces()

                if let token = currentToken, case let .Punctuator(type) = token where type == .RightBrace {
                    // TODO: too nested
                    var enumDeclAccessLevel = accessLevelModifier
                    switch accessLevelModifier {
                    case .PublicSet, .InternalSet, .PrivateSet:
                        enumDeclAccessLevel = .Default
                    default: ()
                    }
                    let enumDecl = EnumDeclaration(
                        name: enumName, attributes: attributes, accessLevel: enumDeclAccessLevel)
                    if let currentRange = currentRange ?? consumedTokens.last?.1 {
                        enumDecl.sourceRange = SourceRange(start: startLocation, end: currentRange.end)
                    }
                    topLevelCode.append(enumDecl)
                    switch accessLevelModifier {
                    case .PublicSet, .InternalSet, .PrivateSet:
                        throw ParserError.InvalidAccessLevelModifierToDeclaration(accessLevelModifier)
                    default: ()
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
        else {
            throw ParserError.MissingIdentifier
        }
    }
}
