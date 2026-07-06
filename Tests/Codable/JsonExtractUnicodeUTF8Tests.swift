//
//  JsonExtractUnicodeUTF8Tests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 28.05.2026.
//
//  Mirror of `JsonExtractUnicodeEscapeTests` but every non-ASCII character
//  inside the JSON is written as the raw UTF-8 byte sequence — not as a
//  JSON `\uXXXX` escape. Comparing pass/fail of both files isolates the
//  effect of `\u` escapes from the effect of the Unicode characters
//  themselves.
//

@testable import AdaptyCodable
import Foundation
import Testing

struct JsonExtractUnicodeUTF8Tests {
    // MARK: - Helpers

    private static func decodeString(_ data: Data) throws -> String {
        try JSONDecoder().decode(String.self, from: data)
    }

    // MARK: - Values: BMP characters as UTF-8

    @Test func valueEuroSign() throws {
        // JSON: {"price":"€99"}  ← € is the literal UTF-8 sequence
        let jsonStr = "{\"price\":\"\u{20ac}99\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/price"))
        #expect(value == "\u{20ac}99")
    }

    @Test func valueTrademark() throws {
        // JSON: {"label":"Adapty™"}
        let jsonStr = "{\"label\":\"Adapty\u{2122}\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/label"))
        #expect(value == "Adapty\u{2122}")
    }

    @Test func valueArrow() throws {
        let jsonStr = "{\"direction\":\"\u{2192}\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/direction"))
        #expect(value == "\u{2192}")
    }

    @Test func valueMixedSymbols() throws {
        let jsonStr = "{\"symbols\":\"\u{20ac}\u{2122}\u{2192}\u{26a1}\u{272a}\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/symbols"))
        #expect(value == "\u{20ac}\u{2122}\u{2192}\u{26a1}\u{272a}")
    }

    // MARK: - Values: different alphabets as UTF-8

    @Test func valueCyrillic() throws {
        let jsonStr = "{\"greeting\":\"Привет\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/greeting"))
        #expect(value == "Привет")
    }

    @Test func valueGreek() throws {
        let jsonStr = "{\"letters\":\"αβγ\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/letters"))
        #expect(value == "αβγ")
    }

    @Test func valueHebrew() throws {
        let jsonStr = "{\"hello\":\"שלום\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "שלום")
    }

    @Test func valueArmenian() throws {
        let jsonStr = "{\"letters\":\"ԱԲԳ\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/letters"))
        #expect(value == "ԱԲԳ")
    }

    @Test func valueJapaneseHiragana() throws {
        let jsonStr = "{\"hello\":\"こんにちは\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "こんにちは")
    }

    @Test func valueChinese() throws {
        let jsonStr = "{\"hello\":\"你好\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "你好")
    }

    @Test func valueKorean() throws {
        let jsonStr = "{\"hello\":\"안녕\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/hello"))
        #expect(value == "안녕")
    }

    // MARK: - Values: emoji as UTF-8 (no surrogate pairs)

    @Test func valueThumbsUp() throws {
        let jsonStr = "{\"reaction\":\"\u{1f44d}\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/reaction"))
        #expect(value == "\u{1f44d}")
    }

    @Test func valueAllEmojis() throws {
        // 👍 💖 💬 📈 📝 📺 🔔 🔙 🔥 🔯 🕳 😊 🙂 🌅 🎁 🎯 ⚡ ✪
        let line = "\u{1f44d} \u{1f496} \u{1f4ac} \u{1f4c8} \u{1f4dd} \u{1f4fa} \u{1f514} \u{1f519} \u{1f525} \u{1f52f} \u{1f573} \u{1f60a} \u{1f642} \u{1f305} \u{1f381} \u{1f3af} \u{26a1} \u{272a}"
        let jsonStr = "{\"line\":\"\(line)\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/line"))
        #expect(value == line)
    }

    @Test func valueEmojiPerCodePoint() throws {
        let codepoints: [(scalar: Unicode.Scalar, expected: String)] = [
            (Unicode.Scalar(0x1f44d)!, "\u{1f44d}"),
            (Unicode.Scalar(0x1f496)!, "\u{1f496}"),
            (Unicode.Scalar(0x1f4ac)!, "\u{1f4ac}"),
            (Unicode.Scalar(0x1f4c8)!, "\u{1f4c8}"),
            (Unicode.Scalar(0x1f4dd)!, "\u{1f4dd}"),
            (Unicode.Scalar(0x1f4fa)!, "\u{1f4fa}"),
            (Unicode.Scalar(0x1f514)!, "\u{1f514}"),
            (Unicode.Scalar(0x1f519)!, "\u{1f519}"),
            (Unicode.Scalar(0x1f525)!, "\u{1f525}"),
            (Unicode.Scalar(0x1f52f)!, "\u{1f52f}"),
            (Unicode.Scalar(0x1f573)!, "\u{1f573}"),
            (Unicode.Scalar(0x1f60a)!, "\u{1f60a}"),
            (Unicode.Scalar(0x1f642)!, "\u{1f642}"),
            (Unicode.Scalar(0x1f305)!, "\u{1f305}"),
            (Unicode.Scalar(0x1f381)!, "\u{1f381}"),
            (Unicode.Scalar(0x1f3af)!, "\u{1f3af}"),
            (Unicode.Scalar(0x26a1)!, "\u{26a1}"),
            (Unicode.Scalar(0x272a)!, "\u{272a}"),
        ]

        for (scalar, expected) in codepoints {
            let ch = String(scalar)
            let jsonStr = "{\"v\":\"\(ch)\"}"
            let json = try #require(jsonStr.data(using: .utf8))
            let value = try Self.decodeString(json.jsonExtract(pointer: "/v"))
            #expect(value == expected, "scalar=\(scalar)")
        }
    }

    // MARK: - Keys as UTF-8 — jsonExtract by UTF-8 pointer

    @Test func extractByPointerForEuroKey() throws {
        let jsonStr = "{\"\u{20ac}\":\"euro\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/\u{20ac}"))
        #expect(value == "euro")
    }

    @Test func extractByPointerForTrademarkKey() throws {
        let jsonStr = "{\"\u{2122}\":\"tm\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/\u{2122}"))
        #expect(value == "tm")
    }

    @Test func extractByPointerForCyrillicKey() throws {
        let jsonStr = "{\"имя\":\"value\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/имя"))
        #expect(value == "value")
    }

    @Test func extractByPointerForEmojiKey() throws {
        let jsonStr = "{\"\u{1f44d}\":\"liked\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/\u{1f44d}"))
        #expect(value == "liked")
    }

    @Test func extractByPointerForJapaneseKey() throws {
        let jsonStr = "{\"こんにちは\":\"greeting\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/こんにちは"))
        #expect(value == "greeting")
    }

    @Test func extractByPointerForChineseKey() throws {
        let jsonStr = "{\"你好\":\"hi\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let value = try Self.decodeString(json.jsonExtract(pointer: "/你好"))
        #expect(value == "hi")
    }

    // MARK: - Keys as UTF-8 — jsonContains / jsonExist

    @Test func containsAndExistForKeys() throws {
        let jsonStr = "{\"\u{20ac}\":1,\"\u{2122}\":2,\"\u{1f44d}\":3}"
        let json = try #require(jsonStr.data(using: .utf8))

        #expect(try json.jsonContains(pointer: "/\u{20ac}") == true)
        #expect(try json.jsonContains(pointer: "/\u{2122}") == true)
        #expect(try json.jsonContains(pointer: "/\u{1f44d}") == true)

        #expect(try json.jsonExist(pointer: "/\u{20ac}") == true)
        #expect(try json.jsonExist(pointer: "/\u{2122}") == true)
        #expect(try json.jsonExist(pointer: "/\u{1f44d}") == true)

        #expect(try json.jsonContains(pointer: "/missing") == false)
    }

    // MARK: - Keys as UTF-8 — jsonInspect

    @Test func inspectKeys() throws {
        let jsonStr = "{\"\u{20ac}\":1,\"\u{2122}\":2,\"\u{2192}\":3,\"\u{1f44d}\":4,\"имя\":5}"
        let json = try #require(jsonStr.data(using: .utf8))
        let info = try json.jsonInspect(pointer: "")

        guard case let .object(keys) = info else {
            Issue.record("Expected an object, got \(info)")
            return
        }

        #expect(Set(keys) == Set(["\u{20ac}", "\u{2122}", "\u{2192}", "\u{1f44d}", "имя"]))
    }

    // MARK: - Keys as UTF-8 — jsonExtractRange

    @Test func rangeForEuroKey() throws {
        let jsonStr = "{\"\u{20ac}\":\"euro\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/\u{20ac}")

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        #expect(key == "\u{20ac}")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == "\"euro\"")
    }

    @Test func rangeForEmojiKey() throws {
        let jsonStr = "{\"\u{1f44d}\":\"liked\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/\u{1f44d}")

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        #expect(key == "\u{1f44d}")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == "\"liked\"")
    }

    @Test func rangeForCyrillicKey() throws {
        let jsonStr = "{\"имя\":\"value\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/имя")

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        #expect(key == "имя")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == "\"value\"")
    }

    // MARK: - Range over UTF-8 values

    @Test func rangeForValueKeepsRawForm() throws {
        let jsonStr = "{\"k\":\"\u{20ac}\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/k")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == "\"\u{20ac}\"")
    }

    @Test func rangeForSurrogatePairValueKeepsRawForm() throws {
        let jsonStr = "{\"k\":\"\u{1f44d}\"}"
        let json = try #require(jsonStr.data(using: .utf8))
        let result = try json.jsonExtractRange(pointer: "/k")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == "\"\u{1f44d}\"")
    }

    // MARK: - Batch extraction with UTF-8 keys

    @Test func extractManyWithKeys() throws {
        let jsonStr = "{\"\u{20ac}\":\"euro\",\"\u{1f44d}\":\"liked\"}"
        let json = try #require(jsonStr.data(using: .utf8))

        let results = try json.jsonExtractMany(pointers: ["/\u{20ac}", "/\u{1f44d}"])
        #expect(results.count == 2)

        let euro = try Self.decodeString(#require(results["/\u{20ac}"]))
        #expect(euro == "euro")

        let liked = try Self.decodeString(#require(results["/\u{1f44d}"]))
        #expect(liked == "liked")
    }

    // MARK: - Nested UTF-8 keys

    @Test func nestedKeyPath() throws {
        let jsonStr = "{\"outer\":{\"\u{20ac}\":{\"inner\":\"\u{1f496}\"}}}"
        let json = try #require(jsonStr.data(using: .utf8))

        let extracted = try Self.decodeString(
            json.jsonExtract(pointer: "/outer/\u{20ac}/inner")
        )
        #expect(extracted == "\u{1f496}")

        #expect(try json.jsonContains(pointer: "/outer/\u{20ac}/inner") == true)
        #expect(try json.jsonExist(pointer: "/outer/\u{20ac}/inner") == true)
    }

    // MARK: - jsonFastInspect on UTF-8 values

    @Test func fastInspectClassifiesValues() throws {
        let jsonStr = "{\"\u{20ac}\":\"text\",\"arr\":[\"\u{20ac}\"],\"num\":42}"
        let json = try #require(jsonStr.data(using: .utf8))

        #expect(try json.jsonFastInspect(pointer: "/\u{20ac}") == .string)
        #expect(try json.jsonFastInspect(pointer: "/arr") == .array(count: 0))
        #expect(try json.jsonFastInspect(pointer: "/arr/0") == .string)
        #expect(try json.jsonFastInspect(pointer: "/num") == .number)
    }
}
