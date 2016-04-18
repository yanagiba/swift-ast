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

import ast

extension Parser {
    /*
    - [_] attribute → `@` attribute-name attribute-argument-clause/opt/
    - [x] attribute-name → identifier
    - [ ] attribute-argument-clause → `(` balanced-tokens/opt/ `)`
    - [ ] attributes → attribute attributes/opt/
    - [ ] balanced-tokens → balanced-token balanced-tokens/opt/
    - [ ] balanced-token → `(` balanced-tokens/opt/ `)`
    - [ ] balanced-token → `[` balanced-tokens/opt/ `]`
    - [ ] balanced-token → `{` balanced-tokens/opt/ `}`
    - [ ] balanced-token → Any identifier, keyword, literal, or operator
    - [ ] balanced-token → Any punctuation except `(`, `)`, `[`, `]`, `{`, or `}`
    - [_] error handling
    */
    func parseAttributes() -> [Attribute] {
        let parsingAttributesResult = parseAttributes(head: currentToken, tokens: reversedTokens.map { $0.0 })
        for _ in 0..<parsingAttributesResult.advancedBy {
            shiftToken()
        }
        return parsingAttributesResult.attributes
    }

    func parseAttributes(head: Token?, tokens: [Token]) -> (attributes: [Attribute], advancedBy: Int) {
        var remainingTokens = tokens
        var remainingHeadToken: Token? = head

        var declarationAttributes = [Attribute]()
        while let token = remainingHeadToken, case let .Punctuator(type) = token where type == .At {
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()

            guard let attributeName = readIdentifier(forToken: remainingHeadToken) else {
                break
            }

            declarationAttributes.append(Attribute(name: attributeName))
            remainingTokens = skipWhitespaces(for: remainingTokens)
            remainingHeadToken = remainingTokens.popLast()
        }
        return (declarationAttributes, tokens.count - remainingTokens.count)
    }
}
