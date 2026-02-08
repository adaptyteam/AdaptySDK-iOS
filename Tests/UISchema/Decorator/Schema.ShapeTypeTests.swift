//
//  Schema.ShapeTypeTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.ShapeType Tests")
    struct ShapeTypeTests {
        typealias Value = Schema.ShapeType

        // MARK: - Test Data

        static let allCases: [(value: Value, rawValue: String)] = [
            (.circle, "circle"),
            (.rectangle(cornerRadius: Schema.CornerRadius(same: 0)), "rect"),
            (.curveUp, "curve_up"),
            (.curveDown, "curve_down"),
        ]

        static let jsonCases = rawValueToJson(allCases)

        static let invalidValues: [String] = [
            "invalid",
            "RECT",
            "Circle",
            "",
        ]

        static let invalidJsons = rawValueToJson(invalidValues)

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
