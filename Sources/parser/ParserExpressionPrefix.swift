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
    - [x] prefix-expression → prefix-operator/opt/ postfix-expression
    - [x] prefix-expression → in-out-expression
    - [x] in-out-expression → `&` identifier
    */
    func _parsePrefixExpression(head: Token?, tokens: [Token]) -> ParsingResult<Expression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .Amp {
            remainingHeadToken = remainingTokens.popLast()
            guard let identifier = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) else {
                return ParsingResult<Expression>.makeNoResult()
            }
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()
            let inOutExpr = InOutExpression(identifier: identifier)
            return ParsingResult<Expression>.makeResult(inOutExpr, tokens.count - remainingTokens.count)
        }

        var prefixOperator: String? = nil
        if let token = remainingHeadToken, case let .Operator(operatorString) = token {
            remainingHeadToken = remainingTokens.popLast()
            prefixOperator = operatorString
        }
        let parsePostfixExpressionResult = _parsePostfixExpression(head: remainingHeadToken, tokens: remainingTokens)
        if parsePostfixExpressionResult.hasResult {
            if let prefixOperator = prefixOperator {
                let prefixOperatorExpr = PrefixOperatorExpression(
                    prefixOperator: prefixOperator, postfixExpression: parsePostfixExpressionResult.result)
                return ParsingResult<Expression>.makeResult(prefixOperatorExpr, tokens.count - remainingTokens.count)
            }
            else {
                return ParsingResult<Expression>.wrap(parsePostfixExpressionResult)
            }
        }

        return ParsingResult<Expression>.makeNoResult()
    }

    func parsePrefixOperatorExpression() throws -> PrefixOperatorExpression {
        let result = _parsePrefixExpression(head: currentToken, tokens: reversedTokens.map { $0.0 })

        guard result.hasResult else {
            throw ParserError.InternalError // TODO: better error handling
        }

        guard let prefixOperatorExpression = result.result as? PrefixOperatorExpression else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        try rewindAllWhitespaces()

        return prefixOperatorExpression
    }

    func parseInOutExpression() throws -> InOutExpression {
        let result = _parsePrefixExpression(head: currentToken, tokens: reversedTokens.map { $0.0 })

        guard result.hasResult else {
            throw ParserError.InternalError // TODO: better error handling
        }

        guard let inOutExpression = result.result as? InOutExpression else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        try rewindAllWhitespaces()

        return inOutExpression
    }
}
