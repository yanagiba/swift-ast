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
    - [x] primary-expression → literal-expression
    - [x] primary-expression → self-expression
    - [ ] primary-expression → superclass-expression
    - [ ] primary-expression → closure-expression
    - [ ] primary-expression → parenthesized-expression
    - [ ] primary-expression → implicit-member-expression
    - [ ] primary-expression → wildcard-expression
    */
    func parsePrimaryExpression() throws -> PrimaryExpression {
        return try _parseAndUnwrapParsingResult {
            self._parsePrimaryExpression(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parsePrimaryExpression(head: Token?, tokens: [Token]) -> ParsingResult<PrimaryExpression> {
        let parseIdentifierExpressionResult = _parseIdentifierExpression(head, tokens: tokens)
        if parseIdentifierExpressionResult.hasResult {
            return ParsingResult<PrimaryExpression>.wrap(parseIdentifierExpressionResult)
        }

        let parseLiteralExpressionResult = _parseLiteralExpression(head, tokens: tokens)
        if parseLiteralExpressionResult.hasResult {
            return ParsingResult<PrimaryExpression>.wrap(parseLiteralExpressionResult)
        }

        let parseSelfExpressionResult = _parseSelfExpression(head, tokens: tokens)
        if parseSelfExpressionResult.hasResult {
            return ParsingResult<PrimaryExpression>.wrap(parseSelfExpressionResult)
        }

        return ParsingResult<PrimaryExpression>.makeNoResult()
    }

    /*
    - [x] primary-expression → identifier generic-argument-clause/opt/
    */
    func parseIdentifierExpression() throws -> IdentifierExpression {
        return try _parseAndUnwrapParsingResult {
            self._parseIdentifierExpression(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseIdentifierExpression(head: Token?, tokens: [Token]) -> ParsingResult<IdentifierExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        guard let identifier = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) else {
            return ParsingResult<IdentifierExpression>.makeNoResult()
        }
        remainingTokens = skipWhitespacesForTokens(remainingTokens)
        remainingHeadToken = remainingTokens.popLast()

        let genericResult = parseGenericArgumentClause(remainingHeadToken, tokens: remainingTokens)
        for _ in 0..<genericResult.advancedBy {
            remainingHeadToken = remainingTokens.popLast()
        }

        let identifierExpression =
            IdentifierExpression(identifier: identifier, generic: genericResult.genericArgumentClause)

        return ParsingResult<IdentifierExpression>.makeResult(identifierExpression, tokens.count - remainingTokens.count)
    }

    /*
    - [x] literal-expression → literal
    - [x] literal-expression → array-literal | dictionary-literal
    - [x] literal-expression → __FILE__ | __LINE__ | __COLUMN__ | __FUNCTION__
    - [x] array-literal → `[` array-literal-items/opt/ `]`
    - [x] array-literal-items → array-literal-item `,`/opt/ | array-literal-item `,` array-literal-items
    - [x] array-literal-item → expression
    - [x] dictionary-literal → `[` dictionary-literal-items `]` | `[` `:` `]`
    - [x] dictionary-literal-items → dictionary-literal-item `,`/opt/ | dictionary-literal-item `,` dictionary-literal-items
    - [x] dictionary-literal-item → expression `:` expression
    */
    func parseLiteralExpression() throws -> LiteralExpression {
        return try _parseAndUnwrapParsingResult {
            self._parseLiteralExpression(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseLiteralExpression(head: Token?, tokens: [Token]) -> ParsingResult<LiteralExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        guard let headToken = remainingHeadToken else {
            return ParsingResult<LiteralExpression>.makeNoResult()
        }

        var resultLiteral: LiteralExpression?

        switch headToken {
        case .NilLiteral:
            resultLiteral = NilLiteralExpression()
        case .BinaryIntegerLiteral(let rawString):
            resultLiteral = IntegerLiteralExpression(kind: .Binary, rawString: rawString)
        case .OctalIntegerLiteral(let rawString):
            resultLiteral = IntegerLiteralExpression(kind: .Octal, rawString: rawString)
        case .DecimalIntegerLiteral(let rawString):
            resultLiteral = IntegerLiteralExpression(kind: .Decimal, rawString: rawString)
        case .HexadecimalIntegerLiteral(let rawString):
            resultLiteral = IntegerLiteralExpression(kind: .Hexadecimal, rawString: rawString)
        case .DecimalFloatingPointLiteral(let rawString):
            resultLiteral = FloatLiteralExpression(kind: .Decimal, rawString: rawString)
        case .HexadecimalFloatingPointLiteral(let rawString):
            resultLiteral = FloatLiteralExpression(kind: .Hexadecimal, rawString: rawString)
        case .TrueBooleanLiteral:
            resultLiteral = BooleanLiteralExpression(kind: .True)
        case .FalseBooleanLiteral:
            resultLiteral = BooleanLiteralExpression(kind: .False)
        case .StaticStringLiteral(let rawString):
            resultLiteral = StringLiteralExpression(kind: .Ordinary, rawString: rawString)
        case .InterpolatedStringLiteral(let rawString):
            resultLiteral = StringLiteralExpression(kind: .Interpolated, rawString: rawString)
        case .Punctuator(let punctuatorType) where punctuatorType == .LeftSquare:
            let parsingArrayLiteralExprResult = _parseArrayLiteralExpression(remainingHeadToken, tokens: remainingTokens)
            if parsingArrayLiteralExprResult.hasResult {
                resultLiteral = parsingArrayLiteralExprResult.result
                for _ in 0..<parsingArrayLiteralExprResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }
            }
            else {
                let parsingDictionaryLiteralExprResult = _parseDictionaryLiteralExpression(remainingHeadToken, tokens: remainingTokens)
                if parsingDictionaryLiteralExprResult.hasResult {
                    resultLiteral = parsingDictionaryLiteralExprResult.result
                    for _ in 0..<parsingDictionaryLiteralExprResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }
                }
            }
        case .Keyword(let exprKeyword, let keywordType) where keywordType == .Expression && exprKeyword.hasPrefix("__") && exprKeyword.hasSuffix("__"):
            switch exprKeyword {
            case "__FILE__":
                resultLiteral = SpecialLiteralExpression(kind: .File)
            case "__LINE__":
                resultLiteral = SpecialLiteralExpression(kind: .Line)
            case "__COLUMN__":
                resultLiteral = SpecialLiteralExpression(kind: .Column)
            case "__FUNCTION__":
                resultLiteral = SpecialLiteralExpression(kind: .Function)
            default: ()
            }
        default: ()
        }
        remainingTokens = skipWhitespacesForTokens(remainingTokens)
        remainingHeadToken = remainingTokens.popLast()

        if let resultLiteral = resultLiteral {
            return ParsingResult<LiteralExpression>.makeResult(resultLiteral, tokens.count - remainingTokens.count)
        }
        return ParsingResult<LiteralExpression>.makeNoResult()
    }

    private func _parseArrayLiteralExpression(head: Token?, tokens: [Token]) -> ParsingResult<ArrayLiteralExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .LeftSquare {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            var items = [Expression]()

            while let currentToken = remainingHeadToken {
                if case let .Punctuator(punctuatorType) = currentToken where punctuatorType == .RightSquare {
                    break
                }

                let parsingExpressionResult = _parseExpression(remainingHeadToken, tokens: remainingTokens)
                guard parsingExpressionResult.hasResult else {
                    break
                }
                items.append(parsingExpressionResult.result)

                for _ in 0..<parsingExpressionResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                if let commaToken = remainingHeadToken, case let .Punctuator(punctuatorType) = commaToken where punctuatorType == .Comma {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()
                }
                else {
                    break
                }
            }

            if let currentToken = remainingHeadToken, case let .Punctuator(punctuatorType) = currentToken where punctuatorType == .RightSquare {
                return ParsingResult<ArrayLiteralExpression>.makeResult(ArrayLiteralExpression(items: items), tokens.count - remainingTokens.count)
            }
            else {
                // TODO: error handling, missing closing square
                return ParsingResult<ArrayLiteralExpression>.makeNoResult()
            }
        }

        return ParsingResult<ArrayLiteralExpression>.makeNoResult()
    }

    private func _parseDictionaryLiteralExpression(head: Token?, tokens: [Token]) -> ParsingResult<DictionaryLiteralExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Punctuator(punctuatorType) = token where punctuatorType == .LeftSquare {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            var items = [(Expression, Expression)]()

            while let currentToken = remainingHeadToken {
                if case let .Punctuator(punctuatorType) = currentToken where punctuatorType == .RightSquare {
                    break
                }

                let parsingKeyExpressionResult = _parseExpression(remainingHeadToken, tokens: remainingTokens)
                guard parsingKeyExpressionResult.hasResult else {
                    break
                }

                for _ in 0..<parsingKeyExpressionResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                guard let colonToken = remainingHeadToken, case let .Punctuator(punctuatorType) = colonToken where punctuatorType == .Colon else {
                    return ParsingResult<DictionaryLiteralExpression>.makeNoResult()
                }
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()

                let parsingValueExpressionResult = _parseExpression(remainingHeadToken, tokens: remainingTokens)
                guard parsingValueExpressionResult.hasResult else {
                    return ParsingResult<DictionaryLiteralExpression>.makeNoResult()
                }

                for _ in 0..<parsingValueExpressionResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                items.append((parsingKeyExpressionResult.result, parsingValueExpressionResult.result))

                if let commaToken = remainingHeadToken, case let .Punctuator(punctuatorType) = commaToken where punctuatorType == .Comma {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()
                }
                else {
                    break
                }
            }

            if let currentToken = remainingHeadToken, case let .Punctuator(punctuatorType) = currentToken where punctuatorType == .RightSquare {
                return ParsingResult<DictionaryLiteralExpression>.makeResult(DictionaryLiteralExpression(items: items), tokens.count - remainingTokens.count)
            }
            else {
                // TODO: error handling, missing closing square
                return ParsingResult<DictionaryLiteralExpression>.makeNoResult()
            }
        }

        return ParsingResult<DictionaryLiteralExpression>.makeNoResult()
    }

    /*
    - [x] self-expression → `self`
    - [x] self-expression → `self` `.` identifier
    - [x] self-expression → `self` `[` expression-list `]`
    - [x] self-expression → `self` `.` `init`
    */
    func parseSelfExpression() throws -> SelfExpression {
        return try _parseAndUnwrapParsingResult {
            self._parseSelfExpression(self.currentToken, tokens: self.reversedTokens.map { $0.0 })
        }
    }

    func _parseSelfExpression(head: Token?, tokens: [Token]) -> ParsingResult<SelfExpression> {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let headToken = remainingHeadToken, case let .Keyword(exprKeyword, keywordType) = headToken
        where keywordType == .Expression && exprKeyword == "self" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            var selfExpr = SelfExpression.makeSelfExpression()

            if let connectingToken = remainingHeadToken, case let .Punctuator(punctuatorType) = connectingToken
            where punctuatorType == .Period || punctuatorType == .LeftSquare {
                remainingTokens = skipWhitespacesForTokens(remainingTokens)
                remainingHeadToken = remainingTokens.popLast()

                if punctuatorType == .Period {
                    if let keywordToken = remainingHeadToken, case let .Keyword(declKeyword, keywordType) = keywordToken
                    where keywordType == .Declaration && declKeyword == "init" {
                        remainingTokens = skipWhitespacesForTokens(remainingTokens)
                        remainingHeadToken = remainingTokens.popLast()

                        selfExpr = SelfExpression.makeSelfInitializerExpression()
                    }
                    else if let identifier = readIdentifier(includeContextualKeywords: true, forToken: remainingHeadToken) {
                        remainingTokens = skipWhitespacesForTokens(remainingTokens)
                        remainingHeadToken = remainingTokens.popLast()

                        selfExpr = SelfExpression.makeSelfMethodExpression(identifier)
                    }
                }
                else {
                    let parsingExpressionListResult = _parseExpressionList(remainingHeadToken, tokens: remainingTokens)
                    if parsingExpressionListResult.hasResult {
                        for _ in 0..<parsingExpressionListResult.advancedBy {
                            remainingHeadToken = remainingTokens.popLast()
                        }

                        if let closingToken = remainingHeadToken, case let .Punctuator(punctuatorType) = closingToken
                        where punctuatorType == .RightSquare {
                            remainingTokens = skipWhitespacesForTokens(remainingTokens)
                            remainingHeadToken = remainingTokens.popLast()

                            selfExpr = SelfExpression.makeSelfSubscriptExpression(parsingExpressionListResult.result)
                        }
                    }
                }
            }

            return ParsingResult<SelfExpression>.makeResult(selfExpr, tokens.count - remainingTokens.count)
        }

        return ParsingResult<SelfExpression>.makeNoResult()
    }
}
