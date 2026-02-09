//
//  Schema.RichText.ItemTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

import Testing

@testable import AdaptyUIBuilder

private extension SchemaTests.RichTextTests {
    @Suite("Schema.RichText.Item Tests")
    struct ItemTests {
        typealias Value = Schema.RichText.Item
        typealias Attributes = Schema.RichText.Attributes

        // MARK: - Helpers

        static let attrsWithColor = Attributes(
            fontAssetId: nil, size: nil, txtColor: .assetId("red"),
            imageTintColor: nil, background: nil, strike: nil, underline: nil
        )

        static let attrsWithSize = Attributes(
            fontAssetId: nil, size: 14, txtColor: nil,
            imageTintColor: nil, background: nil, strike: nil, underline: nil
        )

        static let attrsWithTint = Attributes(
            fontAssetId: nil, size: nil, txtColor: nil,
            imageTintColor: .assetId("tint_color"), background: nil, strike: nil, underline: nil
        )

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Text — plain string
            (
                .text("Hello", nil),
                Json(##""Hello""##)
            ),
            // Text — empty string
            (
                .text("", nil),
                Json(##""""##)
            ),
            // Text — with attributes
            (
                .text("styled", attrsWithColor),
                Json(##"""
                {
                    "text": "styled",
                    "attributes": {
                        "color": "red"
                    }
                }
                """##)
            ),
            // Tag — without attributes
            (
                .tag("price", nil),
                Json(##"""
                {
                    "tag": "price"
                }
                """##)
            ),
            // Tag — with attributes
            (
                .tag("product_name", attrsWithSize),
                Json(##"""
                {
                    "tag": "product_name",
                    "attributes": {
                        "size": 14
                    }
                }
                """##)
            ),
            // Image — without attributes
            (
                .image(.assetId("icon_asset"), nil),
                Json(##"""
                {
                    "image": "icon_asset"
                }
                """##)
            ),
            // Image — with attributes
            (
                .image(.assetId("icon"), attrsWithTint),
                Json(##"""
                {
                    "image": "icon",
                    "attributes": {
                        "tint": "tint_color"
                    }
                }
                """##)
            ),
        ]

        // Text as object — decodes correctly, encodes back as plain string
        static let textObjectJsonCases: [(value: Value, json: Json)] = [
            // Text as object without attributes
            (
                .text("Hello", nil),
                Json(##"""
                {
                    "text": "Hello"
                }
                """##)
            ),
        ]

        // Unknown — decoded from object without known keys
        static let unknownJsonCases: [(value: Value, json: Json)] = [
            // Empty object
            (.unknown, Json(##"{}"##)),
            // Object with unrecognized keys only
            (.unknown, Json(##"""
            {
                "foo": "bar"
            }
            """##)),
        ]

        static let invalidJsons: [Json] = [
            // Number
            Json(##"123"##),
            // Boolean
            Json(##"true"##),
            // Array
            Json(##"[1, 2]"##),
            // Null
            Json(##"null"##),
            // Text key with wrong type
            Json(##"{"text": 123}"##),
            // Tag key with wrong type
            Json(##"{"tag": true}"##),
            // Image key with wrong type
            Json(##"{"image": 123}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid item", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode text object format", arguments: textObjectJsonCases)
        func decodeTextObject(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode unknown item", arguments: unknownJsonCases)
        func decodeUnknown(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode produces correct structure", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            switch value {
            case let .text(text, attributes):
                if attributes != nil {
                    let obj = try #require(encoded.deserilized as? [String: Any])
                    #expect(obj["text"] as? String == text)
                    #expect(obj["attributes"] is [String: Any])
                } else {
                    let str = try #require(encoded.deserilized as? String)
                    #expect(str == text)
                }
            case let .tag(tag, attributes):
                let obj = try #require(encoded.deserilized as? [String: Any])
                #expect(obj["tag"] as? String == tag)
                if attributes != nil {
                    #expect(obj["attributes"] is [String: Any])
                } else {
                    #expect(obj["attributes"] == nil)
                }
            case let .image(_, attributes):
                let obj = try #require(encoded.deserilized as? [String: Any])
                #expect(obj["image"] != nil)
                if attributes != nil {
                    #expect(obj["attributes"] is [String: Any])
                } else {
                    #expect(obj["attributes"] == nil)
                }
            case .unknown:
                break
            }
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
