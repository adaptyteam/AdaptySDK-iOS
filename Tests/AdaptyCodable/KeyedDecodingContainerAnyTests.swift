//
//  KeyedDecodingContainerAnyTests.swift
//  AdaptyTests
//
//  Created by OpenAI on 20.09.2025.
//

@testable import AdaptyCodable
import Foundation
import Testing

extension AdaptyCodableTests {
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

        @Test("decodeDictionary decodes nested values and preserves nulls")
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
                    "items": [1, "two", ["flag": true], NSNull()],
                    "label": "inner",
                ],
                "empty": NSNull(),
            ]))
            #expect(fixture.value["empty"] is NSNull)
        }

        @Test("keyed helpers decode array dictionary and any values")
        func decodeKeyedHelpers() throws {
            let fixture = try Json(
                ##"""
                {
                  "array": [null, 1, null, "two", {"flag": true}, null],
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
                NSNull(),
                1,
                NSNull(),
                "two",
                ["flag": true],
                NSNull(),
            ]))
            #expect(Json(deserilized: fixture.dictionary) == Json(deserilized: [
                "name": "value",
                "missing": NSNull(),
            ]))
            #expect(try Json(deserilized: #require(fixture.any)) == Json(deserilized: [
                "nested": ["x", 2],
            ]))
            #expect(fixture.missingArray == nil)
            #expect(fixture.missingDictionary == nil)
        }

        @Test("Omitting nulls removes dictionary entries recursively and preserves empty containers")
        func dictionaryOmittingNullValues() throws {
            struct Fixture: Decodable {
                let value: [String: any Sendable]

                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: AnyCodingKey.self)
                    value = try container.decodeDictionary(omittingNullValues: true)
                }
            }

            let json = Json(##"""
            {
              "null": null,
              "nested": {"null": null, "value": 42},
              "items": [null, {"null": null}, [null, 2, null], null],
              "onlyNulls": {"a": null, "b": null},
              "empty": {},
              "false": false,
              "zero": 0,
              "emptyString": "",
              "nullString": "null"
            }
            """##)
            let fixture = try json.decode(Fixture.self)
            let preserved = try json.decode(RootDictionaryFixture.self)

            #expect(Json(deserilized: preserved.value) == json)
            #expect(Json(deserilized: fixture.value) == Json(##"""
            {
              "nested": {"value": 42},
              "items": [{}, [2]],
              "onlyNulls": {},
              "empty": {},
              "false": false,
              "zero": 0,
              "emptyString": "",
              "nullString": "null"
            }
            """##))
        }

        @Test("Omitting nulls compacts arrays recursively without dropping non-null elements")
        func arrayOmittingNullValues() throws {
            struct Fixture: Decodable {
                let omitted: [any Sendable]
                let preserved: [any Sendable]

                init(from decoder: any Decoder) throws {
                    var omittingContainer = try decoder.unkeyedContainer()
                    omitted = try omittingContainer.decodeArray(omittingNullValues: true)
                    var preservingContainer = try decoder.unkeyedContainer()
                    preserved = try preservingContainer.decodeArray(omittingNullValues: false)
                }
            }

            let json = Json(##"""
            [null, false, null, 0, "", "null", {"null": null, "value": 1}, [null, 2, null], [null, null], [], {}, null]
            """##)
            let fixture = try json.decode(Fixture.self)

            #expect(Json(deserilized: fixture.preserved) == json)
            #expect(Json(deserilized: fixture.omitted) == Json(##"""
            [false, 0, "", "null", {"value": 1}, [2], [], [], {}]
            """##))
        }

        @Test("Keyed helpers propagate null omission to present collections")
        func keyedHelpersOmittingNullValues() throws {
            struct Fixture: Decodable {
                let array: [any Sendable]
                let dictionary: [String: any Sendable]
                let any: (any Sendable)?
                let optionalArray: [any Sendable]?
                let optionalDictionary: [String: any Sendable]?
                let missingArray: [any Sendable]?
                let missingDictionary: [String: any Sendable]?

                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: KeyedFixture.CodingKeys.self)
                    array = try container.decodeArray(forKey: .array, omittingNullValues: true)
                    dictionary = try container.decodeDictionary(forKey: .dictionary, omittingNullValues: true)
                    any = try container.decodeAnyIfPresent(forKey: .any, omittingNullValues: true)
                    optionalArray = try container.decodeArrayIfPresent(forKey: .array, omittingNullValues: true)
                    optionalDictionary = try container.decodeDictionaryIfPresent(forKey: .dictionary, omittingNullValues: true)
                    missingArray = try container.decodeArrayIfPresent(forKey: .missingArray, omittingNullValues: true)
                    missingDictionary = try container.decodeDictionaryIfPresent(forKey: .missingDictionary, omittingNullValues: true)
                }
            }

            let json = Json(##"""
            {
              "array": [null, null],
              "dictionary": {"null": null},
              "any": [null, {"null": null, "items": [null, 42]}, null]
            }
            """##)
            let fixture = try json.decode(Fixture.self)
            let preserved = try json.decode(KeyedFixture.self)

            #expect(Json(deserilized: preserved.array) == Json(##"[null, null]"##))
            #expect(Json(deserilized: preserved.dictionary) == Json(##"{"null": null}"##))
            #expect(try Json(deserilized: #require(preserved.any)) == Json(##"[null, {"null": null, "items": [null, 42]}, null]"##))
            #expect(fixture.array.isEmpty)
            #expect(fixture.dictionary.isEmpty)
            #expect(try #require(fixture.optionalArray).isEmpty)
            #expect(try #require(fixture.optionalDictionary).isEmpty)
            #expect(try Json(deserilized: #require(fixture.any)) == Json(##"[{"items": [42]}]"##))
            #expect(fixture.missingArray == nil)
            #expect(fixture.missingDictionary == nil)
        }

        @Test("Omitting a null field returns nil while a missing field stays nil in both modes")
        func anyOmittingNullValues() throws {
            struct Fixture: Decodable {
                let omitted: (any Sendable)?
                let preserved: (any Sendable)?
                let missingOmitted: (any Sendable)?
                let missingPreserved: (any Sendable)?

                enum CodingKeys: String, CodingKey {
                    case null
                    case missing
                }

                init(from decoder: any Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    omitted = try container.decodeAnyIfPresent(forKey: .null, omittingNullValues: true)
                    preserved = try container.decodeAnyIfPresent(forKey: .null, omittingNullValues: false)
                    missingOmitted = try container.decodeAnyIfPresent(forKey: .missing, omittingNullValues: true)
                    missingPreserved = try container.decodeAnyIfPresent(forKey: .missing, omittingNullValues: false)
                }
            }

            let fixture = try Json(##"{"null": null}"##).decode(Fixture.self)

            #expect(fixture.omitted == nil)
            #expect(fixture.preserved is NSNull)
            #expect(fixture.missingOmitted == nil)
            #expect(fixture.missingPreserved == nil)
        }

        @Test("decodeAnyIfPresent distinguishes missing keys from null")
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
            #expect(fixture.empty is NSNull)
        }
    }
}

