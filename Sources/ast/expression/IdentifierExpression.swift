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

public class IdentifierExpression: PrimaryExpression {
    public let identifier: Identifier
    public let generic: GenericArgumentClause?

    public init(identifier: Identifier, generic: GenericArgumentClause?) {
        self.identifier = identifier
        self.generic = generic
    }

    public convenience init(identifier: Identifier) {
        self.init(identifier: identifier, generic: nil)
    }
}
