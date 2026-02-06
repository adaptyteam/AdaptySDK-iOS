//
//  Schema.UnitTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.Unit Tests")
    struct SchemaUnitTests {
        typealias Value = Schema.Unit

        // MARK: - Test Data

        static let decodeCases: [(value: Value, json: String)] = [
            // Number format → .point
            (
                Value.point(10),
                json: "10"
            ),
            (
                Value.point(0),
                json: "0"
            ),
            (
                Value.point(-5),
                json: "-5"
            ),
            (
                Value.point(3.14),
                json: "3.14"
            ),

            // {point: N} format → .point
            (
                Value.point(10),
                json: #"{"point":10}"#
            ),
            (
                Value.point(0),
                json: #"{"point":0}"#
            ),

            // {screen: N} format → .screen
            (
                Value.screen(0.5),
                json: #"{"screen":0.5}"#
            ),
            (
                Value.screen(1),
                json: #"{"screen":1}"#
            ),
            (
                Value.screen(0),
                json: #"{"screen":0}"#
            ),

            // {safe_area: ...} format → .safeArea
            (
                Value.safeArea(.start),
                json: #"{"safe_area":"start"}"#
            ),
            (
                Value.safeArea(.end),
                json: #"{"safe_area":"end"}"#
            ),

            // {value: N} format, default unit → .point
            (
                Value.point(10),
                json: #"{"value":10}"#
            ),

            // {value: N, unit: "point"/screen"} format
            (
                Value.point(10),
                json: #"{"value":10,"unit":"point"}"#
            ),
            (
                Value.screen(0.5),
                json: #"{"value":0.5,"unit":"screen"}"#
            ),
            (
                Value.screen(0.5),
                json: #"{"value":0.5,"unit":"screen"}"#
            ),
            (
                Value.screen(0.5),
                json: #"{"value":0.5,"unit":"screen"}"#
            ),
        ]

        static let invalidJsons: [String] = [
            #""string""#,
            "true",
            "{}",
            #"{"safe_area":"invalid"}"#,
            #"{"value":10,"unit":"invalid"}"#,
            #"{"unknown":10}"#,
        ]

        // MARK: - Decoding Tests

        @Test("decode from all supported formats", arguments: decodeCases)
        func decode(value: Value, json: String) throws {
            let data = "[\(json)]".data(using: .utf8)!
            let result = try JSONDecoder().decode([Value].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == value)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(json: String) {
            let data = "[\(json)]".data(using: .utf8)!
            #expect(throws: (any Error).self) {
                try JSONDecoder().decode([Value].self, from: data)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode .point as bare number")
        func encodePoint() throws {
            let data = try JSONEncoder().encode([Value.point(10)])
            let result = try JSONDecoder().decode([Double].self, from: data)
            #expect(result == [10])
        }

        @Test("encode .screen as object with screen key")
        func encodeScreen() throws {
            let data = try JSONEncoder().encode([Value.screen(0.5)])
            let result = try JSONDecoder().decode([[String: Double]].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == ["screen": 0.5])
        }

        @Test("encode .safeArea as object with safe_area key")
        func encodeSafeArea() throws {
            let data = try JSONEncoder().encode([Value.safeArea(.start)])
            let result = try JSONDecoder().decode([[String: String]].self, from: data)
            #expect(result.count == 1)
            #expect(result[0] == ["safe_area": "start"])
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
