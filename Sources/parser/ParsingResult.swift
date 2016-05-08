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

class ParsingResult<T> {
    private let _result: T?
    private let _advancedBy: Int
    // let errors; [ParserError] // TODO: collect parser errors

    private init(result: T?, advancedBy: Int) {
        _result = result
        _advancedBy = advancedBy
    }
}

extension ParsingResult {
    var advancedBy: Int {
        return _advancedBy
    }

    var result: T {
        return _result!
    }

    var hasResult: Bool {
        return _result != nil
    }

    var getOrNil: T? {
        return _result
    }
}

extension ParsingResult {
    class func makeResult(_ result: T, _ advancedBy: Int) -> ParsingResult<T> {
        return ParsingResult<T>(result: result, advancedBy: advancedBy)
    }

    class func makeNoResult() -> ParsingResult<T> {
        return ParsingResult<T>(result: nil, advancedBy: 0)
    }
}

extension ParsingResult {
    class func wrap<U>(_ result: ParsingResult<U>) -> ParsingResult<T> {
        if let wrappedResult = result.result as? T {
            return ParsingResult<T>.makeResult(wrappedResult, result.advancedBy)
        }
        return ParsingResult<T>.makeNoResult()
    }
}

extension Parser {
    func _parseAndUnwrapParsingResult<U>(parsingFunction: () -> ParsingResult<U>) throws -> U {
        let result = parsingFunction()

        guard result.hasResult else {
            throw ParserError.InternalError // TODO: better error handling
        }

        for _ in 0..<result.advancedBy {
            shiftToken()
        }

        try rewindAllWhitespaces()

        return result.result
    }
}
