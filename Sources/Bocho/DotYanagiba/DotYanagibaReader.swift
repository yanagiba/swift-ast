/*
   Copyright 2017 Ryuichi Intellectual Property and the Yanagiba project contributors

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

public struct DotYanagibaReader {
  public static func read(from path: String) -> DotYanagiba? {
    guard FileManager.default.fileExists(atPath: path),
      let content = try? String(contentsOfFile: path, encoding: .utf8)
    else {
      return nil
    }

    let dotYanagibaParser = DotYanagibaParser()
    return dotYanagibaParser.parse(content: content)
  }

  public static func read() -> DotYanagiba? {
    var homeDotYanagiba: DotYanagiba?
    if let homeEnv = getenv("HOME"), let homePath = String(utf8String: homeEnv) {
      homeDotYanagiba = read(from: "\(homePath)/.yanagiba")
    }

    let pwd = FileManager.default.currentDirectoryPath
    guard let currentDotYanagiba = read(from: "\(pwd)/.yanagiba") else {
      return homeDotYanagiba
    }

    if let dotYanagibaLint = homeDotYanagiba {
      return DotYanagiba.merge(dotYanagibaLint, with: currentDotYanagiba)
    }

    return currentDotYanagiba
  }
}
