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
    - [x] expression → try-operator/opt/ prefix-expression binary-expressions/opt/
    */
    func parseExpression() throws -> Expression {
        return try _parseAndUnwrapParsingResult {
            self._parseExpression(head: self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseExpression(head: Token?, tokens: [Token]) -> ParsingResult<Expression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        let parsingTryOpExprResult = _parseTryOperatorExpression(head: remainingHeadToken, tokens: remainingTokens)
        guard parsingTryOpExprResult.hasResult else {
            return parsingTryOpExprResult
        }
        for _ in 0..<parsingTryOpExprResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        let parsingBiExprsResult = _parseBinaryExpressions(head: remainingHeadToken, tokens: remainingTokens, lhs: parsingTryOpExprResult.result)
        guard parsingBiExprsResult.hasResult else {
            return parsingTryOpExprResult
        }
        for _ in 0..<parsingBiExprsResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        return ParsingResult<Expression>.makeResult(parsingBiExprsResult.result, tokens.count - remainingTokens.count)
    }

    func parseTryOperatorExpression() throws -> TryOperatorExpression {
        let result = _parseTryOperatorExpression(head: currentToken, tokens: reversedTokens.map { $0.0 })

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

    func _parseTryOperatorExpression(head: Token?, tokens: [Token]) -> ParsingResult<Expression> {
        return _parseAndWrapTryOperatorExpression(head: head, tokens: tokens) {
            self._parsePrefixExpression(head: $0, tokens: $1)
        }
    }

    func _parseAndWrapTryOperatorExpression(
        head: Token?,
        tokens: [Token],
        parsingFunction: (Token?, [Token]) -> ParsingResult<Expression>) -> ParsingResult<Expression> {
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

            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()
        }

        let parseExpressionResult = parsingFunction(remainingHeadToken, remainingTokens)
        guard parseExpressionResult.hasResult else {
            return ParsingResult<Expression>.makeNoResult()
        }
        for _ in 0..<parseExpressionResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        if let tryOperatorKind = tryOperatorKind {
            let prefixExpression = parseExpressionResult.result
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
        return parseExpressionResult
    }

    /*
    - [x] expression-list → expression | expression `,` expression-list
    */
    func parseExpressionList() throws -> [Expression] {
        return try _parseAndUnwrapParsingResult {
            self._parseExpressionList(head: self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseExpressionList(head: Token?, tokens: [Token]) -> ParsingResult<[Expression]> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        let firstExpressionResult = _parseExpression(head: remainingHeadToken, tokens: remainingTokens)
        guard firstExpressionResult.hasResult else {
            return ParsingResult<[Expression]>.makeNoResult()
        }
        for _ in 0..<firstExpressionResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        var expressions = [Expression]()
        expressions.append(firstExpressionResult.result)

        while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Comma {
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let expressionResult = _parseExpression(head: remainingHeadToken, tokens: remainingTokens)
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
