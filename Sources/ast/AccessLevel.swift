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

public enum AccessLevel {
    case Default

    case Public
    case Internal
    case Private
    case PublicSet
    case InternalSet
    case PrivateSet
}

extension AccessLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case Default: return "default"
        case Public: return "public"
        case Internal: return "internal"
        case Private: return "private"
        case PublicSet: return "public(set)"
        case InternalSet: return "internal(set)"
        case PrivateSet: return "private(set)"
        }
    }
}
