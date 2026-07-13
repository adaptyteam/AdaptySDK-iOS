//
//  JsonExtractUnicodeEscapeTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 28.05.2026.
//

@testable import AdaptyCodable
import Foundation
import Testing

/// Tests that the simdjson-backed JSON access path handles JSON `\uXXXX`
/// escape sequences in values, in object keys, and across the JSON Pointer /
/// range / inspect APIs.
///
/// Escape sequences are produced programmatically (see `u(_:)` / `us(_:)`),
/// so the Swift source itself contains no backslash literal — the literal
/// reverse-solidus byte is materialised at runtime from `UnicodeScalar(0x5c)`.
struct JsonExtractUnicodeEscapeTests {
    // MARK: - Helpers

    /// Returns a JSON-style `\uXXXX` escape (6 ASCII characters) for a single
    /// UTF-16 code unit. For non-BMP code points use `us(_:)` with the
    /// surrogate pair, e.g. `us(0xd83d, 0xdc4d)` for 👍.
    private static func u(_ code: UInt16) -> String {
        let reverseSolidus = String(UnicodeScalar(0x5c as UInt8))
        return reverseSolidus + "u" + String(format: "%04x", code)
    }

    /// Concatenates multiple `\uXXXX` escapes in order.
    private static func us(_ codes: UInt16...) -> String {
        codes.map { Self.u($0) }.joined()
    }

    private static func decodeString(_ data: Data) throws -> String {
        try JSONDecoder().decode(String.self, from: data)
    }

    // MARK: - Values: BMP characters via \uXXXX

    @Test func valueEuroSignFromEscape() throws {
        // JSON: {"price":"€99"}
        let jsonStr = #"{"price":""# + Self.u(0x20ac) + #"99"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/price"))
        #expect(value == "\u{20ac}99")
    }

    @Test func valueTrademarkFromEscape() throws {
        // JSON: {"label":"Adapty™"}
        let jsonStr = #"{"label":"Adapty"# + Self.u(0x2122) + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/label"))
        #expect(value == "Adapty\u{2122}")
    }

    @Test func valueArrowFromEscape() throws {
        // JSON: {"direction":"→"}
        let jsonStr = #"{"direction":""# + Self.u(0x2192) + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/direction"))
        #expect(value == "\u{2192}")
    }

    @Test func valueMixedSymbolsFromEscape() throws {
        // JSON: {"symbols":"€™→⚡✪"}
        let escapes = Self.us(0x20ac, 0x2122, 0x2192, 0x26a1, 0x272a)
        let jsonStr = #"{"symbols":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/symbols"))
        #expect(value == "\u{20ac}\u{2122}\u{2192}\u{26a1}\u{272a}")
    }

    // MARK: - Values: different alphabets via \uXXXX

    @Test func valueCyrillicFromEscape() throws {
        // JSON: {"greeting":"Привет"} -> "Привет"
        let escapes = Self.us(0x041f, 0x0440, 0x0438, 0x0432, 0x0435, 0x0442)
        let jsonStr = #"{"greeting":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/greeting"))
        #expect(value == "Привет")
    }

    @Test func valueGreekFromEscape() throws {
        // JSON: {"letters":"αβγ"} -> "αβγ"
        let escapes = Self.us(0x03b1, 0x03b2, 0x03b3)
        let jsonStr = #"{"letters":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/letters"))
        #expect(value == "αβγ")
    }

    @Test func valueHebrewFromEscape() throws {
        // JSON: {"hello":"שלום"} -> "שלום"
        let escapes = Self.us(0x05e9, 0x05dc, 0x05d5, 0x05dd)
        let jsonStr = #"{"hello":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "שלום")
    }

    @Test func valueArmenianFromEscape() throws {
        // JSON: {"letters":"ԱԲԳ"} -> "ԱԲԳ"
        let escapes = Self.us(0x0531, 0x0532, 0x0533)
        let jsonStr = #"{"letters":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/letters"))
        #expect(value == "ԱԲԳ")
    }

    @Test func valueJapaneseHiraganaFromEscape() throws {
        // JSON: {"hello":"こんにちは"} -> "こんにちは"
        let escapes = Self.us(0x3053, 0x3093, 0x306b, 0x3061, 0x306f)
        let jsonStr = #"{"hello":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "こんにちは")
    }

    @Test func valueChineseFromEscape() throws {
        // JSON: {"hello":"你好"} -> "你好"
        let escapes = Self.us(0x4f60, 0x597d)
        let jsonStr = #"{"hello":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "你好")
    }

