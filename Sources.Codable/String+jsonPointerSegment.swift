//
//  String+jsonPointerSegment.swift
//  AdaptyCodable
//
//  Created by Aleksei Valiano on 28.05.2026.
//

import Foundation

public extension String {
    /// Encodes this string as a JSON Pointer segment that matches object keys
    /// serialised with `\uXXXX` escapes (e.g. Python `json.dumps` default,
    /// Java Jackson with `ESCAPE_NON_ASCII`, and what the Adapty backend emits).
    ///
    /// Encoding rules:
    /// - ASCII characters (U+0000..U+007F), except `/` and `~`, pass through.
    /// - `/` becomes `~1`, `~` becomes `~0` per RFC 6901.
    /// - BMP non-ASCII code points (U+0080..U+FFFF) become one `\uXXXX` escape.
    /// - Supplementary code points (U+10000..U+10FFFF) become a UTF-16
    ///   surrogate pair: `\uHHHH\uLLLL`.
    /// - Hex digits are lowercase (matching the Adapty backend output).
    ///
    /// The returned string does NOT include the leading `/` separator —
    /// concatenate segments yourself when building a multi-segment pointer:
    ///
    /// ```swift
    /// let pointer = "/" + "€".jsonPointerSegment       // "/€"
    /// let nested  = "/items/" + "👍".jsonPointerSegment // "/items/👍"
    /// try data.jsonExtract(pointer: pointer)
    /// ```
    ///
    /// This helper is the right tool when the source JSON uses `\uXXXX`
    /// escapes. When the JSON uses raw UTF-8 bytes for the same key, just use
    /// the original string — Pointer comparison is byte-for-byte against the
    /// raw JSON form (see the Raw-form contract in `Data+jsonExtract`).
    var jsonPointerSegment: String {
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
            case 0x80 ... 0xffff: // BMP non-ASCII
                result += reverseSolidus + String(format: "u%04x", scalar.value)
            default: // supplementary plane — UTF-16 surrogate pair
                let v = scalar.value - 0x10000
                let high = 0xd800 + (v >> 10)
                let low = 0xdc00 + (v & 0x3ff)
                result += reverseSolidus + String(format: "u%04x", high)
                result += reverseSolidus + String(format: "u%04x", low)
            }
        }

        return result
    }
}
