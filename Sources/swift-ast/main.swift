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

import PathKit

import source
import parser

var filePaths = Process.arguments
filePaths.removeAtIndex(0)

for filePath in filePaths {
  let absolutePath = Path(filePath).absolute()

  guard let fileContent = try? absolutePath.read(NSUTF8StringEncoding) else {
    print("Error in reading file \(absolutePath)")
    continue
  }

  let sourceFile = SourceFile(path: "\(absolutePath)", content: fileContent)

  let parser = Parser()
  let parserStartTime = CFAbsoluteTimeGetCurrent()
  let (astContext, errors) = parser.parse(sourceFile)
  let parserTimeElapsed = CFAbsoluteTimeGetCurrent() - parserStartTime

  for error in errors {
    print("Parser error: \(error)")
  }
  print("")
  print(astContext.inspect())
  print("")
  print("----------")
  print("File contains \(fileContent.characters.count) chars, and it takes \(parserTimeElapsed) seconds to parse.")
  print("----------")
}
