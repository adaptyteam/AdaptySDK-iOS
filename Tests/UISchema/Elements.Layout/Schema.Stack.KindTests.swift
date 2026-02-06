//
//  Schema.Stack.KindTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.Stack.Kind Tests")
    struct SchemaStackKindTests {
        typealias Value = Schema.Stack.Kind

        // MARK: - Test Data

        static let allCases: [(value: Value, rawValue: String)] = [
            (.vertical, "v_stack"),
            (.horizontal, "h_stack"),
            (.z, "z_stack"),
        ]

        static let invalidValues: [String] = [
            "invalid",
            "vstack",
            "stack",
            "V_STACK",
            "",
        ]
    }
}

// MARK: - RawRepresentable Tests

private extension AdaptyUISchemaTests.SchemaStackKindTests {
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

// MARK: - Decodable Tests

private extension AdaptyUISchemaTests.SchemaStackKindTests {
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
}
