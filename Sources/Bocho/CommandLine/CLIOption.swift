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

public class CLIOption {
  public private(set) var arguments: [String]

  public init(_ arguments: [String]) {
    self.arguments = arguments
  }

  public func contains(_ option: String) -> Bool {
    return !arguments.filter({ $0 == "-\(option)" || $0 == "--\(option)" }).isEmpty
  }

  public func readAsString(_ option: String) -> String? {
    guard let argIndex = arguments.index(of: "-\(option)") else {
      return nil
    }

    let argValueIndex = arguments.index(after: argIndex)
    guard argValueIndex < arguments.count else {
      return nil
    }
    let option = arguments[argValueIndex]

    arguments.removeSubrange(argIndex...argValueIndex)

    return option
  }

  public func readAsDictionary(_ option: String) -> [String: Any]? {
    guard let optionString = readAsString(option) else {
      return nil
    }

    return optionString.components(separatedBy: ",")
      .compactMap { opt -> (String, String)? in
        let keyValuePair = opt.components(separatedBy: "=")
        guard keyValuePair.count == 2 else {
          return nil
        }
        let key = keyValuePair[0]
        let value = keyValuePair[1]
        return (key, value)
      }
      .reduce([:]) { (carryOver, arg) -> [String: Any] in
        var mutableDict = carryOver
        mutableDict[arg.0] = arg.1
        return mutableDict
      }
  }
}
