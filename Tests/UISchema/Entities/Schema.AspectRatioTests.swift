//
//  Schema.AspectRatioTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.AspectRatio Tests")
    struct SchemaAspectRatioTests {
        typealias Value = Schema.AspectRatio

        // MARK: - Test Data

        static let allCases: [(value: Value, rawValue: String)] = [
            (.fit, "fit"),
            (.fill, "fill"),
            (.stretch, "stretch"),
        ]

        static let invalidValues: [String] = [
            "invalid",
            "FIT",
            "",
        ]
    }
}

// MARK: - RawRepresentable Tests

private extension AdaptyUISchemaTests.SchemaAspectRatioTests {
    @Test("init with valid raw value returns correct value", arguments: allCases)
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
}

// MARK: - Codable Tests

private extension AdaptyUISchemaTests.SchemaAspectRatioTests {
    // MARK: - Decoding

    @Test("decode valid value from JSON", arguments: allCases)
    func decodeValid(value: Value, jsonValue: String) throws {
        let json = #"["\#(jsonValue)"]"#.data(using: .utf8)!
        let result = try JSONDecoder().decode([Value].self, from: json)
        #expect(result.count == 1)
        #expect(result[0] == value)
    }

    @Test("decode invalid value from JSON throws error", arguments: invalidValues)
    func decodeInvalid(invalid: String) {
        let json = #"["\#(invalid)"]"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([Value].self, from: json)
        }
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
