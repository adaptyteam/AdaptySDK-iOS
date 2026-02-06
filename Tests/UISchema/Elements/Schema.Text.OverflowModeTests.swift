//
//  Schema.Text.OverflowModeTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.Text.OverflowMode Tests")
    struct SchemaTextOverflowModeTests {
        typealias Value = Schema.Text.OverflowMode

        // MARK: - Test Data

        static let allCases: [(value: Value, rawValue: String)] = [
            (.scale, "scale"),
            (.unknown, "unknown"),
        ]

        static let invalidValues: [String] = [
            "invalid",
            "SCALE",
            "",
        ]
    }
}

// MARK: - RawRepresentable Tests

private extension AdaptyUISchemaTests.SchemaTextOverflowModeTests {
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
}

// MARK: - Codable Tests

private extension AdaptyUISchemaTests.SchemaTextOverflowModeTests {
    // MARK: - Decoding

    @Test("decode valid value from JSON", arguments: allCases)
    func decodeValid(value: Value, jsonValue: String) throws {
        let json = #"["\#(jsonValue)"]"#.data(using: .utf8)!
        let result = try JSONDecoder().decode([Value].self, from: json)
        #expect(result.count == 1)
        #expect(result[0] == value)
    }

    // Special: invalid values decode to .unknown instead of throwing
    @Test("decode unknown value from JSON returns .unknown", arguments: invalidValues)
    func decodeUnknown(invalid: String) throws {
        let json = #"["\#(invalid)"]"#.data(using: .utf8)!
        let result = try JSONDecoder().decode([Value].self, from: json)
        #expect(result.count == 1)
        #expect(result[0] == .unknown)
    }

    // MARK: - Encoding

    @Test("encode produces correct JSON value", arguments: allCases)
    func encode(value: Value, jsonValue: String) throws {
        let data = try JSONEncoder().encode([value])
        let json = try JSONDecoder().decode([String].self, from: data)
        #expect(json.count == 1)
        #expect(json[0] == jsonValue)
    }

    // MARK: - Roundtrip

    @Test("encode → decode roundtrip", arguments: allCases)
    func roundtrip(value: Value, jsonValue: String) throws {
        let data = try JSONEncoder().encode([value])
        let decoded = try JSONDecoder().decode([Value].self, from: data)
        #expect(decoded.count == 1)
        #expect(decoded[0] == value)
    }
}
