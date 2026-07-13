//
//  JsonPointerSegmentTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 28.05.2026.
//

@testable import AdaptyCodable
import Foundation
import Testing

struct JsonPointerSegmentTests {
    /// Returns the literal `\uXXXX` sequence (6 ASCII chars) for a single
    /// UTF-16 code unit. Built from raw byte 0x5c so no Swift backslash
    /// literal appears in source.
    private static func u(_ code: UInt16) -> String {
        let reverseSolidus = String(UnicodeScalar(0x5c as UInt8))
        return reverseSolidus + "u" + String(format: "%04x", code)
    }

    private static func us(_ codes: UInt16...) -> String {
        codes.map { Self.u($0) }.joined()
    }

    private static func decodeString(_ data: Data) throws -> String {
        try JSONDecoder().decode(String.self, from: data)
    }

    // MARK: - ASCII pass-through

    @Test func emptyString() {
        #expect("".jsonPointerSegment == "")
    }

    @Test func plainAsciiPassesThrough() {
        #expect("name".jsonPointerSegment == "name")
        #expect("placement_id_42".jsonPointerSegment == "placement_id_42")
        #expect("AbcXYZ012".jsonPointerSegment == "AbcXYZ012")
    }

    @Test func asciiPunctuationPassesThrough() {
        // Everything ASCII except '/' and '~'
        #expect(" !\"#$%&'()*+,-.".jsonPointerSegment == " !\"#$%&'()*+,-.")
        #expect("0123456789:;<=>?".jsonPointerSegment == "0123456789:;<=>?")
        #expect("[\\]^_`".jsonPointerSegment == "[\\]^_`")
        #expect("{|}".jsonPointerSegment == "{|}")
    }

    // MARK: - RFC 6901 escapes

    @Test func slashIsEscapedToTilde1() {
        #expect("/".jsonPointerSegment == "~1")
        #expect("a/b".jsonPointerSegment == "a~1b")
        #expect("///".jsonPointerSegment == "~1~1~1")
    }

    @Test func tildeIsEscapedToTilde0() {
        #expect("~".jsonPointerSegment == "~0")
        #expect("a~b".jsonPointerSegment == "a~0b")
        #expect("~~".jsonPointerSegment == "~0~0")
    }

    @Test func slashAndTildeOrderPreserved() {
        // RFC 6901 says encode tilde first when escaping; the result must be
        // unambiguous either way at decode time. We verify both inputs come
        // out as expected.
        #expect("~/".jsonPointerSegment == "~0~1")
        #expect("/~".jsonPointerSegment == "~1~0")
        #expect("a~1b/c".jsonPointerSegment == "a~01b~1c") // literal ~1 in name
    }

    // MARK: - BMP non-ASCII -> single \uXXXX

    @Test func euroSign() {
        #expect("\u{20ac}".jsonPointerSegment == Self.u(0x20ac))
    }

    @Test func trademark() {
        #expect("\u{2122}".jsonPointerSegment == Self.u(0x2122))
    }

    @Test func arrow() {
        #expect("\u{2192}".jsonPointerSegment == Self.u(0x2192))
    }

    @Test func cyrillic() {
        // "имя"
        #expect("имя".jsonPointerSegment == Self.us(0x0438, 0x043c, 0x044f))
    }

    @Test func greek() {
        #expect("αβγ".jsonPointerSegment == Self.us(0x03b1, 0x03b2, 0x03b3))
    }

    @Test func japaneseHiragana() {
        #expect("こんにちは".jsonPointerSegment == Self.us(0x3053, 0x3093, 0x306b, 0x3061, 0x306f))
    }

    @Test func chinese() {
        #expect("你好".jsonPointerSegment == Self.us(0x4f60, 0x597d))
    }

    @Test func korean() {
        #expect("안녕".jsonPointerSegment == Self.us(0xc548, 0xb155))
    }

    // MARK: - Supplementary plane -> UTF-16 surrogate pair

    @Test func thumbsUpAsSurrogatePair() {
        // 👍 = U+1F44D -> 👍
        #expect("\u{1f44d}".jsonPointerSegment == Self.us(0xd83d, 0xdc4d))
    }

