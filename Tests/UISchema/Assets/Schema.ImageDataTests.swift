//
//  Schema.ImageDataTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.ImageData Tests")
    struct ImageDataTests {
        typealias Value = Schema.ImageData

        // MARK: - Helpers

        // base64 "SGVsbG8="
        static let SGVsbG8_ = Data("Hello".utf8)
        // base64 "UHJldmlldw=="
        static let UHJldmlldw__ = Data("Preview".utf8)

        static let https_example_com_image_png = URL(string: "https://example.com/image.png")!

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Raster image (inline base64)
            (
                .raster(customId: nil, SGVsbG8_),
                Json(##"""
                {
                    "type": "image",
                    "value": "SGVsbG8="
                }
                """##)
            ),
            // Raster with custom_id
            (
                .raster(customId: "my_image", SGVsbG8_),
                Json(##"""
                {
                    "type": "image",
                    "custom_id": "my_image",
                    "value": "SGVsbG8="
                }
                """##)
            ),
            // URL image without preview
            (
                .url(customId: nil, https_example_com_image_png, previewRaster: nil),
                Json(##"""
                {
                    "type": "image",
                    "url": "https://example.com/image.png"
                }
                """##)
            ),
            // URL image with preview
            (
                .url(customId: nil, https_example_com_image_png, previewRaster: UHJldmlldw__),
                Json(##"""
                {
                    "type": "image",
                    "url": "https://example.com/image.png",
                    "preview_value": "UHJldmlldw=="
                }
                """##)
            ),
            // URL image with custom_id
            (
                .url(customId: "my_url_image", https_example_com_image_png, previewRaster: nil),
                Json(##"""
                {
                    "type": "image",
                    "custom_id": "my_url_image",
                    "url": "https://example.com/image.png"
                }
                """##)
            ),
            // URL image with preview and custom_id
            (
                .url(customId: "full", https_example_com_image_png, previewRaster: UHJldmlldw__),
                Json(##"""
                {
                    "type": "image",
                    "custom_id": "full",
                    "url": "https://example.com/image.png",
                    "preview_value": "UHJldmlldw=="
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing type
            Json(##"""
            {
                "value": "SGVsbG8="
            }
            """##),
            // Wrong type
            Json(##"""
            {
                "type": "wrong_image",
                "url": "https://example.com/image.png"
            }
            """##),
            // Missing both value and url
            Json(##"""
            {
                "type": "image"
            }
            """##),
            // Empty value and no url
            Json(##"""
            {
                "type": "image",
                "value": ""
            }
            """##),
            // Invalid base64 in value
            Json(##"""
            {
                "type": "image",
                "value": "@@@"
            }
            """##),
            // Invalid base64 in preview_value
            Json(##"""
            {
                "type": "image",
                "url": "https://example.com/image.png",
                "preview_value": "@@@"
            }
            """##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid image data", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
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
            #expect(obj["type"] as? String == "image")
            switch value {
            case let .raster(customId, rasterData):
                #expect(obj["custom_id"] as? String == customId)
                #expect(obj["value"] as? String == rasterData.base64EncodedString())
                #expect(obj["url"] == nil)
            case let .url(customId, url, previewRaster):
                #expect(obj["custom_id"] as? String == customId)
                #expect(obj["url"] as? String == url.absoluteString)
                #expect(obj["value"] == nil)
                if let previewRaster {
                    #expect(obj["preview_value"] as? String == previewRaster.base64EncodedString())
                } else {
                    #expect(obj["preview_value"] == nil)
                }
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
