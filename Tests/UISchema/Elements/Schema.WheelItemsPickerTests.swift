//
//  Schema.WheelItemsPickerTests.swift
//  AdaptyTests
//
//  Created by Codex on 21.08.2025.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

extension SchemaTests {
    struct WheelItemsPickerTests {}
}

private extension SchemaTests.WheelItemsPickerTests {
    typealias Value = Schema.WheelItemsPicker

    static let jsonCases: [(value: Value, json: Json)] = [
        (
            Value(
                value: .init(path: ["profile", "flag"], setter: nil, scope: .screen, converter: nil),
                items: [
                    .init(stringId: "first", value: .init(true)),
                    .init(stringId: "second", value: .init(false)),
                ]
            ),
            Json(##"""
            {
                "value": { "var": "profile.flag" },
                "items": [
                    { "string_id": "first", "value": true },
                    { "string_id": "second", "value": false }
                ]
            }
            """##)
        ),
        (
            Value(
                value: .init(path: ["profile", "score"], setter: nil, scope: .screen, converter: nil),
                items: [
                    .init(stringId: "first", value: .init(1.5)),
                    .init(stringId: "second", value: .init(2.5)),
                ]
            ),
            Json(##"""
            {
                "value": { "var": "profile.score" },
                "items": [
                    { "string_id": "first", "value": 1.5 },
                    { "string_id": "second", "value": 2.5 }
                ]
            }
            """##)
        ),
        (
            Value(
                value: .init(path: ["profile", "name"], setter: nil, scope: .screen, converter: nil),
                items: [
                    .init(stringId: "first", value: .init("A")),
                    .init(stringId: "second", value: .init("B")),
                ]
            ),
            Json(##"""
            {
                "value": { "var": "profile.name" },
                "items": [
                    { "string_id": "first", "value": "A" },
                    { "string_id": "second", "value": "B" }
                ]
            }
            """##)
        ),
        (
            Value(
                value: .init(path: ["profile", "age"], setter: nil, scope: .screen, converter: nil),
                items: [
                    .init(stringId: "first", value: .init(-1)),
                    .init(stringId: "second", value: .init(42)),
                ]
            ),
            Json(##"""
            {
                "value": { "var": "profile.age" },
                "items": [
                    { "string_id": "first", "value": -1 },
                    { "string_id": "second", "value": 42 }
                ]
            }
            """##)
        ),
        (
            Value(
                value: .init(path: ["profile", "identifier"], setter: nil, scope: .screen, converter: nil),
                items: [
                    .init(stringId: "first", value: .init(3_000_000_000 as UInt)),
                    .init(stringId: "second", value: .init(4_000_000_000 as UInt)),
                ]
            ),
            Json(##"""
            {
                "value": { "var": "profile.identifier" },
                "items": [
                    { "string_id": "first", "value": 3000000000 },
                    { "string_id": "second", "value": 4000000000 }
                ]
            }
            """##)
        ),
    ]

    static let invalidJsons: [Json] = [
        Json(##"""
        {
            "items": [
                { "string_id": "first", "value": true }
            ]
        }
        """##),
        Json(##"""
        {
            "value": { "var": "profile.flag" }
        }
        """##),
        Json(##"""
        {
            "value": { "var": "profile.flag" },
            "items": true
        }
        """##),
        Json(##"""
        {
            "value": { "var": "profile.flag" },
            "items": [
                { "value": true }
            ]
        }
        """##),
        Json(##"""
        {
            "value": { "var": "profile.flag" },
            "items": [
                { "string_id": "first" }
            ]
        }
        """##),
    ]

    static let invalidPrimitiveValueJsons: [Json] = [
        Json(##"""
        {
            "value": { "var": "profile.flag" },
            "items": [
                { "string_id": "first", "value": [1, 2, 3] }
            ]
        }
        """##),
        Json(##"""
        {
            "value": { "var": "profile.flag" },
            "items": [
                { "string_id": "first", "value": { "nested": true } }
            ]
        }
        """##),
    ]

    @Test("decode valid wheel items picker", arguments: jsonCases)
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

    @Test("decode item with non-primitive value throws decoding error", arguments: invalidPrimitiveValueJsons)
    func decodeInvalidPrimitiveValue(invalid: Json) {
        #expect(throws: DecodingError.self, "JSON should be invalid: \(invalid)") {
            try invalid.decode(Value.self)
        }
    }
}

