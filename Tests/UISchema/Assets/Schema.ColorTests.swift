//
//  Schema.ColorTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.Color Tests")
    struct ColorTests {
        typealias Value = Schema.Color

        // MARK: - Test Data

        /// Canonical pairs: rawValue property returns exactly this string
        static let allCases: [(value: Value, rawValue: String)] = [
            (Value(customId: nil, data: 0xFF0000FF), "#ff0000ff"),
            (Value(customId: nil, data: 0x00FF00FF), "#00ff00ff"),
            (Value(customId: nil, data: 0x0000FFFF), "#0000ffff"),
            (Value(customId: nil, data: 0xFFFFFFFF), "#ffffffff"),
            (Value(customId: nil, data: 0x000000FF), "#000000ff"),
            (Value(customId: nil, data: 0x00000000), "#00000000"),
            (Value(customId: nil, data: 0xFF00AA80), "#ff00aa80"),
        ]
        /// Non-canonical but valid inputs (6-digit, uppercase, mixed case)
        static let alternativeInputsCases: [(value: Value, rawValue: String)] = [
            // 6-digit hex → alpha defaults to 0xFF
            (Value(customId: nil, data: 0xFF0000FF), "#FF0000"),
            (Value(customId: nil, data: 0xFF0000FF), "#ff0000"),
            (Value(customId: nil, data: 0xFF00AAFF), "#Ff00Aa"),

            // 8-digit uppercase
            (Value(customId: nil, data: 0xFF0000FF), "#FF0000FF"),
            (Value(customId: nil, data: 0xFF00AA80), "#FF00AA80"),
        ]

        static let jsonCases = rawValueToJson(allCases)

        static let alternativeInputsJsonCases = rawValueToJson(alternativeInputsCases)

        static let invalidValues: [String] = [
            "FF0000",
            "#F00",
            "#GGGGGG",
            "#FF0000F",
            "#FF000",
            "",
            "#",
        ]

        static let invalidJsons = rawValueToJson(invalidValues)

        // MARK: - RawRepresentable Tests

        @Test("init with valid raw value returns correct value", arguments: allCases + alternativeInputsCases)
        func initWithValidRawValue(value: Value, rawValue: String) {
            #expect(Value(rawValue: rawValue) == value)
        }

        @Test("rawValue returns correct string", arguments: allCases)
        func rawValue(value: Value, rawValue: String) {
            #expect(value.rawValue == rawValue)
        }

        @Test("init with invalid raw value returns nil", arguments: invalidValues)
        func initWithInvalidRawValue(invalid: String) {
            #expect(Value(rawValue: invalid) == nil)
        }

        // MARK: - Decoding

        @Test("decode valid value from JSON", arguments: jsonCases + alternativeInputsJsonCases)
        func decodeValid(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode invalid value from JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Encoding

        @Test("encode produces correct JSON value", arguments: jsonCases)
        func encode(value: Value, json: Json) throws {
            let encoded = try Json.encode(value)
            #expect(encoded == json)
        }

        // MARK: - Roundtrip

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
