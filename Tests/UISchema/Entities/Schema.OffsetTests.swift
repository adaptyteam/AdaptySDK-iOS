//
//  Schema.OffsetTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.Offset Tests")
    struct SchemaOffsetTests {
        typealias Value = Schema.Offset

        // MARK: - Test Data

        static let decodeCases: [(value: Value, json: String)] = [
            // Unit format → y=value, x=.zero
            (
                Value(x: .point(0), y: .point(10)),
                json: "10"
            ),
            (
                Value(x: .point(0), y: .point(0)),
                json: "0"
            ),
            (
                Value(x: .point(0), y: .point(5.5)),
                json: "5.5"
            ),
            (
                Value(x: .point(0), y: .point(0.5)),
                json: #"{"point":0.5}"#
            ),
            (
                Value(x: .point(0), y: .screen(0.5)),
                json: #"{"screen":0.5}"#
            ),
            (
                Value(x: .point(0), y: .safeArea(.end)),
                json: #"{"safe_area":"end"}"#
            ),

            // Array format [y, x]
            (
                Value(x: .point(0), y: .point(0)),
                json: "[]"
            ),
            (
                Value(x: .point(0), y: .point(5)),
                json: "[5]"
            ),
            (
                Value(x: .point(20), y: .point(10)),
                json: "[10,20]"
            ),
            (
                // >2 elements: extras ignored
                Value(x: .point(20), y: .point(10)),
                json: #"[10,{"point":20},30]"#
            ),
            (
                // Mixed Unit types
                Value(x: .screen(0.5), y: .point(10)),
                json: #"[10,{"screen":0.5}]"#
            ),

            // Object format
            (
                Value(x: .point(20), y: .point(10)),
                json: #"{"y":10,"x":20}"#
            ),
            (
                Value(x: .point(0), y: .point(10)),
                json: #"{"y":10}"#
            ),
            (
                Value(x: .point(20), y: .point(0)),
                json: #"{"x":20}"#
            ),
            (
                Value(x: .point(0), y: .point(0)),
                json: "{}"
            ),
            (
                Value(x: .screen(0), y: .screen(0.5)),
                json: #"{"x":{"screen":0},"y":{"screen":0.5}}"#
            ),
            (
                Value(x: .zero, y: .safeArea(.start)),
                json: #"{"y":{"safe_area":"start"}}"#
            ),
        ]

        static let invalidJsons: [String] = [
            #""string""#,
            "true",
            #"["a","b"]"#,
        ]

        // MARK: - Decoding Tests

        @Test("decode from unit, array, and object formats", arguments: decodeCases)
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

        @Test("encode  y as single Unit value when x is zero", arguments: [
            Schema.Unit.point(0),
            Schema.Unit.point(10),
            Schema.Unit.screen(0),
            Schema.Unit.screen(5),
            Schema.Unit.safeArea(.end)
        ])
        func encodeOnlyYValue(value: Schema.Unit) throws {
            let data = try JSONEncoder().encode([value])
            let result = try JSONDecoder().decode([Schema.Unit].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == value)
        }

        @Test("encode different x and y as array [y, x]", arguments: [
            Value(x: .point(20), y: .point(10)),
            Value(x: .point(20), y: .screen(10)),
            Value(x: .screen(20), y: .point(0)),
            Value(x: .safeArea(.start), y: .point(0)),
        ])
        func encodeAllValues(value _: Value) throws {
            let value = Value(x: .point(20), y: .point(10))
            let data = try JSONEncoder().encode([value])
            let result = try JSONDecoder().decode([[Schema.Unit]].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == [value.y, value.x])
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
