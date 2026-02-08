//
//  Schema.AssetsCollectionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-08.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.AssetsCollection Tests")
    struct AssetsCollectionTests {
        typealias Value = Schema.AssetsCollection

        // MARK: - Helpers

        static let defaultFontColor = Schema.Color(customId: nil, data: 0x000000FF)
        static let color_FF0000 = Schema.Color(customId: nil, data: 0xFF0000FF)

        // MARK: - Test Data

        static let jsonCases: [(value: [String: Schema.Asset], json: Json)] = [
            // Empty array
            (
                [:],
                Json(##"[]"##)
            ),
            // Single color asset
            (
                ["color1": .solidColor(color_FF0000)],
                Json(##"""
                [
                    {
                        "id": "color1",
                        "type": "color",
                        "value": "#FF0000"
                    }
                ]
                """##)
            ),
            // Mixed types — color + font
            (
                [
                    "color1": .solidColor(color_FF0000),
                    "font1": .font(.init(
                        customId: nil,
                        alias: "Helvetica",
                        familyName: "adapty_system",
                        weight: 400,
                        italic: false,
                        defaultSize: 15,
                        defaultColor: defaultFontColor
                    )),
                ],
                Json(##"""
                [
                    {
                        "id": "color1",
                        "type": "color",
                        "value": "#FF0000"
                    },
                    {
                        "id": "font1",
                        "type": "font",
                        "value": "Helvetica"
                    }
                ]
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Duplicate ids
            Json(##"""
            [
                {
                    "id": "dup",
                    "type": "color",
                    "value": "#FF0000"
                },
                {
                    "id": "dup",
                    "type": "color",
                    "value": "#00FF00"
                }
            ]
            """##),
            // Missing id
            Json(##"""
            [
                {
                    "type": "color",
                    "value": "#FF0000"
                }
            ]
            """##),
            // Not an array
            Json(##"""
            {
                "id": "color1",
                "type": "color",
                "value": "#FF0000"
            }
            """##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid assets collection", arguments: jsonCases)
        func decode(value: [String: Schema.Asset], json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded.value == value)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: [String: Schema.Asset]) throws {
            let original = Value(value: value)
            let decoded = try Json.encode(original).decode(Value.self)
            #expect(decoded.value == original.value)
        }
    }
}
