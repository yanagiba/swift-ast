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
    - [x] postfix-expression → primary-expression
    - [x] postfix-expression → postfix-expression postfix-operator
    - [_] postfix-expression → function-call-expression
    - [x] postfix-expression → initializer-expression
    - [x] postfix-expression → explicit-member-expression
    - [x] postfix-expression → postfix-self-expression
    - [x] postfix-expression → dynamic-type-expression
    - [x] postfix-expression → subscript-expression
    - [x] postfix-expression → forced-value-expression
    - [x] postfix-expression → optional-chaining-expression
    */
    func parsePostfixExpression() throws -> PostfixExpression {
        return try _parseAndUnwrapParsingResult {
            self._parsePostfixExpression(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parsePostfixExpression(head: Token?, tokens: [Token]) -> ParsingResult<PostfixExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        var previousUsedToken: Token?

        let parsePrimaryExpressionResult = _parsePrimaryExpression(remainingHeadToken, tokens: remainingTokens)
        guard parsePrimaryExpressionResult.hasResult else {
            return ParsingResult<PostfixExpression>.makeNoResult()
        }
        for _ in 0..<parsePrimaryExpressionResult.advancedBy {
            previousUsedToken = remainingHeadToken
            remainingHeadToken = remainingTokens.popLast()
        }

        var resultExpression: PostfixExpression = parsePrimaryExpressionResult.result

        postfixLoop: while let currentHeadToken = remainingHeadToken {
            switch currentHeadToken {
            case .Punctuator(let punctuatorType):
                switch punctuatorType {
                case .LeftParen:
                    let parseParenExprResult = _parseParenthesizedExpression(remainingHeadToken, tokens: remainingTokens)
                    guard parseParenExprResult.hasResult else {
                        break postfixLoop
                    }
                    for _ in 0..<parseParenExprResult.advancedBy {
                        previousUsedToken = remainingHeadToken
                        remainingHeadToken = remainingTokens.popLast()
                    }

                    resultExpression = FunctionCallExpression.makeParenthesizedFunctionCallExpression(resultExpression, parseParenExprResult.result)
                case .Period:
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let parseDotPostfixExprResult = _parseDotPostfixExpression(
                        remainingHeadToken, tokens: remainingTokens, postfixExpression: resultExpression)
                    guard parseDotPostfixExprResult.hasResult else {
                        break postfixLoop
                    }
                    for _ in 0..<parseDotPostfixExprResult.advancedBy {
                        previousUsedToken = remainingHeadToken
                        remainingHeadToken = remainingTokens.popLast()
                    }

                    resultExpression = parseDotPostfixExprResult.result
                case .LeftSquare:
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let parsingExpressionListResult = _parseExpressionList(remainingHeadToken, tokens: remainingTokens)
                    guard parsingExpressionListResult.hasResult  else {
                        break postfixLoop
                    }
                    for _ in 0..<parsingExpressionListResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }

                    if let closingToken = remainingHeadToken, case let .Punctuator(punctuatorType) = closingToken
                    where punctuatorType == .RightSquare {
                        for _ in 0..<remainingTokens.count-skipWhitespacesForTokens(remainingTokens).count {
                            previousUsedToken = remainingHeadToken
                            remainingHeadToken = remainingTokens.popLast()
                        }
                        previousUsedToken = remainingHeadToken
                        remainingHeadToken = remainingTokens.popLast()

                        resultExpression = SubscriptExpression(
                            postfixExpression: resultExpression, indexExpressions: parsingExpressionListResult.result)
                    }
                    else {
                        break postfixLoop
                    }
                case .Exclaim:
                    guard let previousConsumedToken = previousUsedToken where !previousConsumedToken.isWhitespace() else {
                        break postfixLoop
                    }
                    for _ in 0..<remainingTokens.count-skipWhitespacesForTokens(remainingTokens).count {
                        previousUsedToken = remainingHeadToken
                        remainingHeadToken = remainingTokens.popLast()
                    }
                    previousUsedToken = remainingHeadToken
                    remainingHeadToken = remainingTokens.popLast()

                    resultExpression = ForcedValueExpression(postfixExpression: resultExpression)
                case .Question:
                    guard let previousConsumedToken = previousUsedToken where !previousConsumedToken.isWhitespace() else {
                        break postfixLoop
                    }
                    for _ in 0..<remainingTokens.count-skipWhitespacesForTokens(remainingTokens).count {
                        previousUsedToken = remainingHeadToken
                        remainingHeadToken = remainingTokens.popLast()
                    }
                    previousUsedToken = remainingHeadToken
                    remainingHeadToken = remainingTokens.popLast()

                    resultExpression = OptionalChainingExpression(postfixExpression: resultExpression)
                default:
                    break postfixLoop
                }
            case .Operator(let operatorString):
                for _ in 0..<remainingTokens.count-skipWhitespacesForTokens(remainingTokens).count {
                    previousUsedToken = remainingHeadToken
                    remainingHeadToken = remainingTokens.popLast()
                }
                previousUsedToken = remainingHeadToken
                remainingHeadToken = remainingTokens.popLast()

                resultExpression = PostfixOperatorExpression(
                    postfixOperator: operatorString, postfixExpression: resultExpression)
            default:
                break postfixLoop
            }
        }

        return ParsingResult<PostfixExpression>.makeResult(resultExpression, tokens.count - remainingTokens.count)
    }

    private func _parseDotPostfixExpression(
        head: Token?,
        tokens: [Token],
        postfixExpression resultExpression: PostfixExpression) -> ParsingResult<PostfixExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        // initializer expression, post self expression, dynamic type expression
        if let currentHeadToken = remainingHeadToken, case let .Keyword(keywordStr, _) = currentHeadToken
        where keywordStr == "init" || keywordStr == "self" || keywordStr == "dynamicType" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            if keywordStr == "init" {
                return ParsingResult<PostfixExpression>.makeResult(
                    InitializerExpression(postfixExpression: resultExpression), tokens.count - remainingTokens.count)
            }

            if keywordStr == "self" {
                return ParsingResult<PostfixExpression>.makeResult(
                    PostfixSelfExpression(postfixExpression: resultExpression), tokens.count - remainingTokens.count)
            }

            if keywordStr == "dynamicType" {
                return ParsingResult<PostfixExpression>.makeResult(
                    DynamicTypeExpression(postfixExpression: resultExpression), tokens.count - remainingTokens.count)
            }
        }

        // explicit member expression
        let parseIdExprResult = _parseIdentifierExpression(remainingHeadToken, tokens: remainingTokens)
        if parseIdExprResult.hasResult {
            for _ in 0..<parseIdExprResult.advancedBy {
                remainingHeadToken = remainingTokens.popLast()
            }
            return ParsingResult<PostfixExpression>.makeResult(
                ExplicitMemberExpression.makeNamedTypeExplicitMemberExpression(resultExpression, parseIdExprResult.result),
                tokens.count - remainingTokens.count)
        }
        let parseLiteralExprResult = _parseLiteralExpression(remainingHeadToken, tokens: remainingTokens)
        if let integerLiteralExpr = parseLiteralExprResult.result as? IntegerLiteralExpression
        where parseLiteralExprResult.hasResult && integerLiteralExpr.kind == .Decimal {
            for _ in 0..<parseLiteralExprResult.advancedBy {
                remainingHeadToken = remainingTokens.popLast()
            }
            return ParsingResult<PostfixExpression>.makeResult(
                ExplicitMemberExpression.makeTupleExplicitMemberExpression(resultExpression, integerLiteralExpr),
                tokens.count - remainingTokens.count)
        }

        return ParsingResult<PostfixExpression>.makeNoResult()
    }

    func parsePostfixOperatorExpression() throws -> PostfixOperatorExpression {
        let postfixOperatorExpression: PostfixOperatorExpression = try _parsePostfixExpressionAndCastToType()
        return postfixOperatorExpression
    }

    /*
    - [x] function-call-expression → postfix-expression parenthesized-expression
    - [ ] function-call-expression → postfix-expression parenthesized-expression/opt/ trailing-closure
    - [ ] trailing-closure → closure-expression
    */
    func parseFunctionCallExpression() throws -> FunctionCallExpression {
        let functionCallExpression: FunctionCallExpression = try _parsePostfixExpressionAndCastToType()
        return functionCallExpression
    }

    /*
    - [x] explicit-member-expression → postfix-expression `.` decimal-digits
    - [x] explicit-member-expression → postfix-expression `.` identifier generic-argument-clause/opt/
    */
    func parseExplicitMemberExpression() throws -> ExplicitMemberExpression {
        let explicitMemberExpression: ExplicitMemberExpression = try _parsePostfixExpressionAndCastToType()
        return explicitMemberExpression
    }

    /*
    - [x] initializer-expression → postfix-expression `.` `init`
    */
    func parseInitializerExpression() throws -> InitializerExpression {
        let initializerExpression: InitializerExpression = try _parsePostfixExpressionAndCastToType()
        return initializerExpression
    }

    /*
    - [x] postfix-self-expression → postfix-expression `.` `self`
    */
    func parsePostfixSelfExpression() throws -> PostfixSelfExpression {
        let postfixSelfExpression: PostfixSelfExpression = try _parsePostfixExpressionAndCastToType()
        return postfixSelfExpression
    }

    /*
    - [x] dynamic-type-expression → postfix-expression `.` `dynamicType`
    */
    func parseDynamicTypeExpression() throws -> DynamicTypeExpression {
        let dynamicTypeExpression: DynamicTypeExpression = try _parsePostfixExpressionAndCastToType()
        return dynamicTypeExpression
    }

    /*
    - [x] subscript-expression → postfix-expression `[` expression-list `]`
    */
    func parseSubscriptExpression() throws -> SubscriptExpression {
        let subscriptExpression: SubscriptExpression = try _parsePostfixExpressionAndCastToType()
        return subscriptExpression
    }

    /*
    - [x] forced-value-expression → postfix-expression `!`
    */
    func parseForcedValueExpression() throws -> ForcedValueExpression {
        let forcedValueExpression: ForcedValueExpression = try _parsePostfixExpressionAndCastToType()
        return forcedValueExpression
    }

    /*
    - [x] optional-chaining-expression → postfix-expression `?`
    */
    func parseOptionalChainingExpression() throws -> OptionalChainingExpression {
        let optionalChainingExpression: OptionalChainingExpression = try _parsePostfixExpressionAndCastToType()
        return optionalChainingExpression
    }

    private func _parsePostfixExpressionAndCastToType<U>() throws -> U {
        let result = _parsePostfixExpression(currentToken, tokens: reversedTokens.map { $0.0 })

        guard result.hasResult else {
            throw ParserError.InternalError // TODO: better error handling
        }

        guard let postfixExpression = result.result as? U else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        try rewindAllWhitespaces()

        return postfixExpression
    }

}
