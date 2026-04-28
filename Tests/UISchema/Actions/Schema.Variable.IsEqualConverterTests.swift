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
    struct IsEqualConvertorTests {
        typealias Value = Schema.IsEqualConverter

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                Value(value: VC.AnyValue("section_1"), falseValue: nil),
                Json(##"{"converter":"is_equal", "converter_params": "section_1"}"##)
            ),
            (
                Value(value: VC.AnyValue(45), falseValue: nil),
                Json(##"{"converter":"is_equal", "converter_params": {"value": 45}}"##)
            ),
            (
                Value(value: VC.AnyValue(45), falseValue: VC.AnyValue(0)),
                Json(##"{"converter":"is_equal", "converter_params": {"value": 45, "false_value": 0}}"##)
            ),
            (
                Value(value: VC.AnyValue(true), falseValue: VC.AnyValue(false)),
                Json(##"{"converter":"is_equal", "converter_params": {"value": true, "false_value": false}}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing "converter_params" key
            Json(##"{"converter": "is_equal"}"##),
            // Missing "converter_params.value" key
            Json(##"{"converter": "is_equal", "converter_params": { "false_value": 0 } }"##),
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
    }
}
