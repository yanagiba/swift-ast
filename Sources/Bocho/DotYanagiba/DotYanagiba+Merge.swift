/*
   Copyright 2017, 2019 Ryuichi Intellectual Property
                        and the Yanagiba project contributors

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

public extension DotYanagiba {
  static func merge(_ one: DotYanagiba, with other: DotYanagiba) -> DotYanagiba {
    var modules = one.modules
    for (moduleName, module) in other.modules {
      if modules[moduleName] == nil {
        modules[moduleName] = module
      } else if let mod = modules[moduleName] {
        var options = mod.options
        for (key, option) in module.options {
          options[key] = option
        }
        modules[moduleName] = DotYanagiba.Module(options: options)
      }
    }
    return DotYanagiba(modules: modules)
  }
}
