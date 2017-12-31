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

extension Lexer /* numeric literal */ {
  public func lexNumericLiteral() -> Token.Kind { /*
    swift-lint:suppress(high_cyclomatic_complexity)
    swift-lint:suppress(high_npath_complexity)
    swift-lint:suppress(high_ncss)
    */
    var negativeNumber = false
    var integerPart: Int = 0
    var fractionalPart: (decimal: Double, offset: Int)?
    var negativeExponent = false
    var exponentPart: Int?

    var rawRepresentation = ""

    var radix = 0
    var part = Part.integer

    func consumeMinusSign() {
      guard char.role == .minus else {
        return
      }

      rawRepresentation = char.string
      _consume(.minus)
      negativeNumber = true
    }

    func consumeExponentHead(withRadix rdx: Int) {
      _consume(char.role)

      rawRepresentation += char.string
      let prt = Part.exponent
      switch char.unicodeScalar {
      case "0"..."9" where appendUnicodeScalar(char.unicodeScalar, to: prt, withRadix: rdx):
        radix = rdx
        part = prt
      case "+":
        consumeDigitHead(withRadix: rdx, to: prt)
      case "-":
        negativeExponent = true
        consumeDigitHead(withRadix: rdx, to: prt)
      default:
        break
      }
    }

    @discardableResult func consumeDigitHead(withRadix rdx: Int, to prt: Part) -> Bool {
      _consume(char.role)

      rawRepresentation += char.string
      switch char.string.lowercased() {
      case
        "0"..."9" where appendUnicodeScalar(char.unicodeScalar, to: prt, withRadix: rdx),
        "a"..."f" where appendUnicodeScalar(char.unicodeScalar, to: prt, withRadix: rdx):
        radix = rdx
        part = prt
        return true
      default:
        return false
      }
    }

    func appendUnicodeScalar(_ scalar: UnicodeScalar, to part: Part, withRadix rdx: Int) -> Bool {
      if rdx == 16, let v = scalar.hex {
        appendValue(v, to: part, withRadix: rdx)
        return true
      } else if let v = scalar.int {
        appendValue(v, to: part, withRadix: rdx)
        return true
      } else {
        return false
      }
    }

    func appendValue(_ value: Int, to part: Part, withRadix rdx: Int) {
      switch part {
      case .integer:
        integerPart = integerPart * rdx + value
      case .decimal:
        let offset = (fractionalPart?.offset ?? 0) + 1
        var decimalValue = Double(value)
        for _ in 0..<offset {
          decimalValue /= Double(rdx)
        }
        let decimal = (fractionalPart?.decimal ?? 0.0) + decimalValue
        fractionalPart = (decimal, offset)
      case .exponent:
        exponentPart = (exponentPart ?? 0) * 10 + value
      }
    }

    // lex a minus sign if it's a negative nubmer
    consumeMinusSign()

    guard let firstInt = char.int else {
      return .invalid(.digitCharExpected)
    }

    // lex first char
    rawRepresentation += char.string
    switch firstInt {
    case 1...9:
      integerPart = firstInt
      radix = 10
      part = .integer
    case 0:
      _consume(char.role)

      guard char.role == .digit || char.role == .identifierHead || char.role == .period else {
        return .integerLiteral(integerPart, rawRepresentation: rawRepresentation)
      }

      rawRepresentation += char.string
      switch char.unicodeScalar {
      case "b":
        consumeDigitHead(withRadix: 2, to: .integer)
      case "o":
        consumeDigitHead(withRadix: 8, to: .integer)
      case "x":
        consumeDigitHead(withRadix: 16, to: .integer)
      case "1"..."9":
        integerPart = char.int!
        fallthrough
      case "_", "0":
        radix = 10
        part = .integer
      case ".":
        consumeDigitHead(withRadix: 10, to: .decimal)
      case "e", "E":
        consumeExponentHead(withRadix: 10)
      default:
        return .invalid(.badChar)
      }
    default:
      return .invalid(.badChar)
    }
    _consume(char.role)

    var intRawRepresentation: String?
    var dotCheckpoint: String?
    var breakFromBadCharInDecimal = false

    // lex second character and forward
    charLoop: while char != .eof {
      let scalar = char.unicodeScalar

      switch (char.role, char.string.lowercased()) {
      case
        (.digit, "0"..."9") where appendUnicodeScalar(scalar, to: part, withRadix: radix),
        (.identifierHead, "_"),
        (.identifierHead, "a"..."d")
          where part != .exponent && appendUnicodeScalar(scalar, to: part, withRadix: radix),
        (.identifierHead, "f")
          where part != .exponent && appendUnicodeScalar(scalar, to: part, withRadix: radix):
        rawRepresentation += char.string
      case (.identifierHead, "e") where part != .exponent && radix == 10:
        rawRepresentation += char.string
        consumeExponentHead(withRadix: 10)
      case (.identifierHead, "e") where radix == 16:
        rawRepresentation += char.string
        appendValue(14, to: part, withRadix: radix)
      case (.identifierHead, "p") where part != .exponent && radix == 16:
        rawRepresentation += char.string
        consumeExponentHead(withRadix: 16)
      case (.period, _) where radix >= 10 && part == .integer:
        let currentRawRepresentation = rawRepresentation
        let checkpoint = checkPoint()

        rawRepresentation += char.string
        guard consumeDigitHead(withRadix: radix, to: .decimal) else {
          rawRepresentation = currentRawRepresentation
          restore(fromCheckpoint: checkpoint)
          breakFromBadCharInDecimal = true
          break charLoop
        }

        intRawRepresentation = currentRawRepresentation
        dotCheckpoint = checkpoint
      case (_, "a"..."z"), (_, "_"):
        if let intRawRepresentation = intRawRepresentation, let dotCheckpoint = dotCheckpoint {
          rawRepresentation = intRawRepresentation
          restore(fromCheckpoint: dotCheckpoint)
          breakFromBadCharInDecimal = true
        }

        break charLoop
      default:
        break charLoop
      }

      _consume(char.role)
    }

    // construct token if success
    if radix == 16 && fractionalPart != nil && exponentPart == nil && !breakFromBadCharInDecimal {
      return .invalid(.badNumber)
    }

    // construct an integer literal
    if (fractionalPart == nil && exponentPart == nil) || breakFromBadCharInDecimal {
      return .integerLiteral(
        negativeNumber ? -integerPart : integerPart,
        rawRepresentation: rawRepresentation)
    }

    // construct a floating-point literal
    var floatingPoint = Double(integerPart)
    if let fractionPart = fractionalPart {
      floatingPoint += fractionPart.decimal
    }
    if let exponentPart = exponentPart {
      let rdx: Double = radix == 10 ? 10 : 2
      if negativeExponent {
        for _ in 0..<exponentPart {
          floatingPoint /= rdx
        }
      } else {
        for _ in 0..<exponentPart {
          floatingPoint *= rdx
        }
      }
    }
    return .floatingPointLiteral(
      negativeNumber ? -floatingPoint : floatingPoint,
      rawRepresentation: rawRepresentation)
  }

  private enum Part {
    case integer
    case decimal
    case exponent
  }
}

/*-
 * Thie file contains code derived from
 * https://github.com/demmys/treeswift/blob/master/src/Parser/NumericLiteralComposer.swift
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