    @Test func valueKoreanFromEscape() throws {
        // JSON: {"hello":"안녕"} -> "안녕"
        let escapes = Self.us(0xc548, 0xb155)
        let jsonStr = #"{"hello":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "안녕")
    }

    // MARK: - Values: emoji via UTF-16 surrogate pairs

    @Test func valueThumbsUpFromSurrogatePair() throws {
        // JSON: {"reaction":"👍"} -> "👍"
        let escapes = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{"reaction":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/reaction"))
        #expect(value == "\u{1f44d}")
    }

    @Test func valueAllEmojisFromSurrogatePairs() throws {
        // 👍 💖 💬 📈 📝 📺 🔔 🔙 🔥 🔯 🕳 😊 🙂 🌅 🎁 🎯 ⚡ ✪ — all via \u escapes.
        let parts: [String] = [
            Self.us(0xd83d, 0xdc4d), // 👍
            Self.us(0xd83d, 0xdc96), // 💖
            Self.us(0xd83d, 0xdcac), // 💬
            Self.us(0xd83d, 0xdcc8), // 📈
            Self.us(0xd83d, 0xdcdd), // 📝
            Self.us(0xd83d, 0xdcfa), // 📺
            Self.us(0xd83d, 0xdd14), // 🔔
            Self.us(0xd83d, 0xdd19), // 🔙
            Self.us(0xd83d, 0xdd25), // 🔥
            Self.us(0xd83d, 0xdd2f), // 🔯
            Self.us(0xd83d, 0xdd73), // 🕳
            Self.us(0xd83d, 0xde0a), // 😊
            Self.us(0xd83d, 0xde42), // 🙂
            Self.us(0xd83c, 0xdf05), // 🌅
            Self.us(0xd83c, 0xdf81), // 🎁
            Self.us(0xd83c, 0xdfaf), // 🎯
            Self.u(0x26a1),          // ⚡
            Self.u(0x272a),          // ✪
        ]
        let escapes = parts.joined(separator: " ")
        let jsonStr = #"{"line":""# + escapes + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/line"))
        let expected = "\u{1f44d} \u{1f496} \u{1f4ac} \u{1f4c8} \u{1f4dd} \u{1f4fa} \u{1f514} \u{1f519} \u{1f525} \u{1f52f} \u{1f573} \u{1f60a} \u{1f642} \u{1f305} \u{1f381} \u{1f3af} \u{26a1} \u{272a}"
        #expect(value == expected)
    }

    @Test func valueEmojiPerCodePoint() throws {
        // One assertion per emoji so a regression in any single code point is
        // reported separately.
        let cases: [(escaped: String, expected: String)] = [
            (Self.us(0xd83d, 0xdc4d), "\u{1f44d}"), // 👍
            (Self.us(0xd83d, 0xdc96), "\u{1f496}"), // 💖
            (Self.us(0xd83d, 0xdcac), "\u{1f4ac}"), // 💬
            (Self.us(0xd83d, 0xdcc8), "\u{1f4c8}"), // 📈
            (Self.us(0xd83d, 0xdcdd), "\u{1f4dd}"), // 📝
            (Self.us(0xd83d, 0xdcfa), "\u{1f4fa}"), // 📺
            (Self.us(0xd83d, 0xdd14), "\u{1f514}"), // 🔔
            (Self.us(0xd83d, 0xdd19), "\u{1f519}"), // 🔙
            (Self.us(0xd83d, 0xdd25), "\u{1f525}"), // 🔥
            (Self.us(0xd83d, 0xdd2f), "\u{1f52f}"), // 🔯
            (Self.us(0xd83d, 0xdd73), "\u{1f573}"), // 🕳
            (Self.us(0xd83d, 0xde0a), "\u{1f60a}"), // 😊
            (Self.us(0xd83d, 0xde42), "\u{1f642}"), // 🙂
            (Self.us(0xd83c, 0xdf05), "\u{1f305}"), // 🌅
            (Self.us(0xd83c, 0xdf81), "\u{1f381}"), // 🎁
            (Self.us(0xd83c, 0xdfaf), "\u{1f3af}"), // 🎯
            (Self.u(0x26a1), "\u{26a1}"),           // ⚡
            (Self.u(0x272a), "\u{272a}"),           // ✪
        ]

        for (escaped, expected) in cases {
            let jsonStr = #"{"v":""# + escaped + #""}"#
            let json = try #require(jsonStr.data(using: .utf8))
            let value = try Self.decodeString(json.jsonExtract(pointer: "/v"))
            #expect(value == expected, "escaped=\(escaped)")
        }
    }

    // MARK: - Keys with \uXXXX escapes — jsonExtract by unescaped UTF-8 pointer

    // Raw-form contract: pointer must match the byte form of the key as it
    // appears in the source JSON. Below the key is written via \u escapes,
    // so the pointer is built from the same \u escape sequence.

    @Test func extractByPointerForEscapedEuroKey() throws {
        // JSON: {"€":"euro"}
        let escape = Self.u(0x20ac)
        let jsonStr = #"{""# + escape + #"":"euro"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/" + escape))
        #expect(value == "euro")
    }

    @Test func extractByPointerForEscapedTrademarkKey() throws {
        // JSON: {"™":"tm"}
        let escape = Self.u(0x2122)
        let jsonStr = #"{""# + escape + #"":"tm"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/" + escape))
        #expect(value == "tm")
    }

    @Test func extractByPointerForEscapedCyrillicKey() throws {
        // JSON: {"имя":"value"}
        let key = Self.us(0x0438, 0x043c, 0x044f)
        let jsonStr = #"{""# + key + #"":"value"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/" + key))
        #expect(value == "value")
    }

    @Test func extractByPointerForEscapedEmojiKey() throws {
        // JSON: {"👍":"liked"}
        let key = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{""# + key + #"":"liked"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/" + key))
        #expect(value == "liked")
    }

    @Test func extractByPointerForEscapedJapaneseKey() throws {
        // JSON: {"こんにちは":"greeting"}
        let key = Self.us(0x3053, 0x3093, 0x306b, 0x3061, 0x306f)
        let jsonStr = #"{""# + key + #"":"greeting"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/" + key))
        #expect(value == "greeting")
    }

    @Test func extractByPointerForEscapedChineseKey() throws {
        // JSON: {"你好":"hi"}
        let key = Self.us(0x4f60, 0x597d)
        let jsonStr = #"{""# + key + #"":"hi"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/" + key))
        #expect(value == "hi")
    }

    // MARK: - Keys with \uXXXX escapes — jsonContains / jsonExist

    @Test func containsAndExistForEscapedKeys() throws {
        // JSON: {"€":1,"™":2,"👍":3} — keys via \u escapes,
        // pointers use the same escape form.
        let k1 = Self.u(0x20ac)
        let k2 = Self.u(0x2122)
        let k3 = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{""# + k1 + #"":1,""# + k2 + #"":2,""# + k3 + #"":3}"#
        let json = try #require(jsonStr.data(using: .utf8))

        #expect(try json.jsonContains(pointer: "/" + k1) == true)
        #expect(try json.jsonContains(pointer: "/" + k2) == true)
        #expect(try json.jsonContains(pointer: "/" + k3) == true)

        #expect(try json.jsonExist(pointer: "/" + k1) == true)
        #expect(try json.jsonExist(pointer: "/" + k2) == true)
        #expect(try json.jsonExist(pointer: "/" + k3) == true)

        #expect(try json.jsonContains(pointer: "/missing") == false)
    }

    // MARK: - Keys with \uXXXX escapes — jsonInspect must return un-escaped keys

    @Test func inspectKeysReturnRawForm() throws {
        // Per the raw-form contract, jsonInspect returns keys byte-for-byte as
        // they appear in the source JSON — so when keys are written via \u
        // escapes, the returned strings are the same \u escape sequences (not
        // the un-escaped UTF-8 form).
        // JSON: {"€":1,"™":2,"→":3,"👍":4,"имя":5}
        let k1 = Self.u(0x20ac)
        let k2 = Self.u(0x2122)
        let k3 = Self.u(0x2192)
        let k4 = Self.us(0xd83d, 0xdc4d)
        let k5 = Self.us(0x0438, 0x043c, 0x044f)
        let jsonStr = #"{""# + k1 + #"":1,""# + k2 + #"":2,""# + k3 + #"":3,""# + k4 + #"":4,""# + k5 + #"":5}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let info = try json.jsonInspect(pointer: "")

        guard case let .object(keys) = info else {
            Issue.record("Expected an object, got \(info)")
            return
        }

        #expect(Set(keys) == Set([k1, k2, k3, k4, k5]))

        // The returned raw keys round-trip back into pointers that find the
        // same values without any transformation.
        for k in keys {
            #expect(try json.jsonContains(pointer: "/" + k) == true,
                    "round-trip pointer should find key \(k)")
        }
    }

    // MARK: - Keys with \uXXXX escapes — jsonExtractRange

    @Test func rangeForEscapedEuroKey() throws {
        // JSON: {"€":"euro"} — pointer in the same escape form.
        let escape = Self.u(0x20ac)
        let jsonStr = #"{""# + escape + #"":"euro"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/" + escape)

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        // The raw key as it appears in the source JSON — the \u escape
        // preserved verbatim, 6 ASCII characters.
        #expect(key == escape)

        let value = try #require(result.value(from: jsonStr))
        #expect(value == #""euro""#)
    }

    @Test func rangeForEscapedEmojiKey() throws {
        // JSON: {"👍":"liked"}
        let escape = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{""# + escape + #"":"liked"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/" + escape)

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        #expect(key == escape)

        let value = try #require(result.value(from: jsonStr))
        #expect(value == #""liked""#)
    }

    @Test func rangeForEscapedCyrillicKey() throws {
        // JSON: {"имя":"value"}
        let escape = Self.us(0x0438, 0x043c, 0x044f)
        let jsonStr = #"{""# + escape + #"":"value"}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/" + escape)

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        #expect(key == escape)

        let value = try #require(result.value(from: jsonStr))
        #expect(value == #""value""#)
    }

    // MARK: - Escaped values via jsonExtractRange — value substring stays raw

    @Test func rangeForEscapedValueKeepsRawForm() throws {
        // JSON: {"k":"€"}
        let escape = Self.u(0x20ac)
        let jsonStr = #"{"k":""# + escape + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/k")

        let value = try #require(result.value(from: jsonStr))
        // Raw value substring includes surrounding quotes and the escape verbatim.
        #expect(value == #"""# + escape + #"""#)
    }

    @Test func rangeForEscapedSurrogatePairValueKeepsRawForm() throws {
        // JSON: {"k":"👍"}
        let escape = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{"k":""# + escape + #""}"#
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/k")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == #"""# + escape + #"""#)
    }

    // MARK: - Batch extraction with escaped keys

    @Test func extractManyWithEscapedKeys() throws {
        // JSON: {"€":"euro","👍":"liked"} — pointers in matching escape form.
        let k1 = Self.u(0x20ac)
        let k2 = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{""# + k1 + #"":"euro",""# + k2 + #"":"liked"}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let p1 = "/" + k1
        let p2 = "/" + k2
        let results = try json.jsonExtractMany(pointers: [p1, p2])
        #expect(results.count == 2)

        let euro = try Self.decodeString(#require(results[p1]))
        #expect(euro == "euro")

        let liked = try Self.decodeString(#require(results[p2]))
        #expect(liked == "liked")
    }

    // MARK: - Nested escaped keys

    @Test func nestedEscapedKeyPath() throws {
        // JSON: {"outer":{"€":{"inner":"💖"}}} — middle segment in escape form,
        // so the pointer uses the same escape form for that segment.
        let middleKey = Self.u(0x20ac)
        let value = Self.us(0xd83d, 0xdc96)
        let jsonStr = #"{"outer":{""# + middleKey + #"":{"inner":""# + value + #""}}}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let pointer = "/outer/" + middleKey + "/inner"

        let extracted = try Self.decodeString(json.jsonExtract(pointer: pointer))
        #expect(extracted == "\u{1f496}")

        #expect(try json.jsonContains(pointer: pointer) == true)
        #expect(try json.jsonExist(pointer: pointer) == true)
    }

    // MARK: - jsonFastInspect on escaped values

    @Test func fastInspectClassifiesEscapedValues() throws {
        // JSON: {"€":"text","arr":["€"],"num":42} — top-level key in escape
        // form, so pointer addresses it via the same escape form.
        let key = Self.u(0x20ac)
        let arrElement = Self.u(0x20ac)
        let jsonStr = #"{""# + key + #"":"text","arr":[""# + arrElement + #""],"num":42}"#
        let json = try #require(jsonStr.data(using: .utf8))

        #expect(try json.jsonFastInspect(pointer: "/" + key) == .string)
        #expect(try json.jsonFastInspect(pointer: "/arr") == .array(count: 0))
        #expect(try json.jsonFastInspect(pointer: "/arr/0") == .string)
        #expect(try json.jsonFastInspect(pointer: "/num") == .number)
    }
}
