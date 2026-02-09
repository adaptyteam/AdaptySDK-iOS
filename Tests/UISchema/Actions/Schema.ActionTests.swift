//
//  Schema.ActionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

extension SchemaTests {
    @Suite("Schema.Action Tests")
    struct ActionTests {
        typealias Value = Schema.Action

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Minimal — func only, defaults
            (
                Value(
                    path: ["doSomething"],
                    params: nil,
                    scope: .screen
                ),
                Json(##"{"func":"doSomething"}"##)
            ),
            // Dotted func path
            (
                Value(
                    path: ["SDK", "openUrl"],
                    params: nil,
                    scope: .screen
                ),
                Json(##"{"func":"SDK.openUrl"}"##)
            ),
            // With params
            (
                Value(
                    path: ["SDK", "openUrl"],
                    params: ["url": .string("example_com")],
                    scope: .screen
                ),
                Json(##"""
                {
                    "func": "SDK.openUrl",
                    "params": {
                        "url": "example_com"
                    }
                }
                """##)
            ),
            // With scope global
            (
                Value(
                    path: ["doSomething"],
                    params: nil,
                    scope: .global
                ),
                Json(##"""
                {
                    "func": "doSomething",
                    "scope": "global"
                }
                """##)
            ),
            // With scope screen (explicit)
            (
                Value(
                    path: ["doSomething"],
                    params: nil,
                    scope: .screen
                ),
                Json(##"""
                {
                    "func": "doSomething",
                    "scope": "screen"
                }
                """##)
            ),
            // Full — all fields
            (
                Value(
                    path: ["SDK", "openUrl"],
                    params: ["url": .string("example_com")],
                    scope: .global
                ),
                Json(##"""
                {
                    "func": "SDK.openUrl",
                    "params": {
                        "url": "example_com"
                    },
                    "scope": "global"
                }
                """##)
            ),
            // Multiple params
            (
                Value(
                    path: ["SDK", "webPurchaseProduct"],
                    params: [
                        "productId": .string("premium"),
                        "openIn": .string("browser_out_app"),
                    ],
                    scope: .global
                ),
                Json(##"""
                {
                    "func": "SDK.webPurchaseProduct",
                    "params": {
                        "productId": "premium",
                        "openIn": "browser_out_app"
                    },
                    "scope": "global"
                }
                """##)
            ),
            // Deep path
            (
                Value(
                    path: ["a", "b", "c"],
                    params: nil,
                    scope: .screen
                ),
                Json(##"{"func": "a.b.c"}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing both "func" and "type"
            Json(##"{}"##),
            // Empty func
            Json(##"{"func": ""}"##),
            // func is only dots
            Json(##"{"func": "."}"##),
            // Unknown legacy type
            Json(##"{"type": "unknown_action"}"##),
            // Legacy open_url without url
            Json(##"{"type": "open_url"}"##),
            // Legacy custom without custom_id
            Json(##"{"type": "custom"}"##),
            // Legacy purchase_product without product_id
            Json(##"{"type": "purchase_product"}"##),
            // Legacy switch without section_id
            Json(##"""
            {
                "type": "switch",
                "index": 1
            }
            """##),
            // Legacy switch without index
            Json(##"""
            {
                "type": "switch",
                "section_id": "tabs"
            }
            """##),
            // Not an object
            Json(##""string""##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid action (new format)", arguments: jsonCases)
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

        @Test("encode produces correct structure", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            let obj = try #require(encoded.deserilized as? [String: Any])
            #expect(obj["func"] as? String == value.path.joined(separator: "."))

            if let params = value.params, !params.isEmpty {
                #expect(obj["params"] is [String: Any])
            } else {
                #expect(obj["params"] == nil)
            }

            if value.scope != .screen {
                #expect(obj["scope"] as? String == value.scope.rawValue)
            } else {
                #expect(obj["scope"] == nil)
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
