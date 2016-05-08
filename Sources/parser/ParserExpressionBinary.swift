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

        let parsingHeadBiOpExprResult = _parseBinaryExpression(head: remainingHeadToken, tokens: remainingTokens, lhs: lhs)
        guard parsingHeadBiOpExprResult.hasResult else {
            return ParsingResult<BinaryExpression>.makeNoResult()
        }
        for _ in 0..<parsingHeadBiOpExprResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        let parsingBiExprsResult = _parseBinaryExpressions(head: remainingHeadToken, tokens: remainingTokens, lhs: parsingHeadBiOpExprResult.result)
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
    - [x] binary-expression → assignment-operator try-operator/opt/ prefix-expression
    - [x] binary-expression → conditional-operator try-operator/opt/ prefix-expression
    - [x] binary-expression → type-casting-operator
    */
    func _parseBinaryExpression(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        if let currentToken = head {
            switch currentToken {
            case .Keyword(_, _):
                return _parseTypeCastingOperatorExpression(head: head, tokens: tokens, lhs: lhs)
            case .Punctuator(let punctuatorType):
                switch punctuatorType {
                case .Equal:
                    return _parseAssignmentOperatorExpression(head: head, tokens: tokens, lhs: lhs)
                case .Question:
                    return _parseTernaryConditionalOperatorExpression(head: head, tokens: tokens, lhs: lhs)
                default:
                    return ParsingResult<BinaryExpression>.makeNoResult()
                }
            case .Operator(_):
                return _parseBinaryOperatorExpression(head: head, tokens: tokens, lhs: lhs)
            default:
                return ParsingResult<BinaryExpression>.makeNoResult()
            }
        }

        return ParsingResult<BinaryExpression>.makeNoResult()
    }

    private func _parseBinaryOperatorExpression(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let headToken = remainingHeadToken, case let .Operator(operatorString) = headToken {
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let parsingPrefixExprResult = _parsePrefixExpression(head: remainingHeadToken, tokens: remainingTokens)
            if parsingPrefixExprResult.hasResult {
                for _ in 0..<parsingPrefixExprResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                let biOpExpr = BinaryOperatorExpression(binaryOperator: operatorString, leftExpression: lhs, rightExpression: parsingPrefixExprResult.result)
                return ParsingResult<BinaryExpression>.makeResult(biOpExpr, tokens.count - remainingTokens.count)
            }
        }

        return ParsingResult<BinaryExpression>.makeNoResult()
    }

    /*
    - [x] conditional-operator → `?` try-operator/opt/ expression `:`
    */
    private func _parseTernaryConditionalOperatorExpression(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let headToken = remainingHeadToken, case let .Punctuator(punctuatorType) = headToken where punctuatorType == .Question {
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let parsingTrueExprResult =
                _parseAndWrapTryOperatorExpression(head: remainingHeadToken, tokens: remainingTokens) { self._parseExpression(head: $0, tokens: $1) }
            if parsingTrueExprResult.hasResult {
                for _ in 0..<parsingTrueExprResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                if let colonToken = remainingHeadToken, case let .Punctuator(colonPunctuator) = colonToken where colonPunctuator == .Colon {
                    remainingTokens = skipWhitespaces(for: remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let parsingFalseExprResult = _parseTryOperatorExpression(head: remainingHeadToken, tokens: remainingTokens)
                    if parsingFalseExprResult.hasResult {
                        for _ in 0..<parsingFalseExprResult.advancedBy {
                            remainingHeadToken = remainingTokens.popLast()
                        }

                        let ternaryConditionalOpExpr = TernaryConditionalOperatorExpression(
                            conditionExpression: lhs,
                            trueExpression: parsingTrueExprResult.result,
                            falseExpression: parsingFalseExprResult.result)
                        return ParsingResult<BinaryExpression>.makeResult(ternaryConditionalOpExpr, tokens.count - remainingTokens.count)
                    }
                }
            }
        }

        return ParsingResult<BinaryExpression>.makeNoResult()
    }

    /*
    - [x] assignment-operator → `=`
    */
    private func _parseAssignmentOperatorExpression(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let headToken = remainingHeadToken, case let .Punctuator(punctuatorType) = headToken where punctuatorType == .Equal {
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let parsingTryOpExprResult = _parseTryOperatorExpression(head: remainingHeadToken, tokens: remainingTokens)
            if parsingTryOpExprResult.hasResult {
                for _ in 0..<parsingTryOpExprResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                let assignmentOpExpr = AssignmentOperatorExpression(leftExpression: lhs, rightExpression: parsingTryOpExprResult.result)
                return ParsingResult<BinaryExpression>.makeResult(assignmentOpExpr, tokens.count - remainingTokens.count)
            }
        }

        return ParsingResult<BinaryExpression>.makeNoResult()
    }

    /*
    - [x] type-casting-operator → `is` type
    - [x] type-casting-operator → `as` type
    - [x] type-casting-operator → `as``?` type
    - [x] type-casting-operator → `as``!` type
    */
    private func _parseTypeCastingOperatorExpression(head: Token?, tokens: [Token], lhs: Expression) -> ParsingResult<BinaryExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let headToken = remainingHeadToken, case let .Keyword(keywordString, _) = headToken where keywordString == "is" || keywordString == "as" {
            var castingKind: TypeCastingOperatorExpression.Kind = .Is
            if keywordString == "as" {
                castingKind = .As
                if let nextToken = remainingTokens.last, case let .Punctuator(punctuatorType) = nextToken
                where punctuatorType == .Exclaim || punctuatorType == .Question {
                    remainingHeadToken = remainingTokens.popLast()
                    if punctuatorType == .Exclaim {
                        castingKind = .ForcedAs
                    }
                    else {
                        castingKind = .OptionalAs
                    }
                }
            }
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            let parsingTypeResult = parseType(head: remainingHeadToken, tokens: remainingTokens)
            if let type = parsingTypeResult.type {
                for _ in 0..<parsingTypeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                let typeCastingOpExpr = TypeCastingOperatorExpression(kind: castingKind, expression: lhs, type: type)
                return ParsingResult<BinaryExpression>.makeResult(typeCastingOpExpr, tokens.count - remainingTokens.count)
            }
        }

        return ParsingResult<BinaryExpression>.makeNoResult()
    }

    func parseBinaryOperatorExpression() throws -> BinaryOperatorExpression {
        let binaryOperatorExpression: BinaryOperatorExpression = try _parseBinaryExpressionAndCastToType()
        return binaryOperatorExpression
    }

    func parseAssignmentOperatorExpression() throws -> AssignmentOperatorExpression {
        let assignmentOperatorExpression: AssignmentOperatorExpression = try _parseBinaryExpressionAndCastToType()
        return assignmentOperatorExpression
    }

    func parseTernaryConditionalOperatorExpression() throws -> TernaryConditionalOperatorExpression {
        let ternaryConditionalOperatorExpression: TernaryConditionalOperatorExpression = try _parseBinaryExpressionAndCastToType()
        return ternaryConditionalOperatorExpression
    }

    func parseTypeCastingOperatorExpression() throws -> TypeCastingOperatorExpression {
        let typeCastingOperatorExpression: TypeCastingOperatorExpression = try _parseBinaryExpressionAndCastToType()
        return typeCastingOperatorExpression
    }

    private func _parseBinaryExpressionAndCastToType<U>() throws -> U {
        let result = _parseExpression(head: currentToken, tokens: reversedTokens.map { $0.0 })

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
