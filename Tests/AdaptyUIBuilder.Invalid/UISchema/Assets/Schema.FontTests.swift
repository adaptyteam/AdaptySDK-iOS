//
//  Schema.FontTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    struct FontTests {
        typealias Value = Schema.Font

        // MARK: - Helpers

        static let defaultFontColor = Schema.Color(customId: nil, data: 0x000000FF)
        static let color_FF0000 = Schema.Color(customId: nil, data: 0xFF0000FF)

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Minimal font — only value, all defaults
            (
                Value(
                    customId: nil,
                    alias: "Helvetica",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Helvetica"
                }
                """##)
            ),
            // Full font — all properties set
            (
                Value(
                    customId: "my_font",
                    alias: "Roboto",
                    familyName: "Roboto",
                    weight: 700,
                    italic: true,
                    defaultSize: 24,
                    defaultColor: color_FF0000,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "custom_id": "my_font",
                    "value": "Roboto",
                    "family_name": "Roboto",
                    "weight": 700,
                    "italic": true,
                    "size": 24,
                    "color": "#FF0000"
                }
                """##)
            ),
            // value as array — takes first element
            (
                Value(
                    customId: nil,
                    alias: "Helvetica",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": ["Helvetica", "Arial"]
                }
                """##)
            ),
            // family_name as array — takes first element
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "CustomFont",
                    weight: 400,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "family_name": ["CustomFont", "Fallback"]
                }
                """##)
            ),
            // custom_id only
            (
                Value(
                    customId: "font1",
                    alias: "Arial",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "custom_id": "font1"
                }
                """##)
            ),
            // family_name as string
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "Roboto",
                    weight: 400,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "family_name": "Roboto"
                }
                """##)
            ),
            // weight
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "adapty_system",
                    weight: 700,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "weight": 700
                }
                """##)
            ),
            // italic
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: true,
                    defaultSize: 15,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "italic": true
                }
                """##)
            ),
            // size as integer
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: false,
                    defaultSize: 24,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "size": 24
                }
                """##)
            ),
            // size as decimal
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: false,
                    defaultSize: 12.5,
                    defaultColor: defaultFontColor,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "size": 12.5
                }
                """##)
            ),
            // color
            (
                Value(
                    customId: nil,
                    alias: "Arial",
                    familyName: "adapty_system",
                    weight: 400,
                    italic: false,
                    defaultSize: 15,
                    defaultColor: color_FF0000,
                    defaultLetterSpacing: nil,
                    defaultLineHeight: nil
                ),
                Json(##"""
                {
                    "type": "font",
                    "value": "Arial",
                    "color": "#FF0000"
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing value
            Json(##"{"type":"font"}"##),
            // Empty value array
            Json(##"{"type":"font","value":[]}"##),
            // Empty object
            Json(##"{}"##),
            // value is number, not string or array
            Json(##"{"type":"font","value":123}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid font", arguments: jsonCases)
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
    }
}
