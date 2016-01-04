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
    - [x] access-level-modifier → `internal` | `internal ( set )`
    - [x] access-level-modifier → `private` | `private ( set )`
    - [x] access-level-modifier → `public` | `public ( set )`
    - [_] error handling
    */
    func parseAccessLevelModifier() throws -> AccessLevel? {
        guard let token = currentToken else {
            throw ParserError.InteralError
        }

        if case let .Keyword(name, _) = token {
            switch name {
            case "public", "private", "internal":
                skipWhitespaces()
                if let openParenToken = currentToken, case let .Punctuator(type) = openParenToken where type == .LeftParen {
                    skipWhitespaces()
                    if let setterAccessLevel = currentToken, case let .Keyword(setterIdentifier, _) = setterAccessLevel where setterIdentifier == "set" {
                        skipWhitespaces()
                        if let closeParenToken = currentToken, case let .Punctuator(type) = closeParenToken where type == .RightParen {
                            skipWhitespaces()
                            if name == "public" {
                                return .PublicSet
                            }
                            else if name == "private" {
                                return .PrivateSet
                            }
                            else {
                                return .InternalSet
                            }
                        }
                        else {
                            throw ParserError.InteralError // TODO: better error handling
                        }
                    }
                    else {
                        throw ParserError.InteralError // TODO: better error handling
                    }
                }
                else {
                    if name == "public" {
                        return .Public
                    }
                    else if name == "private" {
                        return .Private
                    }
                    else {
                        return .Internal
                    }
                }
            default:
                return nil
            }
        }

        return nil
    }
}