    @Test func emojiPerCodePoint() {
        let cases: [(input: String, expected: String)] = [
            ("\u{1f44d}", Self.us(0xd83d, 0xdc4d)), // 👍
            ("\u{1f496}", Self.us(0xd83d, 0xdc96)), // 💖
            ("\u{1f4ac}", Self.us(0xd83d, 0xdcac)), // 💬
            ("\u{1f4c8}", Self.us(0xd83d, 0xdcc8)), // 📈
            ("\u{1f4dd}", Self.us(0xd83d, 0xdcdd)), // 📝
            ("\u{1f4fa}", Self.us(0xd83d, 0xdcfa)), // 📺
            ("\u{1f514}", Self.us(0xd83d, 0xdd14)), // 🔔
            ("\u{1f519}", Self.us(0xd83d, 0xdd19)), // 🔙
            ("\u{1f525}", Self.us(0xd83d, 0xdd25)), // 🔥
            ("\u{1f52f}", Self.us(0xd83d, 0xdd2f)), // 🔯
            ("\u{1f573}", Self.us(0xd83d, 0xdd73)), // 🕳
            ("\u{1f60a}", Self.us(0xd83d, 0xde0a)), // 😊
            ("\u{1f642}", Self.us(0xd83d, 0xde42)), // 🙂
            ("\u{1f305}", Self.us(0xd83c, 0xdf05)), // 🌅
            ("\u{1f381}", Self.us(0xd83c, 0xdf81)), // 🎁
            ("\u{1f3af}", Self.us(0xd83c, 0xdfaf)), // 🎯
            // BMP — single escape
            ("\u{26a1}", Self.u(0x26a1)), // ⚡
            ("\u{272a}", Self.u(0x272a)), // ✪
        ]

        for (input, expected) in cases {
            #expect(input.jsonPointerSegment == expected,
                    "input=\(input)")
        }
    }

    // MARK: - Boundary code points around the BMP / supplementary split

    @Test func boundaries() {
        // U+0080 — smallest non-ASCII, just above ASCII range.
        #expect("\u{0080}".jsonPointerSegment == Self.u(0x0080))
        // U+FFFF — largest single-unit BMP value.
        #expect("\u{ffff}".jsonPointerSegment == Self.u(0xffff))
        // U+10000 — smallest supplementary, becomes 𐀀.
        #expect("\u{10000}".jsonPointerSegment == Self.us(0xd800, 0xdc00))
        // U+10FFFF — largest valid code point, becomes 􏿿.
        #expect("\u{10ffff}".jsonPointerSegment == Self.us(0xdbff, 0xdfff))
    }

    // MARK: - Mixed strings

    @Test func mixedAsciiAndUnicode() {
        // "price_€_99" -> "price_€_99"
        let expected = "price_" + Self.u(0x20ac) + "_99"
        #expect("price_\u{20ac}_99".jsonPointerSegment == expected)
    }

    @Test func mixedRfcAndUnicode() {
        // "a/€~b" -> "a~1€~0b"
        let expected = "a~1" + Self.u(0x20ac) + "~0b"
        #expect("a/\u{20ac}~b".jsonPointerSegment == expected)
    }

    @Test func mixedAsciiBmpAndSurrogate() {
        // "Hi 👍 ™" -> "Hi 👍 ™"
        let expected = "Hi " + Self.us(0xd83d, 0xdc4d) + " " + Self.u(0x2122)
        #expect("Hi \u{1f44d} \u{2122}".jsonPointerSegment == expected)
    }

    // MARK: - Round-trip: build pointer, extract value from escape-form JSON

    @Test func roundTripWithEscapedEuroKey() throws {
        // JSON contains the key as a \u escape; we form the pointer from the
        // user-facing UTF-8 name and verify extract succeeds.
        let keyEscaped = Self.u(0x20ac)
        let jsonStr = #"{""# + keyEscaped + #"":"euro"}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let userKey = "\u{20ac}" // €
        let pointer = "/" + userKey.jsonPointerSegment
        let value = try Self.decodeString(json.jsonExtract(pointer: pointer))
        #expect(value == "euro")
    }

    @Test func roundTripWithEscapedEmojiKey() throws {
        let keyEscaped = Self.us(0xd83d, 0xdc4d)
        let jsonStr = #"{""# + keyEscaped + #"":"liked"}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let userKey = "\u{1f44d}" // 👍
        let pointer = "/" + userKey.jsonPointerSegment
        let value = try Self.decodeString(json.jsonExtract(pointer: pointer))
        #expect(value == "liked")
    }

    @Test func roundTripNestedEscapedPath() throws {
        // JSON: {"outer":{"€":{"items":["a","💖"]}}}
        let middle = Self.u(0x20ac)
        let item = Self.us(0xd83d, 0xdc96)
        let jsonStr = #"{"outer":{""# + middle + #"":{"items":["a",""# + item + #""]}}}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let pointer = "/outer/" + "\u{20ac}".jsonPointerSegment + "/items/1"
        let value = try Self.decodeString(json.jsonExtract(pointer: pointer))
        #expect(value == "\u{1f496}")
    }

    @Test func roundTripWithSlashInKey() throws {
        // JSON key contains a literal slash, written as UTF-8 (no \u needed).
        // We use jsonPointerSegment which escapes / to ~1 — pointer-side escape
        // is independent of how the key is stored in JSON.
        let jsonStr = #"{"path/to/key":"value"}"#
        let json = try #require(jsonStr.data(using: .utf8))

        let pointer = "/" + "path/to/key".jsonPointerSegment
        #expect(pointer == "/path~1to~1key")
        let value = try Self.decodeString(json.jsonExtract(pointer: pointer))
        #expect(value == "value")
    }
}
