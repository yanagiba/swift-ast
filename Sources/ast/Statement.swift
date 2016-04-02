/*
   Copyright 2015 Ryuichi Saito, LLC

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

import util
import source

public class Statement: ASTNode {

    public var sourceRange: SourceRange

    public init() {
        sourceRange = SourceRange(
            start: SourceLocation(path: "<unknown>", line: 0, column: 0),
            end: SourceLocation(path: "<unknown>", line: 0, column: 0))
    }

    public func inspect(indent: Int = 0) -> String {
        return "\(getIndentText(indent))(statement)".terminalColor(.Red)
    }

    func getSourceRangeText() -> String {
        let rangeStr = "\(sourceRange.start.line):\(sourceRange.start.column)-"
            + "\(sourceRange.end.line):\(sourceRange.end.column)"
        return "path=\(sourceRange.start.path) range=\(rangeStr)"
    }

    func getIndentText(indent: Int) -> String {
        return String(repeating: (" " as Character), count: (indent * 2))
    }
}
