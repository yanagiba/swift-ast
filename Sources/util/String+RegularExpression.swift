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

import Foundation

public extension String {
    func match(regex: NSRegularExpression, closure: (matches: [String]) -> ()) -> String? {
        if let match = regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.utf16.count)) {
            var groups = [String]()
            for index in 0..<match.numberOfRanges {
                let rangeAtIndex = match.rangeAtIndex(index)
                if rangeAtIndex.location == NSNotFound {
                    groups.append("")
                }
                else {
                    let matchedGroup = self[self.startIndex.advancedBy(rangeAtIndex.location)..<self.startIndex.advancedBy(rangeAtIndex.location + rangeAtIndex.length)]
                    groups.append(matchedGroup)
                }
            }
            closure(matches: groups)
            return nil
        }
        else {
            return self
        }
    }
}
