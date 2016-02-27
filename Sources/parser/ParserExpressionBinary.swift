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
    - [x] binary-expressions → binary-expression binary-expressions/opt/

    This method parses the tokens and converts them into a tree structure without considering the operator precedence.
    For example, `1 + 2 * 3 - 4` is understood as -(*(+(1, 2), 3), 4) as a result of this method.
    This tree structure is later transformed into another tree structure by applying operator precedence.
    We will add reference to the transformation method later when it is implemented.
    */
    func _parseBinaryExpressions(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        let parsingHeadBiOpExprResult = _parseBinaryExpression(remainingHeadToken, tokens: remainingTokens, lhs: lhs)
        guard parsingHeadBiOpExprResult.hasResult else {
            return ParsingResult<BinaryExpression>.makeNoResult()
        }
        for _ in 0..<parsingHeadBiOpExprResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        let parsingBiExprsResult = _parseBinaryExpressions(remainingHeadToken, tokens: remainingTokens, lhs: parsingHeadBiOpExprResult.result)
        guard parsingBiExprsResult.hasResult else {
            return parsingHeadBiOpExprResult
        }
        for _ in 0..<parsingBiExprsResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        return ParsingResult<BinaryExpression>.makeResult(parsingBiExprsResult.result, tokens.count - remainingTokens.count)
    }

    /*
    - [x] binary-expression → binary-operator prefix-expression
    - [ ] binary-expression → assignment-operator try-operator/opt/ prefix-expression
    - [ ] binary-expression → conditional-operator try-operator/opt/ prefix-expression
    - [ ] binary-expression → type-casting-operator
    */
    func _parseBinaryExpression(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let currentToken = remainingHeadToken {
            switch currentToken {
            case .Operator(let operatorString):
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()

                let parsingPrefixExprResult = _parsePrefixExpression(remainingHeadToken, tokens: remainingTokens)
                if parsingPrefixExprResult.hasResult {
                    for _ in 0..<parsingPrefixExprResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }

                    let biOpExpr = BinaryOperatorExpression(binaryOperator: operatorString, leftExpression: lhs, rightExpression: parsingPrefixExprResult.result)
                    return ParsingResult<BinaryExpression>.makeResult(biOpExpr, tokens.count - remainingTokens.count)
                }
            default:
                return ParsingResult<BinaryExpression>.makeNoResult()
            }
        }

        return ParsingResult<BinaryExpression>.makeNoResult()
    }

    func parseBinaryOperatorExpression() throws -> BinaryOperatorExpression {
        let binaryOperatorExpression: BinaryOperatorExpression = try _parseBinaryExpressionAndCastToType()
        return binaryOperatorExpression
    }

    private func _parseBinaryExpressionAndCastToType<U>() throws -> U {
        let result = _parseExpression(currentToken, tokens: reversedTokens.map { $0.0 })

        guard result.hasResult else {
            throw ParserError.InternalError // TODO: better error handling
        }

        guard let binaryExpression = result.result as? U else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        try rewindAllWhitespaces()

        return binaryExpression
    }

}
