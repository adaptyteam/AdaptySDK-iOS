//
//  DataAssetTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 31.08.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Assets"),
    .feature("Custom Data Asset"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit),
    .tags(.codable)
)
enum DataAssetTests {
    @Suite(
        "Data Asset Parsing",
        .story("Data Asset Parsing")
    )
    struct DataAssetParsingTests {
        /// Inline data is decoded from a UIBuilder configuration. Every byte, the opaque format, and the custom identifier are preserved.
        @Test("Inline data preserves bytes and metadata")
        func inlineDataPreservesBytesAndMetadata() throws {
            let asset = try DataAssetTests.dataAsset(Json(
                ##"""
                {
                  "id": "asset",
                  "type": "data",
                  "custom_id": "chart",
                  "format": "Application/Vnd.Example+Binary;Version=2",
                  "value": "AAECAwQ="
                }
                """##
            ))

            #expect(asset.customId == "chart")
            #expect(asset.format == "Application/Vnd.Example+Binary;Version=2")
            #expect(asset.value == Data([0x00, 0x01, 0x02, 0x03, 0x04]))
            #expect(asset.url == nil)
        }

        /// An explicitly present empty Base64 string is decoded from a UIBuilder configuration. It remains a present source with an empty Data value.
        @Test("Empty inline data remains present")
        func emptyInlineDataRemainsPresent() throws {
            let asset = try DataAssetTests.dataAsset(Json(
                ##"""
                {
                  "id": "asset",
                  "type": "data",
                  "format": "application/octet-stream",
                  "value": ""
                }
                """##
            ))

            #expect(asset.value == Data())
            #expect(asset.url == nil)
        }

        /// A URL data asset is decoded from a UIBuilder configuration. Its URL and format are preserved without an inline value.
        @Test("URL data preserves its source and format")
        func urlDataPreservesSourceAndFormat() throws {
            let asset = try DataAssetTests.dataAsset(Json(
                ##"""
                {
                  "id": "asset",
                  "type": "data",
                  "format": "com.example.scene.v1",
                  "url": "https://cdn.example.com/scene.riv"
                }
                """##
            ))

            #expect(asset.format == "com.example.scene.v1")
            #expect(asset.value == nil)
            #expect(asset.url == URL(string: "https://cdn.example.com/scene.riv"))
        }

        /// Both sources are decoded from one asset. Inline bytes, including an empty payload, coexist with the URL without losing metadata.
        @Test("Inline data and URL are both preserved", arguments: [
            Data([0x00, 0x01, 0x02, 0xFE, 0xFF]),
            Data(),
        ])
        func inlineDataAndURLAreBothPreserved(value: Data) throws {
            let asset = try DataAssetTests.dataAsset(Json(deserilized: [
                "id": "asset",
                "type": "data",
                "custom_id": "animation",
                "format": "Application/Vnd.Example+Binary;Version=2",
                "value": value.base64EncodedString(),
                "url": "https://cdn.example.com/animation.json",
            ]))

            #expect(asset.value == value)
            #expect(asset.url == URL(string: "https://cdn.example.com/animation.json"))
            #expect(asset.customId == "animation")
            #expect(asset.format == "Application/Vnd.Example+Binary;Version=2")
        }

        /// Inline bytes that form a JSON document are decoded from a UIBuilder configuration. They remain bytes and are never converted to VC.AnyValue.
        @Test("Inline JSON remains raw data")
        func inlineJSONRemainsRawData() throws {
            let expected = Data(#"{"answer":42}"#.utf8)
            let asset = try DataAssetTests.dataAsset(Json(
                ##"""
                {
                  "id": "asset",
                  "type": "data",
                  "format": "application/json",
                  "value": "eyJhbnN3ZXIiOjQyfQ=="
                }
                """##
            ))

            #expect(asset.value == expected)
            #expect(asset.url == nil)
        }
    }

    @Suite(
        "Data Asset Validation",
        .story("Data Asset Validation")
    )
    struct DataAssetValidationTests {
        /// A UIBuilder configuration contains a data asset with an invalid format or source combination. Schema decoding rejects the configuration.
        @Test("Invalid data assets are rejected", arguments: [
            Json(##"{"id":"asset","type":"data","value":"AA=="}"##),
            Json(##"{"id":"asset","type":"data","format":"","value":"AA=="}"##),
            Json(##"{"id":"asset","type":"data","format":null,"value":"AA=="}"##),
            Json(##"{"id":"asset","type":"data","format":1,"value":"AA=="}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data"}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":null}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","url":null}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":42}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","url":42}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","url":""}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","url":"https://["}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"%%%"}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"AA==\n"}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":null,"url":"https://example.com/data"}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":42,"url":"https://example.com/data"}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"%%%","url":"https://example.com/data"}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"AA==","url":null}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"AA==","url":42}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"AA==","url":""}"##),
            Json(##"{"id":"asset","type":"data","format":"com.example.data","value":"AA==","url":"https://["}"##),
        ])
        func invalidDataAssetsAreRejected(asset: Json) {
            #expect(throws: (any Error).self, "Expected invalid data asset: \(asset)") {
                try DataAssetTests.configuration(asset: asset)
            }
        }

        /// A malformed known data asset contains a fallback identifier. Schema decoding fails instead of resolving the fallback.
        @Test("Malformed data does not use fallback")
        func malformedDataDoesNotUseFallback() {
            #expect(throws: (any Error).self) {
                try DataAssetTests.configuration(assets: Json(
                    ##"""
                    [
                      {
                        "id": "fallback",
                        "type": "color",
                        "value": "#FF0000"
                      },
                      {
                        "id": "asset",
                        "type": "data",
                        "format": "com.example.data",
                        "fallback_asset_id": "fallback"
                      }
                    ]
                    """##
                ))
            }
        }
    }

    @Suite(
        "Data Asset Integration",
        .story("Data Asset Integration")
    )
    struct DataAssetIntegrationTests {
        /// A configuration contains a data asset and an unknown asset with a fallback. Data is stored without rendering while the unknown asset resolves as before.
        @Test("Configuration stores data and resolves unknown fallback")
        func configurationStoresDataAndResolvesUnknownFallback() throws {
            let configuration = try DataAssetTests.configuration(assets: Json(
                ##"""
                [
                  {
                    "id": "fallback",
                    "type": "color",
                    "value": "#FF0000"
                  },
                  {
                    "id": "future",
                    "type": "future-data",
                    "fallback_asset_id": "fallback"
                  },
                  {
                    "id": "payload",
                    "type": "data",
                    "custom_id": "custom-payload",
                    "format": "com.example.data",
                    "value": "AAE="
                  }
                ]
                """##
            ))

            guard case let .solidColor(fallback)? = configuration.assets["future"] else {
                Issue.record("Expected an unknown asset to resolve to its color fallback")
                return
            }
            #expect(fallback.data == 0xFF0000FF)

            guard case let .data(payload)? = configuration.assets["payload"] else {
                Issue.record("Expected a stored data asset")
                return
            }
            #expect(payload.customId == "custom-payload")
            #expect(payload.value == Data([0x00, 0x01]))
            #expect(payload.url == nil)
        }

        /// A configuration contains every existing asset discriminator. Each asset remains recognized after adding the data case.
        @Test("Existing asset types remain recognized")
        func existingAssetTypesRemainRecognized() throws {
            guard case .solidColor = try DataAssetTests.asset(Json(
                ##"{"id":"asset","type":"color","value":"#FF0000"}"##
            )) else {
                Issue.record("Expected a color asset")
                return
            }
            guard case .colorGradient = try DataAssetTests.asset(Json(
                ##"{"id":"asset","type":"linear-gradient","values":[{"color":"#FF0000","p":0},{"color":"#0000FF","p":1}],"points":{"x0":0,"y0":0,"x1":1,"y1":1}}"##
            )) else {
                Issue.record("Expected a gradient asset")
                return
            }
            guard case .font = try DataAssetTests.asset(Json(
                ##"{"id":"asset","type":"font","value":"Helvetica"}"##
            )) else {
                Issue.record("Expected a font asset")
                return
            }
            guard case .image = try DataAssetTests.asset(Json(
                ##"{"id":"asset","type":"image","value":"SGVsbG8="}"##
            )) else {
                Issue.record("Expected an image asset")
                return
            }
            guard case .video = try DataAssetTests.asset(Json(
                ##"{"id":"asset","type":"video","url":"https://example.com/video.mp4","image":{"type":"image","value":"SGVsbG8="}}"##
            )) else {
                Issue.record("Expected a video asset")
                return
            }
        }
    }
}

private extension DataAssetTests {
    static func dataAsset(_ json: Json) throws -> VC.DataAsset {
        guard case let .data(asset) = try asset(json) else {
            Issue.record("Expected a data asset")
            throw TestError.expectedDataAsset
        }
        return asset
    }

    static func asset(_ json: Json) throws -> VC.Asset {
        let configuration = try configuration(asset: json)
        guard let asset = configuration.assets["asset"] else {
            Issue.record("Expected a known asset")
            throw TestError.expectedKnownAsset
        }
        return asset
    }

    static func configuration(asset: Json) throws -> AdaptyUIConfiguration {
        try configuration(assets: Json(deserilized: [asset.deserilized]))
    }

    static func configuration(assets: Json) throws -> AdaptyUIConfiguration {
        let json = try Json(deserilized: [
            "format": "5.2.0",
            "assets": assets.deserilized,
            "screens": [String: Any](),
            "scripts": [Any](),
        ])
        let schema = try AdaptyUISchema(
            from: json.data,
            configuration: .init(device: .phone)
        )

        return try schema.extractUIConfiguration(
            id: "data-asset-test",
            withLocaleId: "en",
            envoriment: .dataAssetTest
        )
    }

    enum TestError: Error {
        case expectedKnownAsset
        case expectedDataAsset
    }
}

private extension VC.EnvironmentConstants {
    static let dataAssetTest = Self(
        sdkVersion: "test",
        osName: "test",
        osVersion: "test",
        deviceModel: "test",
        appBundleId: nil,
        appVersion: nil,
        appBuild: nil,
        appCurrentLocale: nil,
        userLocales: [],
        userUses24HourClock: true,
        flow: .init(
            placementId: "test",
            variationId: "test",
            abTestName: "test",
            name: "test",
            products: []
        )
    )
}
