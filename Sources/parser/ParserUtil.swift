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
    func skipWhitespacesForTokens(tokens: [Token]) -> [Token] {
        var remainingTokens = tokens
        var remainingHeadToken: Token?
        var isWhitespace = false
        repeat {
            remainingHeadToken = remainingTokens.popLast()
            isWhitespace = remainingHeadToken?.isWhitespace() ?? false // when token is nil, terminate the loop
        } while isWhitespace
        if let headToken = remainingHeadToken {
            remainingTokens.append(headToken)
            return remainingTokens
        }
        return remainingTokens
    }

    func skipWhitespaces() {
        shiftToken()

        while let token = currentToken where token.isWhitespace() {
            shiftToken()
        }
    }

    func ensureStatementSeparator() throws {
        shiftToken()

        while let token = currentToken {
            if case let .Punctuator(punctuatorType) = token {
                if case .Semi = punctuatorType {
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
