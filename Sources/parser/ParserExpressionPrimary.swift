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
    - [x] primary-expression → identifier generic-argument-clause/opt/
    - [ ] primary-expression → literal-expression
    - [ ] primary-expression → self-expression
    - [ ] primary-expression → superclass-expression
    - [ ] primary-expression → closure-expression
    - [ ] primary-expression → parenthesized-expression
    - [ ] primary-expression → implicit-member-expression
    - [ ] primary-expression → wildcard-expression
    */
    func parsePrimaryExpression() throws -> PrimaryExpression {
        let result = parsePrimaryExpression(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let primaryExpression = result.primaryExpression else {
            throw ParserError.InternalError // TODO: better error handling
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return primaryExpression
    }

    func parsePrimaryExpression(head: Token?, tokens: [Token]) -> (primaryExpression: PrimaryExpression?, advancedBy: Int) {
        let parseIdentifierExpressionResult = parseIdentifierExpression(head, tokens: tokens)
        if let identifierExpression = parseIdentifierExpressionResult.identifierExpression {
            return (identifierExpression, parseIdentifierExpressionResult.advancedBy)
        }

        return (nil, 0)
    }

    /*
    - [x] primary-expression → identifier generic-argument-clause/opt/
    */
    func parseIdentifierExpression() throws -> IdentifierExpression {
        let result = parseIdentifierExpression(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let identifierExpression = result.identifierExpression else {
            throw ParserError.InternalError // TODO: better error handling
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return identifierExpression
    }

    func parseIdentifierExpression(head: Token?, tokens: [Token]) -> (identifierExpression: IdentifierExpression?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        guard let identifier = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) else {
            return (nil, 0)
        }
        remainingTokens = skipWhitespacesForTokens(remainingTokens)
        remainingHeadToken = remainingTokens.popLast()

        let genericResult = parseGenericArgumentClause(remainingHeadToken, tokens: remainingTokens)
        for _ in 0..<genericResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        let identifierExpression =
            IdentifierExpression(identifier: identifier, generic: genericResult.genericArgumentClause)

        return (identifierExpression, tokens.count - remainingTokens.count)
    }
}
