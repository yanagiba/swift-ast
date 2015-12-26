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

import source
import ast

public class Parser {
    private var _topLevelCode: TopLevelDeclaration
    private var _reversedTokens: [TokenWithLocation]
    private var _consumedTokens: [TokenWithLocation]

    public init() {
        _topLevelCode = TopLevelDeclaration()
        _reversedTokens = [TokenWithLocation]()
        _consumedTokens = [TokenWithLocation]()
    }

    private var currentTokenWithLocation: TokenWithLocation?
    private var currentToken: Token? {
        return currentTokenWithLocation?.0
    }
    private var currentRange: SourceRange? {
        return currentTokenWithLocation?.1
    }

    private func shiftToken() {
        if let token = currentTokenWithLocation {
            _consumedTokens.append(token)
        }

        currentTokenWithLocation = _reversedTokens.popLast()
    }

    private func unshiftToken() throws {
        guard let token = currentTokenWithLocation else {
            throw ParserError.InteralError
        }

        _reversedTokens.append(token)
        currentTokenWithLocation = _consumedTokens.popLast()
    }

    public func parse(source: SourceFile) -> (astContext: ASTContext, errors: [String]) {
        let lexer = Lexer()
        let lexicalContext = lexer.lex(source)
        return _parse(lexicalContext)
    }

    private func _parse(lexicalContext: LexicalContext) -> (astContext: ASTContext, errors: [String]) {
        _topLevelCode = TopLevelDeclaration()
        _reversedTokens = lexicalContext.tokens.reverse()
        _consumedTokens = [TokenWithLocation]()

        var parserErrors = [String]() // TODO: we probably will handle this with diagnostic classes

        shiftToken()

        guard let firstRange = currentRange else {
            return (ASTContext(topLevelCode: _topLevelCode), parserErrors)
        }
        let startLocation = firstRange.start

        while let token = currentToken {
            do {
                if _isStartOfDeclaration(token, tailTokens: _reversedTokens) {
                    try _parseDeclaration()
                }
            }
            catch ParserError.InteralError {  // TODO: better error message mapping
                parserErrors.append("Fetal error.") // This should not happen
            }
            catch ParserError.MissingSeparator {
                parserErrors.append("Statements must be separated by line breaks or semicolons.")
            }
            catch ParserError.MissingIdentifier {
                parserErrors.append("Missing identifier.")
            }
            catch ParserError.MissingModuleNameInImportDeclaration {
                parserErrors.append("Missing module name in import declaration.")
            }
            catch ParserError.PostfixPeriodIsReserved {
                parserErrors.append("Postfix '.' is reserved.")
            }
            catch {
                parserErrors.append("Unknown error.")
            }

            shiftToken()
        }

        if let lastRange = _sourceRangeOfLastConsumedToken() {
            _topLevelCode.sourceRange = SourceRange(start: startLocation, end: lastRange.end)
        }

        return (ASTContext(topLevelCode: _topLevelCode), parserErrors)
    }

    private func _isStartOfDeclaration(headToken: Token?, tailTokens: [TokenWithLocation]) -> Bool {
        let tailOnlyTokens = tailTokens.map { $0.0 }
        return _isStartOfDeclaration(headToken, tailTokens: tailOnlyTokens)
    }

    private func _isStartOfDeclaration(headToken: Token?, tailTokens: [Token]) -> Bool {
        guard let headToken = headToken else {
            return false
        }

        switch headToken {
        case let .Punctuator(type):
            if type == .At {
                var remainingTokens = _skipWhitespacesForTokens(tailTokens)
                if let remainingHeadToken = remainingTokens.popLast() {
                    switch remainingHeadToken {
                    case .Identifier(_):
                        remainingTokens = _skipWhitespacesForTokens(remainingTokens)
                        return _isStartOfDeclaration(remainingTokens.popLast(), tailTokens: remainingTokens)
                    default:
                        return false
                    }
                }
                return false
            }
            return false
        case let .Keyword(_, type):
            return type == .Declaration
        default:
            return false
        }
    }

    private func _parseAttributes() -> [Attribute] {
        var declarationAttributes = [Attribute]()
        parseAttributesLoop: while let token = currentToken {
            switch token {
            case let .Punctuator(type):
                if type == .At {
                    _skipWhitespaces()
                    if let attributeName = _readIdentifier() {
                        declarationAttributes.append(Attribute(name: attributeName))
                        _skipWhitespaces()
                        continue parseAttributesLoop
                    }
                    else {
                        // TODO: error handling
                    }
                }
                else {
                    break parseAttributesLoop
                }
            default:
                break parseAttributesLoop
            }
        }
        return declarationAttributes
    }

