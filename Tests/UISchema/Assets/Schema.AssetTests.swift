//
//  Schema.AssetTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on2026-02-05.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

private extension SchemaTests {
    @Suite("Schema.Asset Tests")
    struct AssetTests {
        typealias Value = Schema.Asset

        // MARK: - Helpers

        static let defaultFontColor = Schema.Color(customId: nil, data: 0x000000FF)
        static let color_FF0000 = Schema.Color(customId: nil, data: 0xFF0000FF)
        static let color_0000FF = Schema.Color(customId: nil, data: 0x0000FFFF)
        static let SGVsbG8_ = Data("Hello".utf8)
        static let https_example_com_img_png = URL(string: "https://example.com/img.png")!
        static let https_example_com_video_mp4 = URL(string: "https://example.com/video.mp4")!

        // MARK: - Test Data

        static let jsonCases: [(value: Value, json: Json)] = [
            // solidColor
            (
                .solidColor(Schema.Color(customId: nil, data: 0xFF0000FF)),
                Json(##"""
                {
                    "type": "color",
                    "value": "#FF0000"
                }
                """##)
            ),
            // solidColor with custom_id
            (
                .solidColor(Schema.Color(customId: "my_red", data: 0xFF0000FF)),
                Json(##"""
                {
                    "type": "color",
                    "custom_id": "my_red",
                    "value": "#FF0000"
                }
                """##)
            ),
            // font
            (
                .font(Schema.Font(customId: nil, alias: "Helvetica", familyName: "adapty_system", weight: 400, italic: false, defaultSize: 15, defaultColor: defaultFontColor)),
                Json(##"""
                {
                    "type": "font",
                    "value": "Helvetica"
                }
                """##)
            ),
            // image — raster (base64)
            (
                .image(.raster(customId: nil, SGVsbG8_)),
                Json(##"""
                {
                    "type": "image",
                    "value": "SGVsbG8="
                }
                """##)
            ),
            // image — url
            (
                .image(.url(customId: nil, https_example_com_img_png, previewRaster: nil)),
                Json(##"""
                {
                    "type": "image",
                    "url": "https://example.com/img.png"
                }
                """##)
            ),
            // video
            (
                .video(Schema.VideoData(customId: nil, url: https_example_com_video_mp4, image: .raster(customId: nil, SGVsbG8_))),
                Json(##"""
                {
                    "type": "video",
                    "url": "https://example.com/video.mp4",
                    "image": {
                        "type": "image",
                        "value": "SGVsbG8="
                    }
                }
                """##)
            ),
            // linear-gradient
            (
                .colorGradient(Schema.ColorGradient(
                    customId: nil,
                    kind: .linear,
                    start: Schema.Point(x: 0, y: 0),
                    end: Schema.Point(x: 1, y: 1),
                    items: [
                        Schema.ColorGradient.Item(color: color_FF0000, p: 0),
                        Schema.ColorGradient.Item(color: color_0000FF, p: 1),
                    ]
                )),
                Json(##"""
                {
                    "type": "linear-gradient",
                    "values": [
                        { "color": "#FF0000", "p": 0 },
                        { "color": "#0000FF", "p": 1 }
                    ],
                    "points": { "x0": 0, "y0": 0, "x1": 1, "y1": 1 }
                }
                """##)
            ),
        ]

        static let invalidJsons: [Json] = [
            // Empty
            Json(##"{}"##),
            // Not an object
            Json(##""string""##),
            // Color without value
            Json(##"{"type":"color"}"##),
            // Font without value
            Json(##"{"type":"font"}"##),
            // Image without value or url
            Json(##"{"type":"image"}"##),
        ]

        // MARK: - Decoding Tests

        @Test("decode valid asset", arguments: jsonCases)
        func decode(value: Value, json: Json) throws {
            let decoded = try json.decode(Value.self)
            #expect(decoded == value)
        }

        @Test("decode unknown asset type")
        func decodeUnknownType() throws {
            let decoded = try Json(##"{"type":"something_new"}"##).decode(Value.self)
            if case .unknown = decoded {
                // Success
            } else {
                Issue.record("Expected .unknown case, got \(decoded)")
            }
        }

        @Test("decode invalid JSON throws error", arguments: invalidJsons)
        func decodeInvalid(invalid: Json) {
            #expect(throws: (any Error).self, "JSON should be invalid: \(invalid)") {
                try invalid.decode(Value.self)
            }
        }

        // MARK: - Encoding Tests

        @Test("encode produces correct type", arguments: jsonCases.map(\.value))
        func encode(value: Value) throws {
            let encoded = try Json.encode(value)
            let obj = try #require(encoded.deserilized as? [String: Any])
            switch value {
            case .solidColor(let color):
                #expect(obj["type"] as? String == "color")
                #expect(obj["custom_id"] as? String == color.customId)
                #expect(obj["value"] as? String == color.rawValue)
            case .colorGradient(let gradient):
                #expect(obj["type"] as? String == gradient.kind.rawValue)
                #expect(obj["custom_id"] as? String == gradient.customId)
            case .font:
                #expect(obj["type"] as? String == "font")
            case .image(let image):
                #expect(obj["type"] as? String == "image")
                #expect(obj["custom_id"] as? String == image.customId)
            case .video(let video):
                #expect(obj["type"] as? String == "video")
                #expect(obj["custom_id"] as? String == video.customId)
            case .unknown:
                break
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
