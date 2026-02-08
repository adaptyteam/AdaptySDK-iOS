//
//  Schema.VideoDataTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.VideoData Tests")
    struct SchemaVideoDataTests {
        typealias Value = Schema.VideoData
        typealias ImageData = Schema.ImageData

        // MARK: - Helpers

        static let https_example_com_video_mp4 = URL(string: "https://example.com/video.mp4")!
        static let SGVsbG8_ = Data("Hello".utf8)

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // Video with raster image
            (
                Value(
                    customId: nil,
                    url: https_example_com_video_mp4,
                    image: .raster(customId: nil, SGVsbG8_)
                ),
                Json(##"""
                {
                    "type": "video",
                    "url": "https://example.com/video.mp4",
                    "image": { "type": "image", "value": "SGVsbG8=" }
                }
                """##)
            ),
            // Video with URL image (no preview)
            (
                Value(
                    customId: nil,
                    url: https_example_com_video_mp4,
                    image: .raster(customId: nil, SGVsbG8_)
                ),
                Json(##"""
                {
                    "type": "video",
                    "url": "https://example.com/video.mp4",
                    "image": { "type": "image", "value": "SGVsbG8=" }
                }
                """##)
            ),
            // Video with custom_id
            (
                Value(
                    customId: "my_video",
                    url: https_example_com_video_mp4,
                    image: .raster(customId: nil, SGVsbG8_)
                ),
                Json(##"""
                {
                    "type": "video",
                    "custom_id": "my_video",
                    "url": "https://example.com/video.mp4",
                    "image": { "type": "image", "value": "SGVsbG8=" },
                }
                """##)
            ),
            // Video with type field present (ignored during decoding)
            (
                Value(
                    customId: nil,
                    url: https_example_com_video_mp4,
                    image: .raster(customId: nil, SGVsbG8_)
                ),
                Json(##"""
                {
                    "type": "video",
                    "url": "https://example.com/video.mp4",
                    "image": { "type": "image", "value": "SGVsbG8=" }
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Missing url
            Json(##"""
            {
                "type": "video",
                "image": { "type": "image", "value": "SGVsbG8=" }
            }
            """##),
            // Missing image
            Json(##"""
            {
                "type": "video",
                "url": "https://example.com/video.mp4"
            }
            """##),
            // Missing type
            Json(##"""
            {
                "url": "https://example.com/video.mp4",
                "image": { "type": "image", "value": "SGVsbG8=" }
            }
            """##),
            // Empty object
            Json(##"{}"##),
            // Only type field
            Json(##"""
            {
                "type": "video"
            }
            """##),
            // Invalid image (empty object)
            Json(##"""
            {
                "type": "video",
                "url": "https://example.com/video.mp4",
                "image": {}
            }
            """##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid video data", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode invalid JSON throws error", .tags(.debug), arguments: invalidJsons)
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
            #expect(obj["type"] as? String == "video")
            #expect(obj["custom_id"] as? String == value.customId)
            #expect(obj["url"] as? String == value.url.absoluteString)
            let image = try #require(obj["image"] as? [String: Any])
            #expect(image["type"] as? String == "image")
        }

        // MARK: - Roundtrip Tests

        @Test("encode → decode roundtrip", arguments: jsonCases.map(\.value))
        func roundtrip(value: Value) throws {
            let decoded = try Json.encode(value).decode(Value.self)
            #expect(decoded == value)
        }
    }
}
