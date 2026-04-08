//
//  JsonExtractTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 08.04.2026.
//

@testable import AdaptyCodable
import Foundation
import Testing

struct JsonExtractTests {
    let JSON = """
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
        let data = try JSON.jsonExtract(pointer: "/placements/onboarding")
        let str = try #require(String(data: data, encoding: .utf8))
        #expect(str.contains("variations"))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractNestedValue() throws {
        let data = try JSON.jsonExtract(
            pointer: "/placements/onboarding/variations/0/paywall/id"
        )
        let str = try #require(String(data: data, encoding: .utf8))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractMeta() throws {

        struct Meta: Codable { let version: Int }

        let decoder = JSONDecoder()
        let data = try JSON.jsonExtract(pointer: "/meta")
        let meta: Meta = try decoder.decode(Meta.self, from: data)
        #expect(meta.version == 1)
    }

    @Test func pathNotFoundThrows() throws {
        #expect(throws: JsonExtractError.self) {
            try JSON.jsonExtract(pointer: "/placements/nonexistent")
        }
    }

    @Test func extractMany() throws {
        let results = try JSON.jsonExtractMany(pointers: [
            "/meta",
            "/placements/onboarding/variations/0/paywall/id",
        ])
        #expect(results.count == 2)
    }
}

