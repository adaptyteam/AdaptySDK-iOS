//
//  SimdjsonExtractTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 08.04.2026.
//

@testable import AdaptyCodable
import Testing

struct SimdjsonExtractTests {
    let testJSON = """
    {
        "meta": { "version": 1 },
        "placements": {
            "onboarding": {
                "variations": [
                    {
                        "weight": 0.5,
                        "paywall": {
                            "id": "paywall_a",
                            "ui_schema": { "type": "fullscreen" }
                        }
                    },
                    {
                        "weight": 0.5,
                        "paywall": {
                            "id": "paywall_b",
                            "ui_schema": { "type": "bottom_sheet" }
                        }
                    }
                ]
            }
        }
    }
    """.data(using: .utf8)!

    @Test func extractPlacement() throws {
        let extractor = SimdjsonExtractor(data: testJSON)
        let fragment = try extractor.extract(pointer: "/placements/onboarding")

        // Должен содержать variations
        let str = try #require(String(data: fragment, encoding: .utf8))
        #expect(str.contains("variations"))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractNestedValue() throws {
        let extractor = SimdjsonExtractor(data: testJSON)
        let fragment = try extractor.extract(
            pointer: "/placements/onboarding/variations/0/paywall/id"
        )

        let str = try #require(String(data: fragment, encoding: .utf8))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractMeta() throws {
        let extractor = SimdjsonExtractor(data: testJSON)

        struct Meta: Codable { let version: Int }
        let meta: Meta = try extractor.decode(at: "/meta", as: Meta.self)
        #expect(meta.version == 1)
    }

    @Test func pathNotFoundThrows() throws {
        let extractor = SimdjsonExtractor(data: testJSON)
        #expect(throws: SimdjsonError.self) {
            try extractor.extract(pointer: "/placements/nonexistent")
        }
    }

    @Test func extractMany() throws {
        let extractor = SimdjsonExtractor(data: testJSON)
        let results = try extractor.extractMany(pointers: [
            "/meta",
            "/placements/onboarding/variations/0/paywall/id",
        ])
        #expect(results.count == 2)
    }
}

