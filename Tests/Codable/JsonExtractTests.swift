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
    private struct Entity: Codable {
        let meta: Meta
        let placements: [Placement]

        struct Meta: Codable {
            let version: Int
        }

        struct Placement: Codable {
            let onboarding: Onboarding
        }

        struct Onboarding: Codable {
            let variations: [Variation]
        }

        struct Variation: Codable {
            let weight: Double
            let paywall: Paywall
        }

        struct Paywall: Codable {
            let id: String
            let schema: Schema
        }

        struct Schema: Codable {
            let type: String
        }
    }

    private let JSON = """
    {
        "meta": {
            "version": 1
        },
        "placements": [
            {
                "onboarding": {
                    "variations": [
                        {
                            "weight": 0.5,
                            "paywall": {
                                "id": "paywall_a",
                                "schema": {
                                    "type": "fullscreen"
                                }
                            }
                        },
                        {
                            "weight": 0.5,
                            "paywall": {
                                "id": "paywall_b",
                                "schema": {
                                    "type": "bottom_sheet"
                                }
                            }
                        }
                    ]
                }
            }
        ]
    }
    """.data(using: .utf8)!

    @Test func extractPlacement() throws {
        let data = try JSON.jsonExtract(pointer: "/placements/0/onboarding")
        let str = try #require(String(data: data, encoding: .utf8))
        #expect(str.contains("variations"))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractNestedValue() throws {
        let data = try JSON.jsonExtract(
            pointer: "/placements/0/onboarding/variations/0/paywall/id"
        )
        let str = try #require(String(data: data, encoding: .utf8))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractPaywall() throws {
        let decoder = JSONDecoder()
        let paywall = try decoder.decode(
            Entity.Paywall.self,
            from: JSON.jsonExtract(pointer: "/placements/0/onboarding/variations/1/paywall")
        )
        #expect(paywall.id == "paywall_b")
        #expect(paywall.schema.type == "bottom_sheet")
    }

    @Test func dataIsEmptyThrows() throws {
        #expect {
            try Data().jsonExtract(pointer: "/placements/0")
        } throws: { error in
            if let e = error as? JsonExtractError,
               case .dataIsEmpty = e
            {
                true
            } else {
                false
            }
        }
    }

    @Test func pathNotFoundThrows() throws {
        #expect {
            try JSON.jsonExtract(pointer: "/placements/0/nonexistent")
        } throws: { error in
            if let e = error as? JsonExtractError,
               case let .pathNotFound(path) = e,
               path == "/placements/0/nonexistent"
            {
                true
            } else {
                false
            }
        }
    }

    @Test func extractMany() throws {
        let results = try JSON.jsonExtractMany(pointers: [
            "/meta",
            "/placements/0/onboarding/variations/0/paywall",
        ])
        #expect(results.count == 2)
        let jsonMeta = try #require(results["/meta"])
        let jsonPaywall = try #require(results["/placements/0/onboarding/variations/0/paywall"])

        let decoder = JSONDecoder()

        let meta = try decoder.decode(Entity.Meta.self, from: jsonMeta)
        #expect(meta.version == 1)

        let paywall = try decoder.decode(Entity.Paywall.self, from: jsonPaywall)
        #expect(paywall.id == "paywall_a")
        #expect(paywall.schema.type == "fullscreen")
    }
}

