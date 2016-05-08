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
            self._parsePostfixExpression(head: self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parsePostfixExpression(head: Token?, tokens: [Token]) -> ParsingResult<PostfixExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        var previousUsedToken: Token?

        let parsePrimaryExpressionResult = _parsePrimaryExpression(head: remainingHeadToken, tokens: remainingTokens)
        guard parsePrimaryExpressionResult.hasResult else {
            return ParsingResult<PostfixExpression>.makeNoResult()
        }
        __advancedTokensAndPreservePreviousToken(
            parsePrimaryExpressionResult.advancedBy, &remainingTokens, &remainingHeadToken, &previousUsedToken)

        var resultExpression: PostfixExpression = parsePrimaryExpressionResult.result

        postfixLoop: while let currentHeadToken = remainingHeadToken {
            switch currentHeadToken {
            case .Punctuator(let punctuatorType):
                switch punctuatorType {
                case .LeftParen:
                    let parseParenExprResult = _parseParenthesizedExpression(head: remainingHeadToken, tokens: remainingTokens)
                    guard parseParenExprResult.hasResult else {
                        break postfixLoop
                    }
                    __advancedTokensAndPreservePreviousToken(
                        parseParenExprResult.advancedBy, &remainingTokens, &remainingHeadToken, &previousUsedToken)
                    resultExpression = FunctionCallExpression.makeParenthesizedFunctionCallExpression(resultExpression, parseParenExprResult.result)
                case .Period:
                    remainingTokens = skipWhitespaces(for: remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let parseDotPostfixExprResult = _parseDotPostfixExpression(
                        head: remainingHeadToken, tokens: remainingTokens, postfixExpression: resultExpression)
                    guard parseDotPostfixExprResult.hasResult else {
                        break postfixLoop
                    }
                    __advancedTokensAndPreservePreviousToken(
                        parseDotPostfixExprResult.advancedBy, &remainingTokens, &remainingHeadToken, &previousUsedToken)
                    resultExpression = parseDotPostfixExprResult.result
                case .LeftSquare:
                    remainingTokens = skipWhitespaces(for: remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let parsingExpressionListResult = _parseExpressionList(head: remainingHeadToken, tokens: remainingTokens)
                    guard parsingExpressionListResult.hasResult else {
                        break postfixLoop
                    }
                    __advancedTokensAndPreservePreviousToken(
                        parsingExpressionListResult.advancedBy, &remainingTokens, &remainingHeadToken, &previousUsedToken)
                    if let closingToken = remainingHeadToken, case let .Punctuator(punctuatorType) = closingToken
                    where punctuatorType == .RightSquare {
                        __skipWhitespacesAndPreservePreviousToken(&remainingTokens, &remainingHeadToken, &previousUsedToken)
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
                    __skipWhitespacesAndPreservePreviousToken(&remainingTokens, &remainingHeadToken, &previousUsedToken)
                    resultExpression = ForcedValueExpression(postfixExpression: resultExpression)
                case .Question:
                    guard let previousConsumedToken = previousUsedToken where !previousConsumedToken.isWhitespace() else {
                        break postfixLoop
                    }
                    __skipWhitespacesAndPreservePreviousToken(&remainingTokens, &remainingHeadToken, &previousUsedToken)
                    resultExpression = OptionalChainingExpression(postfixExpression: resultExpression)
                default:
                    break postfixLoop
                }
            case .Operator(let operatorString):
                guard let previousConsumedToken = previousUsedToken where !previousConsumedToken.isWhitespace() else {
                    break postfixLoop
                }
                guard __isValidPostfixOperatorExpression(head: remainingHeadToken, tokens: remainingTokens) else {
                    break postfixLoop
                }
                __skipWhitespacesAndPreservePreviousToken(&remainingTokens, &remainingHeadToken, &previousUsedToken)
                resultExpression = PostfixOperatorExpression(
                    postfixOperator: operatorString, postfixExpression: resultExpression)
            default:
                break postfixLoop
            }
        }
        return ParsingResult<PostfixExpression>.makeResult(resultExpression, tokens.count - remainingTokens.count - (remainingHeadToken == nil ? 1 : 0))
    }

    private func __skipWhitespacesAndPreservePreviousToken( // method with side effect
        _ remainingTokens: inout [Token], _ remainingHeadToken: inout Token?, _ previousUsedToken: inout Token?) {
        __advancedTokensAndPreservePreviousToken(
            remainingTokens.count - skipWhitespaces(for: remainingTokens).count + 1,
            &remainingTokens,
            &remainingHeadToken,
            &previousUsedToken)
    }

    private func __advancedTokensAndPreservePreviousToken( // method with side effect
        _ advancedBy: Int,
        _ remainingTokens: inout [Token],
        _ remainingHeadToken: inout Token?,
        _ previousUsedToken: inout Token?) {
        for _ in 0..<advancedBy {
            previousUsedToken = remainingHeadToken
            remainingHeadToken = remainingTokens.popLast()
        }
    }

    private func __isValidPostfixOperatorExpression(head: Token?, tokens: [Token]) -> Bool {
        // TODO: the goal for this method is to verify if there is a prefix expression following the operator
        // TODO: the approach here is very nasty, and need to reconsider
        if tokens.isEmpty {
            return true
        }

        var remainingTokens = tokens
        let _ = remainingTokens.popLast()
        remainingTokens = skipWhitespaces(for: tokens)
        let remainingHeadToken = remainingTokens.popLast()
        let parsingPrefixExpressionResult = _parsePrefixExpression(head: remainingHeadToken, tokens: remainingTokens)
        return !parsingPrefixExpressionResult.hasResult
    }

    private func _parseDotPostfixExpression(
        head: Token?,
        tokens: [Token],
        postfixExpression resultExpression: PostfixExpression) -> ParsingResult<PostfixExpression> {
        let parseDotKeywordPostfixExpressionResult = _parseDotKeywordPostfixExpression(
            head: head, tokens: tokens, postfixExpression: resultExpression)
        if parseDotKeywordPostfixExpressionResult.hasResult {
            return parseDotKeywordPostfixExpressionResult
        }

        return _parseExplicitMemberExpression(head: head, tokens: tokens, postfixExpression: resultExpression)
    }

    private func _parseExplicitMemberExpression(
        head: Token?,
        tokens: [Token],
        postfixExpression resultExpression: PostfixExpression) -> ParsingResult<PostfixExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        let parseIdExprResult = _parseIdentifierExpression(head: remainingHeadToken, tokens: remainingTokens)
        if parseIdExprResult.hasResult {
            for _ in 0..<parseIdExprResult.advancedBy {
                remainingHeadToken = remainingTokens.popLast()
            }
            return ParsingResult<PostfixExpression>.makeResult(
                ExplicitMemberExpression.makeNamedTypeExplicitMemberExpression(resultExpression, parseIdExprResult.result),
                tokens.count - remainingTokens.count)
        }
        let parseLiteralExprResult = _parseLiteralExpression(head: remainingHeadToken, tokens: remainingTokens)
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

    private func _parseDotKeywordPostfixExpression(
        head: Token?,
        tokens: [Token],
        postfixExpression resultExpression: PostfixExpression) -> ParsingResult<PostfixExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let currentHeadToken = remainingHeadToken, case let .Keyword(keywordStr, _) = currentHeadToken
        where keywordStr == "init" || keywordStr == "self" || keywordStr == "dynamicType" {
            remainingTokens = skipWhitespaces(for: remainingTokens)
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
        let result = _parsePostfixExpression(head: currentToken, tokens: reversedTokens.map { $0.0 })

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
