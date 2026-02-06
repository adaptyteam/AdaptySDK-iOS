//
//  Schema.Animation.InterpolatorTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension AdaptyUISchemaTests {
    @Suite("Schema.Animation.Interpolator Tests")
    struct SchemaAnimationInterpolatorTests {
        typealias Value = Schema.Animation.Interpolator

        // MARK: - Test Data

        static let namedCases: [(value: Value, jsonValue: String)] = [
            (.easeInOut, "ease_in_out"),
            (.easeIn, "ease_in"),
            (.easeOut, "ease_out"),
            (.linear, "linear"),
            (.easeInElastic, "ease_in_elastic"),
            (.easeOutElastic, "ease_out_elastic"),
            (.easeInOutElastic, "ease_in_out_elastic"),
            (.easeInBounce, "ease_in_bounce"),
            (.easeOutBounce, "ease_out_bounce"),
            (.easeInOutBounce, "ease_in_out_bounce"),
        ]

        static let invalidStringValues: [String] = [
            "invalid",
            "ease",
            "EASE_IN_OUT",
            "",
        ]
    }
}

// MARK: - Codable Tests (Named Cases)

private extension AdaptyUISchemaTests.SchemaAnimationInterpolatorTests {
    // MARK: - Decoding

    @Test("decode named case from JSON", arguments: namedCases)
    func decodeNamed(value: Value, jsonValue: String) throws {
        let json = #"["\#(jsonValue)"]"#.data(using: .utf8)!
        let result = try JSONDecoder().decode([Value].self, from: json)
        #expect(result.count == 1)
        #expect(result[0] == value)
    }

    @Test("decode invalid string from JSON throws error", arguments: invalidStringValues)
    func decodeInvalidString(invalid: String) {
        let json = #"["\#(invalid)"]"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([Value].self, from: json)
        }
    }

    // MARK: - Encoding

    @Test("encode named case produces correct JSON value", arguments: namedCases)
    func encodeNamed(value: Value, jsonValue: String) throws {
        let data = try JSONEncoder().encode([value])
        let json = try JSONDecoder().decode([String].self, from: data)
        #expect(json.count == 1)
        #expect(json[0] == jsonValue)
    }

    // MARK: - Roundtrip

    @Test("encode → decode roundtrip for named case", arguments: namedCases)
    func roundtripNamed(value: Value, jsonValue: String) throws {
        let data = try JSONEncoder().encode([value])
        let decoded = try JSONDecoder().decode([Value].self, from: data)
        #expect(decoded.count == 1)
        #expect(decoded[0] == value)
    }
}

// MARK: - Codable Tests (Cubic Bezier)

private extension AdaptyUISchemaTests.SchemaAnimationInterpolatorTests {
    @Test("decode cubic bezier from JSON")
    func decodeCubicBezier() throws {
        let json = "[[0.25,0.1,0.25,1.0]]".data(using: .utf8)!
        let result = try JSONDecoder().decode([Value].self, from: json)
        #expect(result.count == 1)
        #expect(result[0] == .cubicBezier(0.25, 0.1, 0.25, 1.0))
    }

    @Test("decode cubic bezier linear from JSON")
    func decodeCubicBezierLinear() throws {
        let json = "[[0.0,0.0,1.0,1.0]]".data(using: .utf8)!
        let result = try JSONDecoder().decode([Value].self, from: json)
        #expect(result.count == 1)
        #expect(result[0] == .cubicBezier(0.0, 0.0, 1.0, 1.0))
    }

    @Test("decode cubic bezier with wrong count throws error")
    func decodeCubicBezierWrongCount() {
        let tooFew = "[[0.25,0.1,0.25]]".data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([Value].self, from: tooFew)
        }

        let tooMany = "[[0.25,0.1,0.25,1.0,0.5]]".data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([Value].self, from: tooMany)
        }

        let empty = "[[]]".data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode([Value].self, from: empty)
        }
    }

    @Test("encode cubic bezier produces correct JSON")
    func encodeCubicBezier() throws {
        let value = Value.cubicBezier(0.25, 0.1, 0.25, 1.0)
        let data = try JSONEncoder().encode([value])
        let json = try JSONDecoder().decode([[Double]].self, from: data)
        #expect(json.count == 1)
        #expect(json[0] == [0.25, 0.1, 0.25, 1.0])
    }

    @Test("encode → decode roundtrip for cubic bezier")
    func roundtripCubicBezier() throws {
        let value = Value.cubicBezier(0.42, 0.0, 0.58, 1.0)
        let data = try JSONEncoder().encode([value])
        let decoded = try JSONDecoder().decode([Value].self, from: data)
        #expect(decoded.count == 1)
        #expect(decoded[0] == value)
    }
}