    private func _parseDeclaration() throws {
        let declarationAttributes = _parseAttributes()

        guard let token = currentToken else {
            throw ParserError.InteralError
        }

        guard case let .Keyword(name, _) = token else {
            throw ParserError.InteralError
        }

        switch name {
        case "import":
            try _parseImportDeclaration(attributes: declarationAttributes)
        default: ()
        }

        try _ensureStatementSeparator()
    }

    private func _parseImportDeclaration(attributes attributes: [Attribute]) throws {
        guard let startRange = currentRange else {
            throw ParserError.InteralError
        }
        let startLocation = startRange.start

        _skipWhitespaces()

        var importKind: ImportKind = .Module
        if let token = currentToken, case let .Keyword(keyName, keywordType) = token where keywordType == .Declaration {
            switch keyName {
            case "typealias":
                importKind = .Typealias
                _skipWhitespaces()
            case "struct":
                importKind = .Struct
                _skipWhitespaces()
            case "class":
                importKind = .Class
                _skipWhitespaces()
            case "enum":
                importKind = .Enum
                _skipWhitespaces()
            case "protocol":
                importKind = .Protocol
                _skipWhitespaces()
            case "var":
                importKind = .Var
                _skipWhitespaces()
            case "func":
                importKind = .Func
                _skipWhitespaces()
            default: ()
            }
        }

        if let moduleName = _readIdentifier(includeContextualKeywords: true) {
            var submodules = [String]()
            shiftToken()

            while let token = currentToken {
                if case let .Punctuator(type) = token where type == .Period {
                    shiftToken()
                    if let submoduleName = _readIdentifier(includeContextualKeywords: true) {
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
            if let currentRange = currentRange ?? _consumedTokens.last?.1 {
                importDecl.sourceRange = SourceRange(start: startLocation, end: currentRange.end)
            }
            _topLevelCode.append(importDecl)

            if importKind != .Module && submodules.isEmpty {
                throw ParserError.MissingModuleNameInImportDeclaration
            }
            if let token = currentToken ?? _consumedTokens.last?.0, case let .Punctuator(type) = token where type == .Period {
                throw ParserError.PostfixPeriodIsReserved
            }
        }
        else {
            throw ParserError.MissingIdentifier
        }
    }

    private func _readIdentifier(includeContextualKeywords includeContextualKeywords: Bool = false) -> String? {
        guard let token = currentToken else {
            return nil
        }

        if case let .Identifier(identifier) = token {
            return identifier
        }
        else if case let .BacktickIdentifier(identifier) = token {
            return identifier
        }
        else if case let .Keyword(identifier, keywordType) = token, case .Contextual(_) = keywordType where includeContextualKeywords {
            return identifier
        }
        else {
            return nil
        }
    }

    private func _skipWhitespacesForTokens(tokens: [Token]) -> [Token] {
        var remainingTokens = tokens
        var remainingHeadToken: Token?
        var isWhitespace = false
        repeat {
            remainingHeadToken = remainingTokens.popLast()
            isWhitespace = remainingHeadToken?.isWhitespace() ?? false // when token is nil, terminate the loop
        } while isWhitespace
        if let headToken = remainingHeadToken {
            remainingTokens.append(headToken)
            return remainingTokens
        }
        return remainingTokens
    }

    private func _skipWhitespaces() {
        shiftToken()

        while let token = currentToken where token.isWhitespace() {
            shiftToken()
        }
    }

    private func _ensureStatementSeparator() throws {
        shiftToken()

        while let token = currentToken {
            if case let .Punctuator(punctuatorType) = token {
                if case .Semi = punctuatorType {
                    return
                }
                else {
                    try unshiftToken()
                    throw ParserError.MissingSeparator
                }
            }
            else if case .LineFeed = token {
                return
            }
            else if case .CarriageReturn = token {
                return
            }
            else if token.isWhitespace() {
                shiftToken()
            }
            else {
                try unshiftToken()
                throw ParserError.MissingSeparator
            }
        }
    }

    private func _sourceRangeOfLastConsumedToken() -> SourceRange? {
        return _consumedTokens.last?.1
    }

}
