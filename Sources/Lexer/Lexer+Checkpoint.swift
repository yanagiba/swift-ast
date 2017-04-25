/*
   Copyright 2015-2017 Ryuichi Saito, LLC and the Yanagiba project contributors

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

extension Lexer /* checkpoint */ {
  public func checkPoint() -> String {
    let id = _scanner.checkPoint()
    _checkpoints[id] = _loadedTokens
    return id
  }

  @discardableResult public func restore(fromCheckpoint cpId: String) -> Bool {
    guard let loadedTokens = _checkpoints[cpId] else { return false }
    guard _scanner.restore(fromCheckpoint: cpId) else { return false }

    _loadedTokens = loadedTokens
    return true
  }
}
