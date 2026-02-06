//
//  Schema.CornerRadiusTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.CornerRadius Tests")
    struct SchemaCornerRadiusTests {
        typealias Value = Schema.CornerRadius

        // MARK: - Test Data

        static let decodeCases: [(value: Value, json: String)] = [
            (
                Value(same: 10),
                json: "10"
            ),
            (
                Value.zero,
                json: "0"
            ),
            (
                Value(same: 5.5),
                json: "5.5"
            ),
            // Array format
            (
                Value.zero,
                json: "[]"
            ),
            (
                Value(topLeading: 5, topTrailing: 5, bottomTrailing: 5, bottomLeading: 5),
                json: "[5]"
            ),
            (
                Value(topLeading: 5, topTrailing: 10, bottomTrailing: 0, bottomLeading: 0),
                json: "[5,10]"
            ),
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 0),
                json: "[1,2,3]"
            ),
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
                json: "[1,2,3,4]"
            ),
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
                json: "[1,2,3,4,5]"
            ),
            // Object format
            (
                Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4),
                json: #"{"top_leading":1,"top_trailing":2,"bottom_trailing":3,"bottom_leading":4}"#
            ),
            (
                Value(topLeading: 5, topTrailing: 0, bottomTrailing: 0, bottomLeading: 0),
                json: #"{"top_leading":5}"#
            ),
            (
                Value(topLeading: 0, topTrailing: 5, bottomTrailing: 0, bottomLeading: 0),
                json: #"{"top_trailing":5}"#
            ),
            (
                Value(topLeading: 0, topTrailing: 0, bottomTrailing: 5, bottomLeading: 0),
                json: #"{"bottom_trailing":5}"#
            ),
            (
                Value(topLeading: 0, topTrailing: 0, bottomTrailing: 0, bottomLeading: 5),
                json: #"{"bottom_leading":5}"#
            ),
            (
                Value.zero,
                json: "{}"
            )
        ]

        static let invalidJsons: [String] = [
            #""string""#,
            "true",
            #"["a","b"]"#
        ]

        // MARK: - Decoding Tests

        @Test("decode from number, array, and object formats", arguments: decodeCases)
        func decode(value: Value, json: String) throws {
            let data = "[\(json)]".data(using: .utf8)!
            let result = try JSONDecoder().decode([Value].self, from: data)
            #expect(result.count == 1)
            #expect(result[0].topLeading == value.topLeading)
            #expect(result[0].topTrailing == value.topTrailing)
            #expect(result[0].bottomTrailing == value.bottomTrailing)
            #expect(result[0].bottomLeading == value.bottomLeading)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(json: String) {
            let data = "[\(json)]".data(using: .utf8)!
            #expect(throws: (any Error).self) {
                try JSONDecoder().decode([Value].self, from: data)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode omits zero values")
        func encodeOmitsZeros() throws {
            let value = Value.zero
            let data = try JSONEncoder().encode([value])
            let json = try JSONDecoder().decode([[String: Double]].self, from: data)
            #expect(json.count == 1)
            #expect(json[0].isEmpty)
        }

        @Test("encode includes only non-zero values")
        func encodeOnlyNonZeros() throws {
            let value = Value(topLeading: 5, topTrailing: 0, bottomTrailing: 3, bottomLeading: 0)
            let data = try JSONEncoder().encode([value])
            let dict = try JSONDecoder().decode([[String: Double]].self, from: data)
            #expect(dict.count == 1)
            #expect(dict[0] == ["top_leading": 5, "bottom_trailing": 3])
        }

        @Test("encode all non-zero values")
        func encodeAllNonZeros() throws {
            let value = Value(topLeading: 1, topTrailing: 2, bottomTrailing: 3, bottomLeading: 4)
            let data = try JSONEncoder().encode([value])
            let dict = try JSONDecoder().decode([[String: Double]].self, from: data)
            #expect(dict.count == 1)
            #expect(dict[0] == ["top_leading": 1, "top_trailing": 2, "bottom_trailing": 3, "bottom_leading": 4])
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: Self.decodeCases.map(\.value))
        func roundtrip(value: Value) throws {
            let data = try JSONEncoder().encode([value])
            let decoded = try JSONDecoder().decode([Value].self, from: data)
            #expect(decoded.count == 1)
            #expect(decoded[0] == value)
        }
    }
}
