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

public enum TerminalColor: Int {
    case Black
    case Red
    case Green
    case Yellow
    case Blue
    case Magenta
    case Cyan
    case White

    case Default
}

public extension String {
    public func toTerminalString(with color: TerminalColor = .Default) -> String {
        let defaultColor = "\u{001B}[0m"
        switch color {
            case .Default:
                return "\(defaultColor)\(self)\(defaultColor)"
            default:
                return "\u{001B}[\(30 + color.rawValue)m\(self)\(defaultColor)"
        }
    }
}
