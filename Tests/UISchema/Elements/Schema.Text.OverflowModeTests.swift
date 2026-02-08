//
//  Schema.Text.OverflowModeTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.TextTests {
    @Suite("Schema.Text.OverflowMode Tests")
    struct OverflowModeTests {
        typealias Value = Schema.Text.OverflowMode

        // MARK: - Test Data

        static let allCases: [(value: Value, rawValue: String)] = [
            (.scale, "scale"),
            (.unknown, "unknown"),
        ]

        static let jsonCases = rawValueToJson(allCases)

        static let invalidValues: [String] = [
            "invalid",
            "SCALE",
            "",
        ]

        static let invalidJsons = rawValueToJson(invalidValues)

        // MARK: - RawRepresentable Tests

        @Test("init with valid raw value returns correct value", arguments: allCases)
        func initWithValidRawValue(value: Value, rawValue: String) {
            #expect(Value(rawValue: rawValue) == value)
        }

        @Test("rawValue returns correct string", arguments: allCases)
        func rawValue(value: Value, rawValue: String) {
            #expect(value.rawValue == rawValue)
        }

        // Special: invalid raw values fall back to .unknown instead of nil
        @Test("init with invalid raw value returns .unknown", arguments: invalidValues)
        func initWithInvalidRawValue(invalid: String) {
            #expect(Value(rawValue: invalid) == .unknown)
        }

        // MARK: - Decoding

        @Test("decode valid value from JSON", arguments: jsonCases)
        func decodeValid(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        // Special: invalid values decode to .unknown instead of throwing
        @Test("decode unknown value from JSON returns .unknown", arguments: invalidJsons)
        func decodeUnknown(invalid: Json) throws {
            let decoded = try invalid.decode(Value.self)
            #expect(decoded == .unknown)
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
