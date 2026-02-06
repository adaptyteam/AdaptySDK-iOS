//
//  Schema.PointTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.Point Tests")
    struct SchemaPointTests {
        typealias Value = Schema.Point

        // MARK: - Test Data

        static let decodeCases: [(value: Value, json: String)] = [
            // Number format → same x and y
            (
                Value.center,
                json: "0.5"
            ),
            (
                Value.zero,
                json: "0"
            ),
            (
                Value.one,
                json: "1"
            ),

            // Array format [y, x]
            (
                Value.zero,
                json: "[]"
            ),
            (
                Value(x: 5, y: 5),
                json: "[5]"
            ),
            (
                Value(x: 2, y: 1),
                json: "[1,2]"
            ),
            (
                Value.center,
                json: "[0.5,0.5]"
            ),
            (
                // >2 elements: extras ignored
                Value(x: 2, y: 1),
                json: "[1,2,3]"
            ),

            // Object format
            (
                Value(x: 2, y: 1),
                json: #"{"y":1,"x":2}"#
            ),
            (
                Value(x: 0, y: 1),
                json: #"{"y":1}"#
            ),
            (
                Value(x: 2, y: 0),
                json: #"{"x":2}"#
            ),
            (
                Value.zero,
                json: "{}"
            ),
        ]

        static let invalidJsons: [String] = [
            #""string""#,
            "true",
            #"["a","b"]"#,
        ]

        // MARK: - Decoding Tests

        @Test("decode from number, array, and object formats", arguments: decodeCases)
        func decode(value: Value, json: String) throws {
            let data = "[\(json)]".data(using: .utf8)!
            let result = try JSONDecoder().decode([Value].self, from: data)
            #expect(result.count == 1)
            #expect(result[0].x == value.x)
            #expect(result[0].y == value.y)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(json: String) {
            let data = "[\(json)]".data(using: .utf8)!
            #expect(throws: (any Error).self) {
                try JSONDecoder().decode([Value].self, from: data)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode same x and y as bare number", arguments: [0, 0.5, 1, 10])
        func encodeSameValues(value: Double) throws {
            let data = try JSONEncoder().encode([value])
            let result = try JSONDecoder().decode([Double].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == value)
        }

        @Test("encode different x and y as array [y, x]")
        func encodeDifferentValues() throws {
            let value = Value(x: 2, y: 1)
            let data = try JSONEncoder().encode([value])
            let result = try JSONDecoder().decode([[Double]].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == [1, 2])
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
