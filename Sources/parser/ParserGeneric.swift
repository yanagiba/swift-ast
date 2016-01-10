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
    - [x] generic-argument-clause → `<` generic-argument-list `>`
    - [x] generic-argument-list → generic-argument | generic-argument `,` generic-argument-list
    - [x] generic-argument → type
    */
    func parseGenericArgumentClause() throws -> GenericArgumentClause {
        let result = parseGenericArgumentClause(currentToken, tokens: reversedTokens.map { $0.0 })

        guard let genericArgumentClause = result.genericArgumentClause else {
            throw ParserError.InternalError
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        return genericArgumentClause
    }

    func parseGenericArgumentClause(head: Token?, tokens: [Token]) -> (genericArgumentClause: GenericArgumentClause?, advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == "<" {
            remainingTokens = skipWhitespacesForTokens(remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            var types = [Type]()
            let firstTypeResult = parseType(remainingHeadToken, tokens: remainingTokens)
            if let firstType = firstTypeResult.type {
                types.append(firstType)

                for _ in 0..<firstTypeResult.advancedBy {
                    remainingHeadToken = remainingTokens.popLast()
                }

                while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .Comma {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    let typeResult = parseType(remainingHeadToken, tokens: remainingTokens)
                    guard let type = typeResult.type else {
                        break
                    }
                    types.append(type)

                    for _ in 0..<typeResult.advancedBy {
                        remainingHeadToken = remainingTokens.popLast()
                    }
                }

                if let token = remainingHeadToken, case let .Operator(operatorString) = token where operatorString == ">" {
                    remainingTokens = skipWhitespacesForTokens(remainingTokens)
                    remainingHeadToken = remainingTokens.popLast()

                    return (GenericArgumentClause(types: types), tokens.count - remainingTokens.count)
                }
            }
            else {
                // TODO: error handling, at least one type is required
            }
        }

        return (nil, 0)
    }

}
