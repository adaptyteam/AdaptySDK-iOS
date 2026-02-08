//
//  Schema.OffsetTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.Offset Tests")
    struct OffsetTests {
        typealias Value = Schema.Offset

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Unit format → y=value, x=.zero
            (
                Value(x: .point(0), y: .point(10)),
                Json(##"10"##)
            ),
            (
                Value(x: .point(0), y: .point(0)),
                Json(##"0"##)
            ),
            (
                Value(x: .point(0), y: .point(5.5)),
                Json(##"5.5"##)
            ),
            (
                Value(x: .point(0), y: .point(0.5)),
                Json(##"{"point":0.5}"##)
            ),
            (
                Value(x: .point(0), y: .screen(0.5)),
                Json(##"{"screen":0.5}"##)
            ),
            (
                Value(x: .point(0), y: .safeArea(.end)),
                Json(##"{"safe_area":"end"}"##)
            ),

            // Array format [y, x]
            (
                Value(x: .point(0), y: .point(0)),
                Json(##"[]"##)
            ),
            (
                Value(x: .point(0), y: .point(5)),
                Json(##"[5]"##)
            ),
            (
                Value(x: .point(20), y: .point(10)),
                Json(##"[10,20]"##)
            ),
            (
                // >2 elements: extras ignored
                Value(x: .point(20), y: .point(10)),
                Json(##"[10,{"point":20},30]"##)
            ),
            (
                // Mixed Unit types
                Value(x: .screen(0.5), y: .point(10)),
                Json(##"[10,{"screen":0.5}]"##)
            ),

            // Object format
            (
                Value(x: .point(20), y: .point(10)),
                Json(##"{"y":10,"x":20}"##)
            ),
            (
                Value(x: .point(0), y: .point(10)),
                Json(##"{"y":10}"##)
            ),
            (
                Value(x: .point(20), y: .point(0)),
                Json(##"{"x":20}"##)
            ),
            (
                Value(x: .point(0), y: .point(0)),
                Json(##"{}"##)
            ),
            (
                Value(x: .screen(0), y: .screen(0.5)),
                Json(##"{"x":{"screen":0},"y":{"screen":0.5}}"##)
            ),
            (
                Value(x: .point(0), y: .safeArea(.start)),
                Json(##"{"y":{"safe_area":"start"}}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##""string""##),
            Json(##"true"##),
            Json(##"["a","b"]"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode from unit, array, and object formats", arguments: jsonCases)
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

        @Test("encode `y` as single Unit value when `x` is zero", arguments: [
            Schema.Unit.point(0),
            Schema.Unit.point(10),
            Schema.Unit.screen(0),
            Schema.Unit.screen(5),
            Schema.Unit.safeArea(.end)
        ])
        func encodeOnlyYValue(unit: Schema.Unit) throws {
            let value = Value(x: .point(0), y: unit)
            let encoded = try Json.encode(value)
            let decodedUnit = try encoded.decode(Schema.Unit.self)
            #expect(decodedUnit == unit)
        }

        @Test("encode all", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            if case .point(0) = value.x {
                let y = try encoded.decode(Schema.Unit.self)
                #expect(y == value.y)
            } else {
                let array = try encoded.decode([Schema.Unit].self)
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
