//
//  Schema.CornerRadiusTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.CornerRadius Tests")
    struct CornerRadiusTests {
        typealias Value = Schema.CornerRadius

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                Value(same: 10),
                Json(##"10"##)
            ),
            (
                Value(same: 0),
                Json(##"0"##)
            ),
            (
                Value(same: 5.5),
                Json(##"5.5"##)
            ),
            // Array format
            (
                Value(same: 0),
                Json(##"[]"##)
            ),
            (
                Value(topLeading: 5, topTrailing: 5, bottomTrailing: 5, bottomLeading: 5),
                Json(##"[5]"##)
            ),
            (
                Value(topLeading: 5, topTrailing: 10, bottomTrailing: 0, bottomLeading: 0),
                Json(##"[5,10]"##)
            ),
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 0),
                Json(##"[1,2,3]"##)
            ),
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
                Json(##"[1,2,3,4]"##)
            ),
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
                Json(##"[1,2,3,4,5]"##)
            ),
            // Object format
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
                Json(##"""
                {
                    "top_leading":1,
                    "top_trailing":2,
                    "bottom_trailing":3,
                    "bottom_leading":4
                }
                """##)
            ),
            (
                Value(topLeading: 5, topTrailing: 0, bottomTrailing: 0, bottomLeading: 0),
                Json(##"""
                {
                    "top_leading":5
                }
                """##)
            ),
            (
                Value(topLeading: 0, topTrailing: 5, bottomTrailing: 0, bottomLeading: 0),
                Json(##"""
                {
                    "top_trailing":5
                }
                """##)
            ),
            (
                Value(topLeading: 0, topTrailing: 0, bottomTrailing: 5, bottomLeading: 0),
                Json(##"""
                {
                    "bottom_trailing":5
                }
                """##)
            ),
            (
                Value(topLeading: 0, topTrailing: 0, bottomTrailing: 0, bottomLeading: 5),
                Json(##"""
                {
                    "bottom_leading":5
                }
                """##)
            ),
            (
                Value(same: 0),
                Json(##"{}"##)
            )
        ]

        static let invalidJsons: [Json] = [
            Json(##""string""##),
            Json(##"true"##),
            Json(##"["a","b"]"##)
        ]

        // MARK: - Decoding Tests

        @Test("decode from number, array, and object formats", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let dcoded = try json.decode(Value.self)
            #expect(dcoded == value)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode all values", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            let obj = try #require(encoded.deserilized as? [String: Double])

            #expect(obj["top_leading"] == (value.topLeading.isZero ? nil : value.topLeading))
            #expect(obj["top_trailing"] == (value.topTrailing.isZero ? nil : value.topTrailing))
            #expect(obj["bottom_trailing"] == (value.bottomTrailing.isZero ? nil : value.bottomTrailing))
            #expect(obj["bottom_leading"] == (value.bottomLeading.isZero ? nil : value.bottomLeading))
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
