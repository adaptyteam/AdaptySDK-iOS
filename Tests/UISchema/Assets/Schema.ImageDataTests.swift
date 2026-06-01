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
    struct ImageDataTests {
        typealias Value = Schema.ImageData

        // MARK: - Helpers

        /// base64 "SGVsbG8="
        static let SGVsbG8_ = Data("Hello".utf8)
        /// base64 "UHJldmlldw=="
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
            // Missing both value and url
            Json(##"""
            {
            }
            """##),
            // Empty value and no url
            Json(##"""
            {
                "value": ""
            }
            """##),
            // Invalid base64 in value
            Json(##"""
            {
                "value": "@@@"
            }
            """##),
            // Invalid base64 in preview_value
            Json(##"""
            {
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
    }
}
