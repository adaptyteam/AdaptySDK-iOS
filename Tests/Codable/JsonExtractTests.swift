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
        let enabled: Bool
        let label: String
        let count: Int
        let empty: Empty?

        struct Meta: Codable {
            let version: Int
        }

        struct Empty: Codable {}

        struct Placement: Codable {
            let onboarding: Onboarding
            let settings: Onboarding
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
                },
                "settings": {
                    "variations": []
                }
            }
        ],
        "enabled": true,
        "label": "test",
        "count": 42,
        "empty":     null

    }
    """.data(using: .utf8)!

    // MARK: - jsonExtract

    @Test func extractPlacement() throws {
        let data = try JSON.jsonExtract(pointer: "/placements/0/onboarding")
        let str = try #require(String(data: data, encoding: .utf8))
        #expect(str.contains("variations"))
        #expect(str.contains("paywall_a"))
    }

    @Test func extractIfContainsNull() throws {
        let empty = try JSON.jsonExtractIfPresent(pointer: "/empty")
        #expect(empty == "null".data(using: .utf8)!)
    }

    @Test func extractIfExistNull() throws {
        let empty = try JSON.jsonExtractIfExist(pointer: "/empty")
        #expect(empty == nil)
    }

    @Test func decodeNull() throws {
        let decoder = JSONDecoder()
        let empty: Entity.Empty? = try decoder.decode(
            Entity.Empty?.self,
            from: JSON.jsonExtract(pointer: "/empty")
        )
        #expect(empty == nil)
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

    // MARK: - jsonExtractMany

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

    // MARK: - jsonContains

    @Test func containsFound() throws {
        #expect(try JSON.jsonContains(pointer: "/placements/0/onboarding") == true)
    }

    @Test func containsNotFound() throws {
        #expect(try JSON.jsonContains(pointer: "/placements/0/nonexistent") == false)
    }

    @Test func containsDeepPath() throws {
        #expect(try JSON.jsonContains(pointer: "/placements/0/onboarding/variations/0/paywall/id") == true)
    }

    @Test func containsEmptyDataThrows() throws {
        #expect {
            try Data().jsonContains(pointer: "/any")
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

    @Test func existFound() throws {
        let pointer = "/count"
        #expect(try JSON.jsonContains(pointer: pointer) == true)
        #expect(try JSON.jsonExist(pointer: pointer) == true)
    }

    @Test func existNotFound() throws {
        let pointer = "/empty"
        #expect(try JSON.jsonContains(pointer: pointer) == true)
        #expect(try JSON.jsonExist(pointer: pointer) == false)
    }

    @Test func nonexistentNotFound() throws {
        let pointer = "/nonexistent"
        #expect(try JSON.jsonContains(pointer: pointer) == false)
        #expect(try JSON.jsonExist(pointer: pointer) == false)
    }

    // MARK: - Inspect ( fast )

    @Test func typeObject() throws {
        #expect(try JSON.jsonFastInspect(pointer: "/meta") == .object(keys: []))
    }

    @Test func typeArray() throws {
        #expect(try JSON.jsonFastInspect(
            pointer: "/placements/0/onboarding/variations"
        ) == .array(count: 0))
    }

    @Test func typeString() throws {
        #expect(try JSON.jsonFastInspect(pointer: "/label") == .string)
    }

    @Test func typeNumber() throws {
        #expect(try JSON.jsonFastInspect(pointer: "/count") == .number)
    }

    @Test func typeBool() throws {
        #expect(try JSON.jsonFastInspect(pointer: "/enabled") == .bool)
    }

    @Test func typeNull() throws {
        #expect(try JSON.jsonFastInspect(pointer: "/empty") == .null)
    }

    @Test func typePathNotFound() throws {
        #expect {
            try JSON.jsonFastInspect(pointer: "/nonexistent")
        } throws: { error in
            guard let e = error as? JsonExtractError,
                  case let .pathNotFound(path) = e
            else {
                return false
            }
            return path == "/nonexistent"
        }
    }

    // MARK: - Inspect ( full )

    @Test func inspectObject() throws {
        let info = try JSON.jsonInspect(pointer: "/placements/0")
        #expect(info == .object(keys: ["onboarding", "settings"]))
    }

    @Test func inspectArray() throws {
        let info = try JSON.jsonInspect(pointer: "/placements/0/onboarding/variations")
        #expect(info == .array(count: 2))
    }

    @Test func inspectEmptyArray() throws {
        let info = try JSON.jsonInspect(pointer: "/placements/0/settings/variations")
        #expect(info == .array(count: 0))
    }

    @Test func inspectString() throws {
        let info = try JSON.jsonInspect(pointer: "/label")
        #expect(info == .string)
    }

    @Test func inspectNumber() throws {
        let info = try JSON.jsonInspect(pointer: "/count")
        #expect(info == .number)
    }

    @Test func inspectBool() throws {
        let info = try JSON.jsonInspect(pointer: "/enabled")
        #expect(info == .bool)
    }

    @Test func inspectNull() throws {
        let info = try JSON.jsonInspect(pointer: "/empty")
        #expect(info == .null)
    }

    @Test func inspectPathNotFound() throws {
        #expect {
            try JSON.jsonInspect(pointer: "/nonexistent")
        } throws: { error in
            guard let e = error as? JsonExtractError,
                  case let .pathNotFound(path) = e
            else {
                return false
            }
            return path == "/nonexistent"
        }
    }

    // MARK: - Range

    let simpleJSON = """
        {
            "name":  "Привет",
            "count":    42,
            "items":      
        [1,2,3]
        ,
            "empty": null
        }
        """
//        #"{"name":"Привет","count":42,"items":[1,2,3],"empty":null}"#

    @Test func rangeObjectProperty() throws {
        let jsonStr = simpleJSON
        let JSON = try #require(jsonStr.data(using: .utf8))

        let result = try JSON.jsonExtractRange(pointer: "/name")

        #expect(result.key != nil)

        let key = try #require(result.key(from: simpleJSON))
        #expect(key == "name")

        let value = try #require(result.value(from: simpleJSON))
        #expect(value == #""Привет""#)
    }

    @Test func rangeArrayElement() throws {
        let jsonStr = simpleJSON
        let JSON = try #require(jsonStr.data(using: .utf8))

        let result = try JSON.jsonExtractRange(pointer: "/items/1")

        #expect(result.key == nil)

        let value = try #require(result.value(from: simpleJSON))
        #expect(value == "2")
    }

    @Test func rangeNestedObject() throws {
        let jsonStr = simpleJSON
        let JSON = try #require(jsonStr.data(using: .utf8))

        let result = try JSON.jsonExtractRange(pointer: "/items")

        #expect(result.key != nil)

        let key = try #require(result.key(from: simpleJSON))
        #expect(key == "items")

        let value = try #require(result.value(from: simpleJSON))
        #expect(value == "[1,2,3]")
    }

    @Test func rangeNull() throws {
        let jsonStr = simpleJSON
        let JSON = try #require(jsonStr.data(using: .utf8))

        let result = try JSON.jsonExtractRange(pointer: "/empty")

        let key = try #require(result.key(from: simpleJSON))
        #expect(key == "empty")

        let value = try #require(result.value(from: simpleJSON))
        #expect(value == #"null"#)
    }

    @Test func rangeCyrillicKey() throws {
        let jsonStr = #"{"имя":"значение"}"#
        let JSON = try #require(jsonStr.data(using: .utf8))

        let result = try JSON.jsonExtractRange(pointer: "/имя")

        #expect(result.key != nil)

        let key = try #require(result.key(from: jsonStr))
        #expect(key == "имя")

        let value = try #require(result.value(from: jsonStr))
        #expect(value == #""значение""#)
    }

    @Test func rangePathNotFound() throws {
        let JSON = try #require(simpleJSON.data(using: .utf8))

        #expect {
            try JSON.jsonExtractRange(pointer: "/nonexistent")
        } throws: { error in
            if let e = error as? JsonExtractError,
               case .pathNotFound = e
            {
                true
            } else {
                false
            }
        }
    }
}

