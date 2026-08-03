//
//  PlacementFallbackSelectionTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 03.08.2026.
//

#if canImport(Testing)

@testable import Adapty
import Foundation
import Testing

extension ResponseCacheTests {
    @Suite("placement fallback selection")
    struct PlacementFallbackSelectionTests {
        @Test
        func newest_placement_source_wins() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let cases = [
                SelectionCase(cacheVersion: 10, fallbackVersion: 20, expectedSource: .fallback),
                SelectionCase(cacheVersion: 20, fallbackVersion: 20, expectedSource: .cache),
                SelectionCase(cacheVersion: 30, fallbackVersion: 20, expectedSource: .cache),
            ]

            for testCase in cases {
                let id = UUID().uuidString
                let placementId = "placement-\(id)"
                let userId = AdaptyUserId(profileId: "profile-\(id)", customerId: nil)
                let cacheData = placementResponse(
                    placementId: placementId,
                    version: testCase.cacheVersion,
                    source: .cache
                )

                try await Cache.write(
                    cacheData,
                    key: AdaptyFlow.cacheKey(placementId: placementId, for: userId),
                    dataVersion: testCase.cacheVersion
                )

                let fallback = try makeFallback(
                    at: root.appendingPathComponent("fallback-\(id).json"),
                    placementId: placementId,
                    version: testCase.fallbackVersion,
                    source: .fallback
                )

                let draw: AdaptyPlacement.Draw<AdaptyFlow>? = await Cache.read(
                    AdaptyFlow.self,
                    placementId: placementId,
                    locale: nil,
                    fetchPolicy: .returnCacheDataElseLoad,
                    for: userId,
                    fallbackFile: fallback
                )

                #expect(
                    draw?.content.name == testCase.expectedSource.rawValue,
                    "cache=\(testCase.cacheVersion), fallback=\(testCase.fallbackVersion)"
                )
            }
        }

        @Test
        func cached_placement_is_used_when_newer_fallback_cannot_be_decoded() async throws {
            let root = await prepareCacheTest()
            defer { cleanupCacheTest(root) }

            let id = UUID().uuidString
            let placementId = "placement-\(id)"
            let userId = AdaptyUserId(profileId: "profile-\(id)", customerId: nil)
            let cacheData = placementResponse(
                placementId: placementId,
                version: 10,
                source: .cache
            )

            try await Cache.write(
                cacheData,
                key: AdaptyFlow.cacheKey(placementId: placementId, for: userId),
                dataVersion: 10
            )

            let fallback = try makeFallback(
                at: root.appendingPathComponent("fallback-\(id).json"),
                placementId: placementId,
                version: 20,
                source: .fallback,
                isValidFlow: false
            )

            let draw: AdaptyPlacement.Draw<AdaptyFlow>? = await Cache.read(
                AdaptyFlow.self,
                placementId: placementId,
                locale: nil,
                fetchPolicy: .returnCacheDataElseLoad,
                for: userId,
                fallbackFile: fallback
            )

            #expect(draw?.content.name == Source.cache.rawValue)
            #expect(draw?.content.placement.version == 10)
        }

        @Test
        func fallback_without_requested_variation_returns_nil() throws {
            let directory = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: directory) }

            let placementId = "placement"
            let fallback = try makeFallback(
                at: directory.appendingPathComponent("fallback.json"),
                placementId: placementId,
                version: 20,
                source: .fallback
            )

            let draw: AdaptyPlacement.Draw<AdaptyFlow>? = try fallback.getPlacement(
                AdaptyFlow.self,
                byPlacementId: placementId,
                withVariationId: "missing-variation",
                userId: AdaptyUserId(profileId: "profile", customerId: nil),
                requestLocale: nil
            )

            #expect(draw == nil)
        }
    }
}

private extension ResponseCacheTests.PlacementFallbackSelectionTests {
    enum Source: String {
        case cache
        case fallback
    }

    struct SelectionCase {
        let cacheVersion: Int
        let fallbackVersion: Int
        let expectedSource: Source
    }

    func makeFallback(
        at fileURL: URL,
        placementId: String,
        version: Int,
        source: Source,
        isValidFlow: Bool = true
    ) throws -> FallbackPlacements {
        let json = """
        {
          "meta": {
            "version": \(Adapty.fallbackFormatVersion),
            "response_created_at": \(version),
            "developer_ids": ["\(placementId)"]
          },
          "data": {
            "\(placementId)": \(placementResponseJSON(
                placementId: placementId,
                version: version,
                source: source,
                isValidFlow: isValidFlow
            ))
          }
        }
        """

        try Data(json.utf8).write(to: fileURL)
        return try FallbackPlacements(fileURL: fileURL)
    }

    func placementResponse(
        placementId: String,
        version: Int,
        source: Source
    ) -> Data {
        Data(placementResponseJSON(
            placementId: placementId,
            version: version,
            source: source
        ).utf8)
    }

    func placementResponseJSON(
        placementId: String,
        version: Int,
        source: Source,
        isValidFlow: Bool = true
    ) -> String {
        let flowId = isValidFlow ? "\"flow_id\": \"flow-\(source.rawValue)\"," : ""

        return """
        {
          "meta": {
            "placement": {
              "developer_id": "\(placementId)",
              "audience_name": "audience",
              "placement_audience_version_id": "audience-version",
              "revision": 1,
              "ab_test_name": "ab-test"
            },
            "response_created_at": \(version)
          },
          "data": [
            {
              "variation_id": "variation-\(source.rawValue)",
              "weight": 100,
              \(flowId)
              "flow_name": "\(source.rawValue)",
              "variations": []
            }
          ]
        }
        """
    }
}

#endif
