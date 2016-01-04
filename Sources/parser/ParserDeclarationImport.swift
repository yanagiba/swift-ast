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
    - [x] import-declaration → attributes/opt/ `import` import-kind/opt/ import-path
    - [x] import-kind → `typealias` | `struct` | `class` | `enum` | `protocol` | `var` | `func`
    - [x] import-path → import-path-identifier | import-path-identifier `.` import-path
    - [_] import-path-identifier → identifier | operator
    - [x] error handling
    */
    func parseImportDeclaration(
        attributes attributes: [Attribute], startLocation: SourceLocation) throws {
        skipWhitespaces()

        var importKind: ImportKind = .Module
        if let token = currentToken, case let .Keyword(keyName, keywordType) = token where keywordType == .Declaration {
            switch keyName {
            case "typealias":
                importKind = .Typealias
                skipWhitespaces()
            case "struct":
                importKind = .Struct
                skipWhitespaces()
            case "class":
                importKind = .Class
                skipWhitespaces()
            case "enum":
                importKind = .Enum
                skipWhitespaces()
            case "protocol":
                importKind = .Protocol
                skipWhitespaces()
            case "var":
                importKind = .Var
                skipWhitespaces()
            case "func":
                importKind = .Func
                skipWhitespaces()
            default: ()
            }
        }

        if let moduleName = readIdentifier(includeContextualKeywords: true) {
            var submodules = [String]()
            shiftToken()

            while let token = currentToken {
                if case let .Punctuator(type) = token where type == .Period {
                    shiftToken()
                    if let submoduleName = readIdentifier(includeContextualKeywords: true) {
                        submodules.append(submoduleName)
                        shiftToken()
                    }
                }
                else {
                    try unshiftToken()
                    break
                }
            }

            let importDecl = ImportDeclaration(module: moduleName, submodules: submodules, importKind: importKind, attributes: attributes)
            if let currentRange = currentRange ?? consumedTokens.last?.1 {
                importDecl.sourceRange = SourceRange(start: startLocation, end: currentRange.end)
            }
            topLevelCode.append(importDecl)

            if importKind != .Module && submodules.isEmpty {
                throw ParserError.MissingModuleNameInImportDeclaration
            }
            if let token = currentToken ?? consumedTokens.last?.0, case let .Punctuator(type) = token where type == .Period {
                throw ParserError.PostfixPeriodIsReserved
            }
        }
        else {
            throw ParserError.MissingIdentifier
        }
    }
}
