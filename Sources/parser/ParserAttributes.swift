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
        var declarationAttributes = [Attribute]()
        parseAttributesLoop: while let token = currentToken {
            switch token {
            case let .Punctuator(type):
                if type == .At {
                    skipWhitespaces()
                    if let attributeName = readIdentifier() {
                        declarationAttributes.append(Attribute(name: attributeName))
                        skipWhitespaces()
                        continue parseAttributesLoop
                    }
                    else {
                        // TODO: error handling
                    }
                }
                else {
                    break parseAttributesLoop
                }
            default:
                break parseAttributesLoop
            }
        }
        return declarationAttributes
    }
}
