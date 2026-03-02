//
//  Schema.Variable.ConverterTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 02.03.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.VariableTests {
    @Suite("Schema.Variable.Converter format Tests")
    struct ConverterTests {
        typealias Value = Schema.Variable.Converter

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                .unknown("name", nil),
                Json(##"{"converter":"name"}"##)
            ),
            (
                .unknown("name_1", .string("p")),
                Json(##"{"converter":"name_1", "converter_params": "p"}"##)
            ),
            (
                .unknown("name_3", .int32(-12)),
                Json(##"{"converter":"name_3", "converter_params": -12}"##)
            ),
            // is_equal
            (
                .isEqual(.string("section_1"), falseValue: nil),
                Json(##"{"converter":"is_equal", "converter_params": "section_1"}"##)
            ),
            (
                .isEqual(.int32(45), falseValue: nil),
                Json(##"{"converter":"is_equal", "converter_params": {"value": 45}}"##)
            ),
            (
                .isEqual(.int32(45), falseValue: .int32(0)),
                Json(##"{"converter":"is_equal", "converter_params": {"value": 45, "false_value": 0}}"##)
            ),
            (
                .isEqual(.bool(true), falseValue: .bool(false)),
                Json(##"{"converter":"is_equal", "converter_params": {"value": true, "false_value": false}}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing "name" key
            Json(##"{"converter_params": "foo"}"##),
            // "name" is number
            Json(##"{"converter": 123}"##),
            // "name" is array
            Json(##"{"converter": ["a", "b"]}"##),
            // Not an object
            Json(##""name""##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid variable", arguments: jsonCases)
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

        @Test("encode produces only var key", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            let obj = try #require(encoded.deserilized as? [String: Any])
            switch value {
            case .isEqual(let value, falseValue: let falseValue):
                #expect(obj["converter"] as? String == "is_equal")
                if let falseValue {
                    let params = try #require(obj["converter_params"] as? [String: Any])
                    #expect(params["value"] != nil)
                    #expect(params["false_value"] != nil)
                } else {
                    #expect(obj["converter_params"] != nil)
                }

            case .unknown(let name, let param):
                #expect(obj["converter"] as? String == name)
                if let param {
                    #expect(obj["converter_params"] != nil)
                } else {
                    #expect(obj["converter_params"] == nil)
                }
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
