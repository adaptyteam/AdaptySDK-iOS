//
//  Schema.Animation.InterpolatorTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests.AnimationTests {
    @Suite("Schema.Animation.Interpolator Tests")
    struct InterpolatorTests {
        typealias Value = Schema.Animation.Interpolator

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            (
                .easeInOut,
                Json(##""ease_in_out""##)
            ),
            (
                .easeIn,
                Json(##""ease_in""##)
            ),
            (
                .easeOut,
                Json(##""ease_out""##)
            ),
            (
                .linear,
                Json(##""linear""##)
            ),
            (
                .easeInElastic,
                Json(##""ease_in_elastic""##)
            ),
            (
                .easeOutElastic,
                Json(##""ease_out_elastic""##)
            ),
            (
                .easeInOutElastic,
                Json(##""ease_in_out_elastic""##)
            ),
            (
                .easeInBounce,
                Json(##""ease_in_bounce""##)
            ),
            (
                .easeOutBounce,
                Json(##""ease_out_bounce""##)
            ),
            (
                .easeInOutBounce,
                Json(##""ease_in_out_bounce""##)
            ),
            (
                .cubicBezier(0.25, 0.1, 0.25, 1.0),
                Json(##"[0.25,0.1,0.25,1.0]"##)
            ),
            (
                .cubicBezier(0.0, 0.0, 1.0, 1.0),
                Json(##"[0.0,0.0,1.0,1.0]"##)
            ),
            (
                .cubicBezier(0.4, 0.0, 0.5, 1.0),
                Json(##"[0.4,0.0,0.5,1.0]"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            Json(##""invalid""##),
            Json(##""ease""##),
            Json(##""EASE_IN_OUT""##),
            Json(##""""##),
            Json(##"[0.25,0.1,0.25]"##),
            Json(##"[0.25,0.1,0.25,1.0,0.5]"##),
            Json(##"[]"##),
        ]

        // MARK: - Decoding

        @Test("decode from JSON", arguments: jsonCases)
        func decodeValid(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) throws {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Encoding

        @Test("encode all cases to JSON", arguments: jsonCases)
        func encode(value: Value, json: Json) throws {
            let encoded = try Json.encode(value)
            guard case let .cubicBezier(a, b, c, d) = value else {
                #expect(encoded == json)
                return
            }
            let deserilized = try #require(encoded.deserilized as? [Double])
            #expect([a, b, c, d] == deserilized)
        }

        // MARK: - Roundtrip

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
