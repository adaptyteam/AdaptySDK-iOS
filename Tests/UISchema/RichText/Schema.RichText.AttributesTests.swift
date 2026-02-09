//
//  Schema.RichText.AttributesTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

import Testing

@testable import AdaptyUIBuilder

private extension SchemaTests.RichTextTests {
    @Suite("Schema.RichText.Attributes Tests")
    struct AttributesTests {
        typealias Value = Schema.RichText.Attributes

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Empty object — all nil
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"{}"##)
            ),
            // Font only
            (
                Value(
                    fontAssetId: "custom_font",
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "font": "custom_font"
                }
                """##)
            ),
            // Size — integer
            (
                Value(
                    fontAssetId: nil,
                    size: 16,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "size": 16
                }
                """##)
            ),
            // Size — decimal
            (
                Value(
                    fontAssetId: nil,
                    size: 12.5,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "size": 12.5
                }
                """##)
            ),
            // Text color only
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: .assetId("text_color"),
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "color": "text_color"
                }
                """##)
            ),
            // Image tint color only
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: .assetId("icon_tint"),
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "tint": "icon_tint"
                }
                """##)
            ),
            // Background only
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: .assetId("highlight_color"),
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "background": "highlight_color"
                }
                """##)
            ),
            // Strike true
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: true,
                    underline: nil
                ),
                Json(##"""
                {
                    "strike": true
                }
                """##)
            ),
            // Strike false
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: false,
                    underline: nil
                ),
                Json(##"""
                {
                    "strike": false
                }
                """##)
            ),
            // Underline true
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: true
                ),
                Json(##"""
                {
                    "underline": true
                }
                """##)
            ),
            // Underline false
            (
                Value(
                    fontAssetId: nil,
                    size: nil,
                    txtColor: nil,
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: false
                ),
                Json(##"""
                {
                    "underline": false
                }
                """##)
            ),
            // Partial — font + size + color
            (
                Value(
                    fontAssetId: "custom_font",
                    size: 16,
                    txtColor: .assetId("text_color"),
                    imageTintColor: nil,
                    background: nil,
                    strike: nil,
                    underline: nil
                ),
                Json(##"""
                {
                    "font": "custom_font",
                    "size": 16,
                    "color": "text_color"
                }
                """##)
            ),
            // Full — all properties
            (
                Value(
                    fontAssetId: "custom_font",
                    size: 24,
                    txtColor: .assetId("text_color"),
                    imageTintColor: .assetId("icon_tint"),
                    background: .assetId("highlight_color"),
                    strike: true,
                    underline: true
                ),
                Json(##"""
                {
                    "font": "custom_font",
                    "size": 24,
                    "color": "text_color",
                    "tint": "icon_tint",
                    "background": "highlight_color",
                    "strike": true,
                    "underline": true
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Not an object (string)
            Json(##""hello""##),
            // Not an object (number)
            Json(##"123"##),
            // Not an object (array)
            Json(##"[1, 2]"##),
            // Size as string
            Json(##"{"size": "big"}"##),
            // Strike as string
            Json(##"{"strike": "yes"}"##),
            // Font as number
            Json(##"{"font": 123}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid attributes", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
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
            let obj = try #require(encoded.deserilized as? [String: Any])

            if let assetId = value.fontAssetId {
                #expect((obj["font"] as? String) == assetId)
            } else {
                #expect(obj["font"] == nil)
            }

            if let size = value.size {
                #expect(obj["size"] as? Double == size)
            } else {
                #expect(obj["size"] == nil)
            }

            if value.txtColor != nil {
                #expect(obj["color"] != nil)
            } else {
                #expect(obj["color"] == nil)
            }

            if value.imageTintColor != nil {
                #expect(obj["tint"] != nil)
            } else {
                #expect(obj["tint"] == nil)
            }

            if value.background != nil {
                #expect(obj["background"] != nil)
            } else {
                #expect(obj["background"] == nil)
            }

            if let strike = value.strike {
                #expect(obj["strike"] as? Bool == strike)
            } else {
                #expect(obj["strike"] == nil)
            }

            if let underline = value.underline {
                #expect(obj["underline"] as? Bool == underline)
            } else {
                #expect(obj["underline"] == nil)
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
