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
    - [x] ypealias-declaration → typealias-head typealias-assignment
    - [x] typealias-head → attributes/opt/ access-level-modifier/opt/ typealias typealias-name
    - [x] typealias-name → identifier
    - [x] typealias-assignment → `=` type
    - [_] error handling
    */
    func parseTypeAliasDeclaration(
        attributes attributes: [Attribute],
        accessLevelModifier: AccessLevel,
        startLocation: SourceLocation) throws {
        skipWhitespaces()

        guard let typeNewName = readIdentifier(includeContextualKeywords: true) else {
            throw ParserError.MissingIdentifier
        }
        skipWhitespaces()

        if let token = currentToken, case let .Punctuator(type) = token where type == .Equal {
            skipWhitespaces()

            let existingType = try parseType()
            let typealiasDecl = TypeAliasDeclaration(
                name: typeNewName, type: existingType, attributes: attributes, accessLevel: accessLevelModifier)

            try rewindAllWhitespaces()
            if let currentRange = currentRange {
                typealiasDecl.sourceRange = SourceRange(start: startLocation, end: currentRange.end)
            }
            topLevelCode.append(typealiasDecl)
        }
        else {
            throw ParserError.InternalError // TODO: error handling
        }
    }
}
