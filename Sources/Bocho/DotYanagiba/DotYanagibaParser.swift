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

struct DotYanagibaParser {
  private func extractModules(from content: String) -> [String: [String]] {
    var modules: [String: [String]] = [:]

    var moduleName = ""
    var lines: [String] = []

    func addToModule() {
      if !moduleName.isEmpty && !lines.isEmpty {
        modules[moduleName] = lines
      }
    }

    for line in content.components(separatedBy: "\n") {
      if line.hasPrefix("#") {
        continue
      } else if !line.hasPrefix(" ") && line.hasSuffix(":") {
        addToModule()

        let name = String(line[..<line.index(before: line.endIndex)])
        moduleName = name
        lines = []
      } else if line.hasPrefix(" ") && !moduleName.isEmpty {
        let whitespaceRemoved = line.components(separatedBy: .whitespaces).joined()
        lines.append(whitespaceRemoved)
      }
    }

    addToModule()

    return modules
  }

  private func extractOptions(from lines: [String]) -> [String: [String]] {
    var options: [String: [String]] = [:]

    var currentKey = ""
    var currentOptions: [String] = []

    for line in lines {
      if line.hasPrefix("-") {
        let option = String(line[line.index(after: line.startIndex)...])
        currentOptions.append(option)
      } else {
        if !currentKey.isEmpty {
          if !currentOptions.isEmpty {
            options[currentKey] = currentOptions
            currentOptions = []
          }
          currentKey = ""
        }

        let keyValuePair = line.components(separatedBy: ":")
        if keyValuePair.count == 2 {
          let key = keyValuePair[0]
          let value = keyValuePair[1]
          if value.isEmpty {
            currentKey = key
          } else {
            options[key] = [value]
          }
        }
      }
    }

    if !currentKey.isEmpty && !currentOptions.isEmpty {
      options[currentKey] = currentOptions
    }

    return options
  }

  private func extractKeyValuePair(from options: [String]) -> [String: String] {
    var dict: [String: String] = [:]

    for option in options {
      let keyValuePair = option.components(separatedBy: ":")
      if keyValuePair.count == 2 {
        let key = keyValuePair[0]
        dict[key] = keyValuePair[1]
      }
    }

    return dict
  }

  private func extractOption(for options: [String]) -> DotYanagiba.Module.Option {
    if options.count == 1 {
      let firstOption = options[0]
      if let firstInt = Int(firstOption) {
        return .int(firstInt)
      }
      return .string(firstOption)
    }

    let keyValues = extractKeyValuePair(from: options)
    if keyValues.count == options.count {
      var intKeyValues: [String: Int] = [:]
      for (key, value) in keyValues {
        if let intValue = Int(value) {
          intKeyValues[key] = intValue
        }
      }
      if intKeyValues.count == keyValues.count {
        return .dictInt(intKeyValues)
      }
      return .dictString(keyValues)
    }

    let listInts = options.compactMap { Int($0) }
    if listInts.count == options.count {
      return .listInt(listInts)
    }

    return .listString(options)
  }

  func parse(content: String) -> DotYanagiba {
    var modules: [String: DotYanagiba.Module] = [:]

    for (moduleName, lines) in extractModules(from: content) {
      var options: [String: DotYanagiba.Module.Option] = [:]

      for (key, option) in extractOptions(from: lines) {
        options[key] = extractOption(for: option)
      }

      let module = DotYanagiba.Module(options: options)
      modules[moduleName] = module
    }

    return DotYanagiba(modules: modules)
  }
}
