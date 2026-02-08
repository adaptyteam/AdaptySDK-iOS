//
//  Schema.PointTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.Point Tests")
    struct PointTests {
        typealias Value = Schema.Point

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Number format → same x and y
            (
                Value(x: 0.5, y: 0.5),
                Json(##"0.5"##)
            ),
            (
                Value(x: 0, y: 0),
                Json(##"0"##)
            ),
            (
                Value(x: 1, y: 1),
                Json(##"1"##)
            ),

            // Array format [y, x]
            (
                Value(x: 0, y: 0),
                Json(##"[]"##)
            ),
            (
                Value(x: 5, y: 5),
                Json(##"[5]"##)
            ),
            (
                Value(x: 2, y: 1),
                Json(##"[1,2]"##)
            ),
            (
                Value(x: 0.5, y: 0.5),
                Json(##"[0.5,0.5]"##)
            ),
            (
                // >2 elements: extras ignored
                Value(x: 2, y: 1),
                Json(##"[1,2,3]"##)
            ),

            // Object format
            (
                Value(x: 2, y: 1),
                Json(##"{"y":1,"x":2}"##)
            ),
            (
                Value(x: 0, y: 1),
                Json(##"{"y":1}"##)
            ),
            (
                Value(x: 2, y: 0),
                Json(##"{"x":2}"##)
            ),
            (
                Value(x: 0, y: 0),
                Json(##"{}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##""string""##),
            Json(##"true"##),
            Json(##"["a","b"]"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode from number, array, and object formats", arguments: jsonCases)
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

        @Test("encode ", arguments: jsonCases.map(\.value))
        func encodeSameValues(value: Value) throws {
            let encoded = try Json.encode(value)
            if value.x == value.y {
                let v = try encoded.decode(Double.self)
                #expect(v == value.x)
            } else {
                let array = try encoded.decode([Double].self)
                #expect(array == [value.y, value.x])
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
