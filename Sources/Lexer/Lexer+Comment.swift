/*
   Copyright 2015-2017 Ryuichi Laboratories and the Yanagiba project contributors

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

import Source

extension Lexer /* comment */ {
  func lexSingleLineComment(startLocation: SourceLocation) -> /* next */ Token {
    var commentContent = ""
    while char != .eof && char.role != .lineFeed {
      commentContent += char.string
      _consume()
    }
    comments.insert(Comment(content: commentContent, location: startLocation))
    return lex()
  }

  func lexMultipleLineComment(
    startLocation: SourceLocation
  ) -> /* next */ Token {
    var commentContent = ""
    var depth = 1
    while depth > 0 {
      switch char.role {
      case .multipleLineCommentHead:
        _consume(andAdvanceScannerBy: 2)
        commentContent += "/*"
        depth += 1
      case .multipleLineCommentTail:
        if _prevRole == .space {
          _consume(andAdvanceScannerBy: 2)
        } else {
          _consume(.space, andAdvanceScannerBy: 2)
        }
        if (depth > 1) {
          commentContent += "*/"
        }
        depth -= 1
      case .eof:
        return Token(
          kind: .invalid(.unexpectedEndOfFile),
          sourceRange: SourceRange(start: _getCurrentLocation(), end: _getCurrentLocation()),
          roles: [])
      default:
        commentContent += char.string
        _consume()
      }
    }
    comments.insert(Comment(content: commentContent, location: startLocation))
    return lex()
  }
}

/*-
 * Thie file contains code derived from
 * https://github.com/demmys/treeswift/blob/master/src/Parser/TokenStream.swift
 * with the following license:
 *
 * BSD 2-clause "Simplified" License
 *
 * Copyright (c) 2014, Atsuki Demizu
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
