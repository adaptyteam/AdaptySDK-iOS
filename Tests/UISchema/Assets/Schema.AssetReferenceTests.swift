//
//  Schema.AssetReferenceTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.AssetReference Tests")
    struct AssetReferenceTests {
        typealias Value = Schema.AssetReference
        typealias Variable = Schema.Variable

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Asset ID — plain string
            (
                .assetId("my_color"),
                Json(##""my_color""##)
            ),
            (
                .assetId("image_123"),
                Json(##""image_123""##)
            ),
            // Empty string is a valid asset ID
            (
                .assetId(""),
                Json(##""""##)
            ),
            // Inline hex color — 6-digit
            (
                .color(Schema.Color(customId: nil, data: 0xFF0000FF)),
                Json(##""#FF0000""##)
            ),
            // Inline hex color — 8-digit with alpha
            (
                .color(Schema.Color(customId: nil, data: 0x00FF0080)),
                Json(##""#00ff0080""##)
            ),
            // Variable reference — dotted path
            (
                .variable(Variable(path: ["some", "path"], setter: nil, scope: .screen)),
                Json(##"{"var":"some.path"}"##)
            ),
            // Variable reference — single segment
            (
                .variable(Variable(path: ["color"], setter: nil, scope: .screen)),
                Json(##"{"var":"color"}"##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Number
            Json(##"123"##),
            // Boolean
            Json(##"true"##),
            // Array
            Json(##"[1,2]"##),
            // Object without "var" key
            Json(##"{"key":"value"}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid asset reference", arguments: jsonCases)
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
            switch value {
            case .assetId(let id):
                let str = try #require(encoded.deserilized as? String)
                #expect(str == id)
            case .color(let color):
                let str = try #require(encoded.deserilized as? String)
                #expect(str == color.rawValue)
            case .variable(let variable):
                let obj = try #require(encoded.deserilized as? [String: Any])
                #expect(obj["var"] as? String == variable.path.joined(separator: "."))
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
