//
//  String+jsonPointerSegment.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 28.05.2026.
//

import Foundation

public extension String {
    /// Encodes this string as a JSON Pointer reference token.
    ///
    /// Encoding rules:
    /// - `/` becomes `~1`, `~` becomes `~0` per RFC 6901.
    /// - When `escapingNonASCII` is `false`, all other characters pass through,
    ///   matching object keys stored as raw UTF-8.
    /// - When `escapingNonASCII` is `true`, BMP non-ASCII code points become one
    ///   `\uXXXX` escape and supplementary code points become a UTF-16 surrogate
    ///   pair `\uHHHH\uLLLL`. Hex digits are lowercase.
    ///
    /// The returned string does NOT include the leading `/` separator —
    /// concatenate segments yourself when building a multi-segment pointer:
    ///
    /// ```swift
    /// let raw = "/" + "€".jsonPointerSegment()
    /// let escaped = "/" + "€".jsonPointerSegment(escapingNonASCII: true)
    /// ```
    func jsonPointerSegment(escapingNonASCII: Bool = false) -> String {
        let reverseSolidus = String(UnicodeScalar(0x5c as UInt8))
        var result = ""
        result.reserveCapacity(unicodeScalars.count)

        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x2f: // "/"
                result += "~1"
            case 0x7e: // "~"
                result += "~0"
            case 0x00 ..< 0x80: // ASCII
                result.unicodeScalars.append(scalar)
            default:
                if !escapingNonASCII {
                    result.unicodeScalars.append(scalar)
                } else if scalar.value <= 0xffff {
                    result += reverseSolidus + String(format: "u%04x", scalar.value)
                } else {
                    let v = scalar.value - 0x10000
                    let high = 0xd800 + (v >> 10)
                    let low = 0xdc00 + (v & 0x3ff)
                    result += reverseSolidus + String(format: "u%04x", high)
                    result += reverseSolidus + String(format: "u%04x", low)
                }
            }
        }

        return result
    }
}
