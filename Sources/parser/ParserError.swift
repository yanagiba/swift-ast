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

import ast

enum ParserError: ErrorType {
    case InternalError

    case InvalidToken
    case MissingSeparator
    case MissingIdentifier
    case MissingModuleNameInImportDeclaration
    case PostfixPeriodIsReserved
    case InvalidAccessLevelModifierToDeclaration(AccessLevel)
}

extension AccessLevel {
    var errorDescription: String {
        switch self {
        case Default: return ""
        case Public, PublicSet: return "public"
        case Internal, InternalSet: return "internal"
        case Private, PrivateSet: return "private"
        }
    }
}


