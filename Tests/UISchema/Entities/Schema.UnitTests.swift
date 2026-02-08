//
//  Schema.UnitTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.Unit Tests")
    struct UnitTests {
        typealias Value = Schema.Unit

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Number format → .point
            (
                Value.point(10),
                Json(##"10"##)
            ),
            (
                Value.point(0),
                Json(##"0"##)
            ),
            (
                Value.point(-5),
                Json(##"-5"##)
            ),
            (
                Value.point(3.14),
                Json(##"3.14"##)
            ),

            // {point: N} format → .point
            (
                Value.point(10),
                Json(##"{"point":10}"##)
            ),
            (
                Value.point(0),
                Json(##"{"point":0}"##)
            ),

            // {screen: N} format → .screen
            (
                Value.screen(0.5),
                Json(##"{"screen":0.5}"##)
            ),
            (
                Value.screen(1),
                Json(##"{"screen":1}"##)
            ),
            (
                Value.screen(0),
                Json(##"{"screen":0}"##)
            ),

            // {safe_area: ...} format → .safeArea
            (
                Value.safeArea(.start),
                Json(##"{"safe_area":"start"}"##)
            ),
            (
                Value.safeArea(.end),
                Json(##"{"safe_area":"end"}"##)
            ),

            // {value: N} format, default unit → .point
            (
                Value.point(10),
                Json(##"{"value":10}"##)
            ),

            // {value: N, unit: "point"/screen"} format
            (
                Value.point(10),
                Json(##"{"value":10,"unit":"point"}"##)
            ),
            (
                Value.screen(0.5),
                Json(##"{"value":0.5,"unit":"screen"}"##)
            ),
            (
                Value.screen(0.5),
                Json(##"{"value":0.5,"unit":"screen"}"##)
            ),
            (
                Value.screen(0.5),
                Json(##"{"value":0.5,"unit":"screen"}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##""string""##),
            Json(##"true"##),
            Json(##"{}"##),
            Json(##"{"safe_area":"invalid"}"##),
            Json(##"{"value":10,"unit":"invalid"}"##),
            Json(##"{"unknown":10}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode from all supported formats", arguments: jsonCases)
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

        @Test("encode all supported formats", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            switch value {
            case .point(let point):
                let v = try encoded.decode(Double.self)
                #expect(v == point)
            case .screen(let screen):
                let o = try encoded.decode([String: Double].self)
                #expect(o == ["screen": screen])
            case .safeArea(let safeArea):
                let o = try encoded.decode([String: Value.SafeArea].self)
                #expect(o == ["safe_area": safeArea])
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
