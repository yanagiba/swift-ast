/*
   Copyright 2015-2016 Ryuichi Saito, LLC

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

public class Parser {
    var topLevelCode: TopLevelDeclaration
    var reversedTokens: [TokenWithLocation]
    var consumedTokens: [TokenWithLocation]

    public init() {
        topLevelCode = TopLevelDeclaration()
        reversedTokens = [TokenWithLocation]()
        consumedTokens = [TokenWithLocation]()
    }

    var currentTokenWithLocation: TokenWithLocation?
    var currentToken: Token? {
        return currentTokenWithLocation?.0
    }
    var currentRange: SourceRange? {
        return currentTokenWithLocation?.1
    }

    public func parse(source: SourceFile) -> (astContext: ASTContext, errors: [String]) {
        let lexer = Lexer()
        let lexicalContext = lexer.lex(source: source)
        return parse(source: source, lexicalContext: lexicalContext)
    }

    func parse(source: SourceFile, lexicalContext: LexicalContext) -> (astContext: ASTContext, errors: [String]) {
        topLevelCode = TopLevelDeclaration()
        reversedTokens = lexicalContext.tokens.reversed()
        consumedTokens = [TokenWithLocation]()

        var parserErrors = [String]() // TODO: we probably will handle this with diagnostic classes

        shiftToken()

        guard let firstRange = currentRange else {
            return (ASTContext(topLevelCode: topLevelCode, source: source), parserErrors)
        }
        let startLocation = firstRange.start

        while let token = currentToken {
            do {
                if isStartOfDeclaration(headToken: token, tailTokens: reversedTokens) {
                    try parseDeclaration()
                }
            }
            catch ParserError.InternalError {  // TODO: better error message mapping
                parserErrors.append("Fetal error.") // This should not happen
            }
            catch ParserError.MissingSeparator {
                parserErrors.append("Statements must be separated by line breaks or semicolons.")
            }
            catch ParserError.MissingIdentifier {
                parserErrors.append("Missing identifier.")
            }
            catch ParserError.MissingModuleNameInImportDeclaration {
                parserErrors.append("Missing module name in import declaration.")
            }
            catch ParserError.PostfixPeriodIsReserved {
                parserErrors.append("Postfix '.' is reserved.")
            }
            catch ParserError.InvalidModifierToDeclaration(let modifier) {
                parserErrors.append("'\(modifier)' modifier cannot be applied to this declaration.")
            }
            catch ParserError.InvalidClassRequirement {
                parserErrors.append("'class' requirement only applies to protocols.")
            }
            catch {
                parserErrors.append("Unknown error.")
            }

            shiftToken()
        }

        if let lastRange = sourceRangeOfLastConsumedToken() {
            topLevelCode.sourceRange = SourceRange(start: startLocation, end: lastRange.end)
        }

        return (ASTContext(topLevelCode: topLevelCode, source: source), parserErrors)
    }
}
