//
//  KeyedDecodingContainerAnyTests.swift
//  AdaptyTests
//
//  Created by OpenAI on 20.09.2025.
//

@testable import AdaptyCodable
import Foundation
import Testing

struct KeyedDecodingContainerAnyTests {
    private struct RootDictionaryFixture: Decodable {
        let value: [String: Any]

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: AnyCodingKey.self)
            value = try container.decodeDictionary()
        }
    }

    private struct KeyedFixture: Decodable {
        let array: [Any]
        let dictionary: [String: Any]
        let any: Any?
        let missingArray: [Any]?
        let missingDictionary: [String: Any]?

        enum CodingKeys: String, CodingKey {
            case array
            case dictionary
            case any
            case missingArray
            case missingDictionary
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            array = try container.decodeArray(forKey: .array)
            dictionary = try container.decodeDictionary(forKey: .dictionary)
            any = try container.decodeAnyIfPresent(forKey: .any)
            missingArray = try container.decodeArrayIfPresent(forKey: .missingArray)
            missingDictionary = try container.decodeDictionaryIfPresent(forKey: .missingDictionary)
        }
    }

    @Test("decodeDictionary decodes nested values and skips nulls")
    func decodeDictionary() throws {
        let fixture = try Json(
            ##"""
            {
              "name": "adapty",
              "enabled": true,
              "count": 3,
              "nested": {
                "items": [1, "two", {"flag": true}, null],
                "label": "inner"
              },
              "empty": null
            }
            """##
        ).decode(RootDictionaryFixture.self)

        #expect(Json(deserilized: fixture.value) == Json(deserilized: [
            "count": 3,
            "enabled": true,
            "name": "adapty",
            "nested": [
                "items": [1, "two", ["flag": true]],
                "label": "inner",
            ],
        ]))
    }

    @Test("keyed helpers decode array dictionary and any values")
    func decodeKeyedHelpers() throws {
        let fixture = try Json(
            ##"""
            {
              "array": [1, "two", {"flag": true}, null],
              "dictionary": {
                "name": "value",
                "missing": null
              },
              "any": {
                "nested": ["x", 2]
              }
            }
            """##
        ).decode(KeyedFixture.self)

        #expect(Json(deserilized: fixture.array) == Json(deserilized: [
            1,
            "two",
            ["flag": true],
        ]))
        #expect(Json(deserilized: fixture.dictionary) == Json(deserilized: [
            "name": "value",
        ]))
        #expect(Json(deserilized: try #require(fixture.any)) == Json(deserilized: [
            "nested": ["x", 2],
        ]))
        #expect(fixture.missingArray == nil)
        #expect(fixture.missingDictionary == nil)
    }

    @Test("decodeAnyIfPresent returns nil for missing and null keys")
    func decodeAnyIfPresentNil() throws {
        struct Fixture: Decodable {
            let missing: Any?
            let empty: Any?

            enum CodingKeys: String, CodingKey {
                case missing
                case empty
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                missing = try container.decodeAnyIfPresent(forKey: .missing)
                empty = try container.decodeAnyIfPresent(forKey: .empty)
            }
        }

        let fixture = try Json(
            ##"""
            {
              "empty": null
            }
            """##
        ).decode(Fixture.self)

        #expect(fixture.missing == nil)
        #expect(fixture.empty == nil)
    }
}
