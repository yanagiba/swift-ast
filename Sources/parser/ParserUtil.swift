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

extension Parser {
    func skipWhitespaces(for tokens: [Token], treatSemiAsWhitespace: Bool = false) -> [Token] {
        var remainingTokens = tokens
        var remainingHeadToken: Token?
        var isWhitespace = false
        repeat {
            remainingHeadToken = remainingTokens.popLast()
            isWhitespace = false
            if let remainingHeadToken = remainingHeadToken {
                if remainingHeadToken.isWhitespace() {
                    isWhitespace = true
                }
                else if case let .Punctuator(punctuatorType) = remainingHeadToken, case .Semi = punctuatorType where treatSemiAsWhitespace {
                    isWhitespace = true
                }
            }
        } while isWhitespace
        if let headToken = remainingHeadToken {
            remainingTokens.append(headToken)
            return remainingTokens
        }
        return remainingTokens
    }

    func skipWhitespaces(treatSemiAsWhitespace: Bool = false) {
        shiftToken()

        while let token = currentToken {
            if token.isWhitespace() {
                shiftToken()
                continue
            }
            if case let .Punctuator(punctuatorType) = token, case .Semi = punctuatorType where treatSemiAsWhitespace {
                shiftToken()
                continue
            }
            break
        }
    }

    func rewindAllWhitespaces() throws {
        if let token = currentToken where !token.isWhitespace() && reversedTokens.isEmpty {
            // this is the end of the lexical context, and it's not a white space,
            // so this is the last meaningful token that we are looking for, therefore, simply return.
            return
        }

        try unshiftToken()
        while let token = currentToken where token.isWhitespace() {
            try unshiftToken()
        }
    }

    func ensureStatementSeparator(stopAtRightBrace: Bool = false) throws {
        shiftToken()

        while let token = currentToken {
            if case let .Punctuator(punctuatorType) = token {
                if case .Semi = punctuatorType {
                    return
                }
                else if case .RightBrace = punctuatorType where stopAtRightBrace {
                    return
                }
                else {
                    try unshiftToken()
                    throw ParserError.MissingSeparator
                }
            }
            else if case .LineFeed = token {
                return
            }
            else if case .CarriageReturn = token {
                return
            }
            else if token.isWhitespace() {
                shiftToken()
            }
            else {
                try unshiftToken()
                throw ParserError.MissingSeparator
            }
        }
    }

    func sourceRangeOfLastConsumedToken() -> SourceRange? {
        return consumedTokens.last?.1
    }
}
