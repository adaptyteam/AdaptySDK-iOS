//
//  Schema.Action.ParameterTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.ActionTests {
    @Suite("Schema.Action.Parameter Tests")
    struct ParameterTests {
        typealias Value = Schema.Action.Parameter

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // null
            (
                .null,
                Json(##"null"##)
            ),
            // bool true
            (
                .bool(true),
                Json(##"true"##)
            ),
            // bool false
            (
                .bool(false),
                Json(##"false"##)
            ),
            // int32 positive
            (
                .int32(42),
                Json(##"42"##)
            ),
            // int32 negative
            (
                .int32(-5),
                Json(##"-5"##)
            ),
            // int32 zero
            (
                .int32(0),
                Json(##"0"##)
            ),
            // uint32 (> Int32.max)
            (
                .uint32(3_000_000_000),
                Json(##"3000000000"##)
            ),
            // double
            (
                .double(3.14),
                Json(##"3.14"##)
            ),
            // double negative
            (
                .double(-0.5),
                Json(##"-0.5"##)
            ),
            // string
            (
                .string("hello"),
                Json(##""hello""##)
            ),
            // empty string
            (
                .string(""),
                Json(##""""##)
            ),
            // empty object
            (
                .object([:]),
                Json(##"{}"##)
            ),
            // object with mixed values
            (
                .object(["name": .string("test"), "count": .int32(1)]),
                Json(##"""
                {
                    "name": "test",
                    "count": 1
                }
                """##)
            ),
            // nested object
            (
                .object(["inner": .object(["flag": .bool(true)])]),
                Json(##"""
                {
                    "inner": {
                        "flag": true
                    }
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // array
            Json(##"[1, 2]"##),
            // array of strings
            Json(##"["a", "b"]"##),
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

        // MARK: - Encoding Tests

        private func reqursiveExpect(_ value: Value, _ deserilized: Any) throws {
            switch value {
            case .null:
                #expect(deserilized is NSNull)
            case .bool(let v):
                #expect(deserilized as? Bool == v)
            case .int32(let v):
                #expect(deserilized as? Int == Int(v))
            case .uint32(let v):
                #expect(deserilized as? UInt == UInt(v))
            case .double(let v):
                #expect(deserilized as? Double == v)
            case .string(let v):
                #expect(deserilized as? String == v)
            case .object(let object):
                let dic = try #require(deserilized as? [String: Any])
                for item in object {
                    print(item.key)
                    let deserilized = try #require(dic[item.key])
                    try reqursiveExpect(item.value, deserilized)
                }
            }
        }

        @Test("encode produces correct value", arguments: jsonCases)
        func encode(value: Value, json: Json) throws {
            let encoded = try Json.encode(value)
            let deserilized = try encoded.deserilized
            try reqursiveExpect(value, deserilized)
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
