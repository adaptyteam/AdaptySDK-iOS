//
//  Schema.ColorGradientTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

 extension SchemaTests {
    @Suite("Schema.ColorGradient Tests")
    struct ColorGradientTests {
        typealias Value = Schema.ColorGradient

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Linear gradient, top-to-bottom, 2 stops
            (
                Value(
                    customId: nil,
                    kind: .linear,
                    start: .init(x: 0.5, y: 0),
                    end: .init(x: 0.5, y: 1),
                    items: [
                        .init(color: .init(customId: nil, data: 0xFF0000FF), p: 0),
                        .init(color: .init(customId: nil, data: 0x0000FFFF), p: 1),
                    ]
                ),
                Json(##"""
                {
                    "type": "linear-gradient",
                    "values": [
                        {"color": "#ff0000ff", "p": 0},
                        {"color": "#0000ffff", "p": 1}
                    ],
                    "points": {
                        "x0": 0.5, "y0": 0,
                        "x1": 0.5, "y1": 1
                    }
                }
                """##)
            ),
            // Radial gradient, 3 stops
            (
                Value(
                    customId: nil,
                    kind: .radial,
                    start: .init(x: 0.5, y: 0.5),
                    end: .init(x: 1, y: 1),
                    items: [
                        .init(color: .init(customId: nil, data: 0xFF0000FF), p: 0),
                        .init(color: .init(customId: nil, data: 0x00FF00FF), p: 0.5),
                        .init(color: .init(customId: nil, data: 0x0000FFFF), p: 1),
                    ]
                ),
                Json(##"""
                {
                    "type": "radial-gradient",
                    "values": [
                        {"color": "#ff0000ff", "p": 0},
                        {"color": "#00ff00ff", "p": 0.5},
                        {"color": "#0000ffff", "p": 1}
                    ],
                    "points": {
                        "x0": 0.5, "y0": 0.5,
                        "x1": 1, "y1": 1
                    }
                }
                """##)
            ),
            // Conic gradient
            (
                Value(
                    customId: nil,
                    kind: .conic,
                    start: .init(x: 0.5, y: 0.5),
                    end: .init(x: 1, y: 0.5),
                    items: [
                        .init(color: .init(customId: nil, data: 0xFF0000FF), p: 0),
                        .init(color: .init(customId: nil, data: 0x0000FFFF), p: 1),
                    ]
                ),
                Json(##"""
                {
                    "type": "conic-gradient",
                    "values": [
                        {"color": "#ff0000ff", "p": 0},
                        {"color": "#0000ffff", "p": 1}
                    ],
                    "points": {
                        "x0": 0.5, "y0": 0.5,
                        "x1": 1, "y1": 0.5
                    }
                }
                """##)
            ),
            // With custom_id
            (
                Value(
                    customId: "my_gradient",
                    kind: .linear,
                    start: .init(x: 0, y: 0),
                    end: .init(x: 1, y: 1),
                    items: [
                        .init(color: .init(customId: nil, data: 0x000000FF), p: 0),
                        .init(color: .init(customId: nil, data: 0xFFFFFFFF), p: 1),
                    ]
                ),
                Json(##"""
                {
                    "type": "linear-gradient",
                    "custom_id": "my_gradient",
                    "values": [
                        {"color": "#000000ff", "p": 0},
                        {"color": "#ffffffff", "p": 1}
                    ],
                    "points": {
                        "x0": 0, "y0": 0,
                        "x1": 1, "y1": 1
                    }
                }
                """##)
            ),
            // Empty values array
            (
                Value(
                    customId: nil,
                    kind: .linear,
                    start: .init(x: 0, y: 0),
                    end: .init(x: 1, y: 0),
                    items: []
                ),
                Json(##"""
                {
                    "type": "linear-gradient",
                    "values": [],
                    "points": {
                        "x0": 0, "y0": 0,
                        "x1": 1, "y1": 0
                    }
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing type
            Json(##"""
            {
                "values": [
                    {"color": "#ff0000ff", "p": 0}
                ],
                "points": {
                    "x0": 0, "y0": 0,
                    "x1": 1, "y1": 1
                }
            }
            """##),
            // Missing values
            Json(##"""
            {
                "type": "linear-gradient",
                "points": {
                    "x0": 0, "y0": 0,
                    "x1": 1, "y1": 1
                }
            }
            """##),
            // Missing points
            Json(##"""
            {
                "type": "linear-gradient",
                "values": [
                    {"color": "#ff0000ff", "p": 0}
                ]
            }
            """##),
            // Invalid type
            Json(##"""
            {
                "type": "unknown",
                "values": [],
                "points": {
                    "x0": 0, "y0": 0,
                    "x1": 1, "y1": 1
                }
            }
            """##),
            // Empty object
            Json(##"{}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid gradient", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
//            #expect(decoded.kind == value.kind)
//            #expect(decoded.start == value.start)
//            #expect(decoded.end == value.end)
//            #expect(decoded.items == value.items)
//            #expect(decoded.customId == value.customId)
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) throws {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode produces correct structure", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            let obj = try #require(encoded.deserilized as? [String: Any])
            #expect(obj["type"] as? String == value.kind.rawValue)
            #expect(obj["custom_id"] as? String == value.customId)
            let values = obj["values"] as? [Any]
            #expect(values?.count == value.items.count)
            let points = try #require(obj["points"] as? [String: Any])
            #expect(points["x0"] as? Double == value.start.x)
            #expect(points["y0"] as? Double == value.start.y)
            #expect(points["x1"] as? Double == value.end.x)
            #expect(points["y1"] as? Double == value.end.y)
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
