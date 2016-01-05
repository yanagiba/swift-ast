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

extension Parser {
    /*
    - [_] declaration → import-declaration
    - [ ] declaration → constant-declaration
    - [ ] declaration → variable-declaration
    - [ ] declaration → typealias-declaration
    - [ ] declaration → function-declaration
    - [_] declaration → enum-declaration
    - [ ] declaration → struct-declaration
    - [ ] declaration → class-declaration
    - [ ] declaration → protocol-declaration
    - [ ] declaration → initializer-declaration
    - [ ] declaration → deinitializer-declaration
    - [ ] declaration → extension-declaration
    - [ ] declaration → subscript-declaration
    - [ ] declaration → operator-declaration
    - [_] error handling
    */
    func parseDeclaration() throws {
        guard let startRange = currentRange else {
            throw ParserError.InternalError
        }
        let startLocation = startRange.start

        let declarationAttributes = parseAttributes()
        let accessLevelModifier = try parseAccessLevelModifier()
        let declarationModifiers = parseDeclarationModifiers()

        guard let token = currentToken else {
            throw ParserError.InternalError
        }

        guard case let .Keyword(name, _) = token else {
            throw ParserError.InternalError
        }

        switch name {
        case "import":
            try parseImportDeclaration(
                attributes: declarationAttributes, startLocation: startLocation)
            if let accessLevelModifier = accessLevelModifier {
                throw ParserError.InvalidAccessLevelModifierToDeclaration(accessLevelModifier)
            }
        case "enum":
            try parseEnumDeclaration(
                attributes: declarationAttributes,
                declarationModifiers: declarationModifiers,
                accessLevelModifier: accessLevelModifier ?? .Default,
                startLocation: startLocation)
        default: ()
        }

        try ensureStatementSeparator()
    }

    func isStartOfDeclaration(headToken: Token?, tailTokens: [TokenWithLocation]) -> Bool {
        let tailOnlyTokens = tailTokens.map { $0.0 }
        return isStartOfDeclaration(headToken, tailTokens: tailOnlyTokens)
    }

    func isStartOfDeclaration(headToken: Token?, tailTokens: [Token]) -> Bool {
        guard let headToken = headToken else {
            return false
        }

        switch headToken {
        case let .Punctuator(type):
            if type == .At {
                var remainingTokens = skipWhitespacesForTokens(tailTokens)
                if let remainingHeadToken = remainingTokens.popLast() {
                    switch remainingHeadToken {
                    case .Identifier(_):
                        remainingTokens = skipWhitespacesForTokens(remainingTokens)
                        return isStartOfDeclaration(remainingTokens.popLast(), tailTokens: remainingTokens)
                    default:
                        return false
                    }
                }
                return false
            }
            return false
        case let .Keyword(_, type):
            switch type {
            case .Declaration:
                return true
            case let .Contextual(contextualType):
                if contextualType == .DeclarationModifier {
                    var remainingTokens = skipWhitespacesForTokens(tailTokens)
                    return isStartOfDeclaration(remainingTokens.popLast(), tailTokens: remainingTokens)
                }
                else {
                    return false
                }
            default:
                return false
            }
        default:
            return false
        }
    }

    private func parseDeclarationModifiers() -> [String] {
        var declarationModifiers = [String]()
        parseModifiersLoop: while let token = currentToken {
            switch token {
            case let .Keyword(modifier, type):
                if case let .Contextual(contextualType) = type where contextualType == .DeclarationModifier {
                    declarationModifiers.append(modifier)
                    skipWhitespaces()
                    continue parseModifiersLoop
                }
                else {
                    break parseModifiersLoop
                }
            default:
                break parseModifiersLoop
            }
        }
        return declarationModifiers
    }
}
