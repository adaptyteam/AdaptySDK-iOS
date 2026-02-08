//
//  Schema.ColorGradient.ItemTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.ColorGradientTests {
    @Suite("Schema.ColorGradient.Item Tests")
    struct ItemTests {
        typealias Value = Schema.ColorGradient.Item

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                Value(color: .init(customId: nil, data: 0xFF0000FF), p: 0),
                Json(##"{"color":"#FF0000","p":0}"##)
            ),
            (
                Value(color: .init(customId: nil, data: 0x00FF00FF), p: 0.5),
                Json(##"{"color":"#00ff00","p":0.5}"##)
            ),
            (
                Value(color: .init(customId: nil, data: 0x0000FFFF), p: 1),
                Json(##"{"color":"#0000FF","p":1}"##)
            ),
            // 8-digit hex with alpha
            (
                Value(color: .init(customId: nil, data: 0xFF000080), p: 0.25),
                Json(##"{"color":"#ff000080","p":0.25}"##)
            ),
            // Edge values for p
            (
                Value(color: .init(customId: nil, data: 0x000000FF), p: -0.5),
                Json(##"{"color":"#000000","p":-0.5}"##)
            ),
            (
                Value(color: .init(customId: nil, data: 0x000000FF), p: 1.5),
                Json(##"{"color":"#000000","p":1.5}"##)
            )
        ]

        static let invalidJsons: [Json] = [
            Json(##"{"p":0}"##),
            Json(##"{"color":"#FF0000"}"##),
            Json(##"{}"##),
            Json(##"{"color":"invalid","p":0}"##)
        ]

        // MARK: - Decoding Tests

        @Test("decode valid gradient item", arguments: jsonCases)
        func decodeValid(value: Value, json: Json) throws {
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

        @Test("encode produces color and p fields", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            let deserilized = try #require(encoded.deserilized as? [String: Any])
            #expect(deserilized["color"] as? String == value.color.rawValue)
            #expect(deserilized["p"] as? Double == value.p)
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
