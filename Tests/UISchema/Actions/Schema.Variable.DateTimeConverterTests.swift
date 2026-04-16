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
    struct DateTimeConvertorTests {
        typealias Value = Schema.Variable.DateTimeConvertor

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                .format("YYYY-mm-dd"),
                Json(##"{"converter": "date_time", "converter_params": "YYYY-mm-dd"}"##)
            ),
            (
                .format("YYYY-mm-dd"),
                Json(##"{"converter": "date_time", "converter_params": { "format": "YYYY-mm-dd" } }"##)
            ),
            (
                .styles(date: .full, time: .full),
                Json(##"{"converter":"date_time", "converter_params": { "date": "full", "time": "full" }}"##)
            ),
            (
                .styles(date: .none, time: .full),
                Json(##"{"converter":"date_time", "converter_params": { "time": "full" }}"##)
            ),
            (
                .styles(date: .full, time: .none),
                Json(##"{"converter":"date_time", "converter_params": { "date": "full" }}"##)
            ),
            (
                .styles(date: .none, time: .none),
                Json(##"{"converter":"date_time", "converter_params": { "date": "none", "time": "none" }}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##"{"converter_params": 123 }"##),
            Json(##"{"converter_params": { "format": 123 }}"##),
            Json(##"{"converter_params": { "date": 123 }}"##),
            Json(##"{"converter_params": { "time": 123 }}"##),
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

