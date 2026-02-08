//
//  Schema.Timer.BehaviorTypeTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.TimerTests {
    @Suite("Schema.Timer.BehaviorType Tests")
    struct BehaviorTypeTests {
        typealias Value = Schema.Timer.BehaviorType

        // MARK: - Test Data

        static let allCases: [(value: Value, rawValue: String)] = [
            (.everyAppear, "start_at_every_appear"),
            (.firstAppear, "start_at_first_appear"),
            (.firstAppearPersisted, "start_at_first_appear_persisted"),
            (.endAtLocalTime, "end_at_local_time"),
            (.endAtUTC, "end_at_utc_time"),
            (.custom, "custom"),
        ]

        static let jsonCases = rawValueToJson(allCases)

        static let invalidValues: [String] = [
            "invalid",
            "start",
            "END_AT_UTC_TIME",
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

        @Test("init with invalid raw value returns nil", arguments: invalidValues)
        func initWithInvalidRawValue(invalid: String) {
            #expect(Value(rawValue: invalid) == nil)
        }

        // MARK: - Decoding

        @Test("decode valid value from JSON", arguments: jsonCases)
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
