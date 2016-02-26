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
    - [_] expression → try-operator/opt/ prefix-expression binary-expressions/opt/
    */
    func parseExpression() throws -> Expression {
        return try _parseAndUnwrapParsingResult {
            self._parseExpression(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseExpression(head: Token?, tokens: [Token]) -> ParsingResult<Expression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        var tryOperatorKind: TryOperatorExpression.Kind? = nil
        if let keywordToken = remainingHeadToken, case let .Keyword(keywordString, _) = keywordToken where keywordString == "try" {
            tryOperatorKind = .Try

            if let punctuatorToken = remainingTokens.last, case let .Punctuator(punctuatorType) = punctuatorToken
            where punctuatorType == .Exclaim || punctuatorType == .Question {
                remainingHeadToken = remainingTokens.popLast()
                if punctuatorType == .Exclaim {
                    tryOperatorKind = .ForcedTry
                }
                else {
                    tryOperatorKind = .OptionalTry
                }
            }

            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()
        }

        let parsePrefixExpressionResult = _parsePrefixExpression(remainingHeadToken, tokens: remainingTokens)
        guard parsePrefixExpressionResult.hasResult else {
            return ParsingResult<Expression>.makeNoResult()
        }

        if let tryOperatorKind = tryOperatorKind {
            let prefixExpression = parsePrefixExpressionResult.result
            let tryOperatorExpr: TryOperatorExpression
            switch tryOperatorKind {
            case .Try:
                tryOperatorExpr = TryOperatorExpression.makeTryOperatorExpression(prefixExpression)
            case .OptionalTry:
                tryOperatorExpr = TryOperatorExpression.makeOptionalTryOperatorExpression(prefixExpression)
            case .ForcedTry:
                tryOperatorExpr = TryOperatorExpression.makeForcedTryOperatorExpression(prefixExpression)
            }
            return ParsingResult<Expression>.makeResult(tryOperatorExpr, tokens.count - remainingTokens.count)
        }
        return parsePrefixExpressionResult
    }

    func parseTryOperatorExpression() throws -> TryOperatorExpression {
        let result = _parseExpression(currentToken, tokens: reversedTokens.map { $0.0 })

        guard result.hasResult else {
            throw ParserError.InternalError // TODO: better error handling
        }

        guard let tryOperatorExpression = result.result as? TryOperatorExpression else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        try rewindAllWhitespaces()

        return tryOperatorExpression
    }

    /*
    - [x] expression-list → expression | expression `,` expression-list
    */
    func parseExpressionList() throws -> [Expression] {
        return try _parseAndUnwrapParsingResult {
            self._parseExpressionList(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseExpressionList(head: Token?, tokens: [Token]) -> ParsingResult<[Expression]> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        let firstExpressionResult = _parseExpression(remainingHeadToken, tokens: remainingTokens)
        guard firstExpressionResult.hasResult else {
            return ParsingResult<[Expression]>.makeNoResult()
        }
        for _ in 0..<firstExpressionResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        var expressions = [Expression]()
        expressions.append(firstExpressionResult.result)

        while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Comma {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let expressionResult = _parseExpression(remainingHeadToken, tokens: remainingTokens)
            guard expressionResult.hasResult else {
                return ParsingResult<[Expression]>.makeNoResult() // TODO: error handling
            }
            expressions.append(expressionResult.result)

            for _ in 0..<expressionResult.advancedBy {
                remainingHeadToken = remainingTokens.popLast()
            }
        }

        return ParsingResult<[Expression]>.makeResult(expressions, tokens.count - remainingTokens.count)
    }
}
