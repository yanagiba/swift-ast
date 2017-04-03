/*
   Copyright 2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

extension Role {
  var isSeparator: Bool {
    switch self {
    case .lineFeed, .semi, .space, .period, .comma, .colon:
      return true
    default:
      return false
    }
  }

  var isHeadSeparator: Bool {
    if isSeparator {
      return true
    }

    switch self {
    case .multipleLineCommentTail, .leftParen, .leftBrace, .leftSquare:
      return true
    default:
      return false
    }
  }

  var isTailSeparator: Bool {
    if isSeparator {
      return true
    }

    switch self {
    case .multipleLineCommentHead, .rightParen, .rightBrace, .rightSquare:
      return true
    default:
      return false
    }
  }
}
