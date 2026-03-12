//
//  Schema.VariableTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

extension SchemaTests {
    struct VariableTests {
        typealias Value = Schema.Variable

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Minimal — single path segment, defaults
            (
                Value(path: ["name"], setter: nil, scope: .screen, converter: nil),
                Json(##"{"var":"name"}"##)
            ),
            // Dotted path
            (
                Value(path: ["user", "name"], setter: nil, scope: .screen, converter: nil),
                Json(##"{"var":"user.name"}"##)
            ),
            // Deep dotted path
            (
                Value(path: ["a", "b", "c", "d"], setter: nil, scope: .screen, converter: nil),
                Json(##"{"var":"a.b.c.d"}"##)
            ),
            // With setter
            (
                Value(path: ["count"], setter: "setCount", scope: .screen, converter: nil),
                Json(##"""
                {
                    "var": "count",
                    "setter": "setCount"
                }
                """##)
            ),
            // With converter
            (
                Value(path: ["section"], setter: nil, scope: .screen, converter: .isEqual(.int32(5), falseValue: nil)),
                Json(##"""
                {
                    "var": "section",
                    "converter": "is_equal",
                    "converter_params": 5
                }
                """##)
            ),
            // With scope global
            (
                Value(path: ["theme"], setter: nil, scope: .global, converter: nil),
                Json(##"""
                {
                    "var": "theme",
                    "scope": "global"
                }
                """##)
            ),
            // With scope screen (explicit)
            (
                Value(path: ["visible"], setter: nil, scope: .screen, converter: nil),
                Json(##"""
                {
                    "var": "visible",
                    "scope": "screen"
                }
                """##)
            ),
            // Full — all fields
            (
                Value(path: ["data", "count"], setter: "setCount", scope: .global, converter: .unknown("to_string", .bool(true))),
                Json(##"""
                {
                    "var": "data.count",
                    "setter": "setCount",
                    "scope": "global",
                    "converter": "to_string",
                    "converter_params": true
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing "var" key
            Json(##"{"setter": "foo"}"##),
            // "var" is number
            Json(##"{"var": 123}"##),
            // "var" is array
            Json(##"{"var": ["a", "b"]}"##),
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
            #expect(obj["var"] as? String == value.path.joined(separator: "."))
            #expect(obj["setter"] as? String == value.setter)
            if value.scope != .screen {
                #expect(obj["scope"] as? String == value.scope.rawValue)
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
