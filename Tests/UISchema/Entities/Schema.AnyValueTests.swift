//
//  Schema.AnyValueTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    struct AnyValueTests {
        typealias Value = Schema.AnyValue

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // null
            (
                Value(String?.none),
                Json(##"null"##)
            ),
            // bool true
            (
                Value(true),
                Json(##"true"##)
            ),
            // bool false
            (
                Value(false),
                Json(##"false"##)
            ),
            // int positive
            (
                Value(42),
                Json(##"42"##)
            ),
            // int negative
            (
                Value(-5),
                Json(##"-5"##)
            ),
            // int zero
            (
                Value(0),
                Json(##"0"##)
            ),
            // uint
            (
                Value(3_000_000_000),
                Json(##"3000000000"##)
            ),
            // double
            (
                Value(3.14),
                Json(##"3.14"##)
            ),
            // double negative
            (
                Value(-0.5),
                Json(##"-0.5"##)
            ),
            // string
            (
                Value("hello"),
                Json(##""hello""##)
            ),
            // empty string
            (
                Value(""),
                Json(##""""##)
            ),
            // empty object
            (
                Value([String: Value]()),
                Json(##"{}"##)
            ),
            // object with mixed values
            (
                Value(["name": Value("test"), "count": Value(1)]),
                Json(##"""
                {
                    "name": "test",
                    "count": 1
                }
                """##)
            ),
            // nested object
            (
                Value(["inner": Value(["flag": Value(true)])]),
                Json(##"""
                {
                    "inner": {
                        "flag": true
                    }
                }
                """##)
            ),
            (
                Value([Value(1), Value(2)]),
                Json(##"[1,2]"##)
            ),
            (
                Value([Value("a"), Value("b")]),
                Json(##"["a", "b"]"##)
            ),
            (
                Value([Value(1), Value(true), Value("string")]),
                Json(##"[1, true, "string"]"##)
            ),
        ]

        static let invalidJsons: [Json] = [
        ]

        // MARK: - Decoding Tests

        @Test("decode valid parameter", arguments: jsonCases)
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

