/*
   Copyright 2016-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

class Scanner {
  private typealias Pointer = String.UnicodeScalarView.Index

  private struct _Point {
    let pointer: Pointer
    let line: Int
    let column: Int
  }

  private var _checkpoints: [String: _Point]

  private var _content: String.UnicodeScalarView
  private var _currentPointer: Pointer
  private var _nextPointer: Pointer {
    return _content.index(after: _currentPointer)
  }

  var line: Int
  var column: Int

  init(content: String) {
    _checkpoints = [:]
    _content = content.unicodeScalars
    _currentPointer = _content.startIndex
    line = 1
    column = 1
  }

  func scan() -> Char {
    guard let current = _scan(_currentPointer) else {
      return .eof
    }
    let role = Role.role(of: current, followedBy: peek())
    return Char(unicodeScalar: current, role: role)
  }

  func peek() -> UnicodeScalar? {
    return _scan(_nextPointer)
  }

  private func _scan(_ ptr: Pointer) -> UnicodeScalar? {
    guard ptr < _content.endIndex else {
      return nil
    }
    return _content[ptr]
  }

  func advance(by count: Int = 1) {
    for _ in 0..<count {
      _advance()
    }
  }

  private func _advance() {
    let current = scan()

    guard current != .eof else {
      return
    }

    switch current.unicodeScalar {
    case "\0":
      break
    case "\n":
      line += 1
      column = 1
    case "\r":
      column = 1
    default:
      column += 1
    }
    _currentPointer = _nextPointer
  }

  func checkPoint() -> String {
    let point = _Point(pointer: _currentPointer, line: line, column: column)
    let id = UUID().uuidString
    _checkpoints[id] = point
    return id
  }

  @discardableResult func restore(fromCheckpoint cpId: String) -> Bool {
    guard let point = _checkpoints[cpId] else {
      return false
    }

    _currentPointer = point.pointer
    line = point.line
    column = point.column
    return true
  }
}

/*-
 * Thie file contains code derived from
 * https://github.com/demmys/treeswift/blob/master/src/Parser/CharacterStream.swift
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
