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

public class ProtocolCompositionType: Type {
    private let _protocols: [TypeIdentifier]

    public init(protocols: [TypeIdentifier]) {
        _protocols = protocols
    }

    public var protocols: [TypeIdentifier] {
        return _protocols
    }

    public func inspect() -> String {
        return "Protocol<\(_protocols.map { $0.inspect() }.joined(separator: ","))>"
    }
}
