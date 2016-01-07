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

import source
import ast

extension Parser {
    /*
    - [_] type-identifier → type-name generic-argument-clause/opt/ | type-name generic-argument-clause/opt/ `.` type-identifier
    - [x] type-name → identifier
    */
    func parseTypeIdentifier() throws -> TypeIdentifier {
        guard let typeName = readIdentifier(includeContextualKeywords: true) else {
            throw ParserError.MissingIdentifier
        }
        skipWhitespaces()

        var names = [String]()
        names.append(typeName)

        while let token = currentToken {
            if case let .Punctuator(type) = token where type == .Period {
                skipWhitespaces()
                if let subTypeName = readIdentifier(includeContextualKeywords: true) {
                    names.append(subTypeName)
                    skipWhitespaces()
                    continue
                }
            }
            break
        }

        return TypeIdentifier(names: names)
    }

    /*
    - [x] type-inheritance-clause → : class-requirement , type-inheritance-list
    - [x] type-inheritance-clause → : class-requirement
    - [x] type-inheritance-clause → : type-inheritance-list
    - [x] type-inheritance-list → type-identifier | type-identifier , type-inheritance-list
    - [x] class-requirement → class
    */
    func parseTypeInheritanceClause() throws -> TypeInheritanceClause {
        guard let token = currentToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Colon else {
            return []
        }
        skipWhitespaces()

        guard let typeIdentifier = parseEachTypeInheritance() else {
            throw ParserError.MissingIdentifier
        }

        var list = TypeInheritanceClause()
        list.append(typeIdentifier)

        while let token = currentToken {
            if case let .Punctuator(type) = token where type == .Comma {
                skipWhitespaces()
                if let typeIdentifier = parseEachTypeInheritance() {
                    list.append(typeIdentifier)
                    //skipWhitespaces()
                    continue
                }
            }
            break
        }

        return list
    }

    private func parseEachTypeInheritance() -> String? {
        if let token = currentToken, case let .Keyword(keywordName, _) = token where keywordName == "class" {
            skipWhitespaces()
            return "class"
        }
        else if let typeIdentifier = try? parseTypeIdentifier() {
            return typeIdentifier.names.joinWithSeparator(".")
        }
        else {
            return nil
        }
    }
}
