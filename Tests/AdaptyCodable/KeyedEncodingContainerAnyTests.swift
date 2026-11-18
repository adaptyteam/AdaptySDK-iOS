//
//  KeyedEncodingContainerAnyTests.swift
//  AdaptyTests
//
//  Created by OpenAI on 20.09.2025.
//

@testable import AdaptyCodable
import Foundation
import Testing

extension AdaptyCodableTests {
    struct KeyedEncodingContainerAnyTests {
        private struct UnsupportedSendable: Sendable {}

        private struct RootDictionaryFixture: Encodable {
            let skipNonEncodableValues: Bool

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                try container.encodeDictionary(
                    [
                        "name": "adapty",
                        "enabled": true,
                        "count": 3,
                        "nested": [
                            "label": "inner",
                            "items": [1, "two", ["flag": true]],
                        ],
                        "ns_bool": NSNumber(value: true),
                        "ns_int": NSNumber(value: Int.min),
                        "ns_uint": NSNumber(value: UInt.max),
                        "ns_double": NSNumber(value: 123.45),
                        "ns_null": NSNull(),
                        "ns_string": NSString(string: "ns_string"),
                        "empty": String?.none as Any,
                        "unsupported": UnsupportedSendable(),
                    ],
                    skipNonEncodableValues: skipNonEncodableValues
                )
            }
        }

        private struct KeyedFixture: Encodable {
            let skipNonEncodableValues: Bool

            enum CodingKeys: String, CodingKey {
                case array
                case dictionary
                case any
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encodeArray(
                    [
                        1,
                        "two",
                        ["flag": true],
                        Int?.none as Any,
                        UnsupportedSendable(),
                        NSNumber(value: true),
                        NSNumber(value: Int.min),
                        NSNumber(value: UInt.max),
                        NSNumber(value: 123.45),
                        NSNull(),
                        NSString(string: "ns_string"),
                    ],
                    skipNonEncodableValues: skipNonEncodableValues,
                    forKey: .array
                )
                try container.encodeDictionary(
                    [
                        "name": "value",
                        "missing": String?.none as Any,
                        "unsupported": UnsupportedSendable(),
                    ],
                    skipNonEncodableValues: skipNonEncodableValues,
                    forKey: .dictionary
                )
                try container.encodeAnyIfPresent(
                    ["nested": "object"],
                    skipNonEncodableValues: skipNonEncodableValues,
                    forKey: .any
                )
            }
        }

        @Test("encodeDictionary encodes nested dictionary and array")
        func encodeDictionary() throws {
            let json = try Json.encode(RootDictionaryFixture(skipNonEncodableValues: true))

            #expect(json == Json(deserilized: [
                "count": 3,
                "enabled": true,
                "name": "adapty",
                "nested": [
                    "items": [1, "two", ["flag": true]],
                    "label": "inner",
                ],
                "ns_bool": true,
                "ns_int": Int.min,
                "ns_uint": UInt.max,
                "ns_double": 123.45,
                "ns_null": NSNull(),
                "ns_string": "ns_string",
                "empty": NSNull(),
            ]))
        }

        @Test("keyed helpers encode dictionary, array and any value")
        func encodeKeyedHelpers() throws {
            let json = try Json.encode(KeyedFixture(skipNonEncodableValues: true))

            #expect(json == Json(deserilized: [
                "any": [
                    "nested": "object",
                ],
                "array": [
                    1,
                    "two",
                    ["flag": true],
                    NSNull(),
                    NSNull(),
                    true,
                    Int.min,
                    UInt.max,
                    123.45,
                    NSNull(),
                    "ns_string",
                ],
                "dictionary": [
                    "name": "value",
                    "missing": NSNull(),
                ],
            ]))
        }

        private struct RoundTripFixture: Codable {
            let value: [String: any Sendable]

            init(from decoder: any Decoder) throws {
                value = try decoder.container(keyedBy: AnyCodingKey.self).decodeDictionary()
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                try container.encodeDictionary(value)
            }
        }

        @Test("decodeDictionary then encodeDictionary preserves nulls in dictionaries and arrays")
        func decodeEncodeRoundTrip() throws {
            let json = Json(##"""
            {
              "null": null,
              "array": [123, null, "333"],
              "nested": {"null": null, "items": [null, {"null": null}, [null]]}
            }
            """##)
            let fixture = try json.decode(RoundTripFixture.self)

            #expect(try Json.encode(fixture) == json)
        }

        private struct OmittingNullsFixture: Encodable {
            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                try container.encodeDictionary(
                    [
                        "ns_null": NSNull(),
                        "none": String?.none as Any,
                        "value": 1,
                        "array": [NSNull(), Int?.none as Any, 1, ["ns_null": NSNull(), "none": String?.none as Any]],
                        "nested": ["ns_null": NSNull(), "none": String?.none as Any],
                    ],
                    omittingNullValues: true
                )
            }
        }

        @Test("Omitting nulls drops NSNull and Optional.none dictionary entries but keeps array elements as null")
        func encodeOmittingNullValues() throws {
            #expect(try Json.encode(OmittingNullsFixture()) == Json(##"""
            {
              "value": 1,
              "array": [null, null, 1, {}],
              "nested": {}
            }
            """##))
        }

        private struct NonFiniteFixture: Encodable {
            let skipNonEncodableValues: Bool

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                try container.encodeDictionary(
                    [
                        "value": 1.5,
                        "nan": Double.nan,
                        "inf": Double.infinity,
                        "float_inf": -Float.infinity,
                        "ns_nan": NSNumber(value: Double.nan),
                        "array": [1, Double.nan, NSNumber(value: -Double.infinity), "x"] as [Any],
                        "nested": ["nan": Double.nan, "value": 2] as [String: Any],
                    ],
                    skipNonEncodableValues: skipNonEncodableValues
                )
            }
        }

        @Test("NaN and Infinity follow the non encodable rules: skipped key, null array element, or error")
        func encodeNonFiniteNumbers() throws {
            #expect(try Json.encode(NonFiniteFixture(skipNonEncodableValues: true)) == Json(##"""
            {
              "value": 1.5,
              "array": [1, null, null, "x"],
              "nested": {"value": 2}
            }
            """##))
            #expect(throws: EncodingError.self) {
                _ = try Json.encode(NonFiniteFixture(skipNonEncodableValues: false))
            }
        }

        @Test("encode helpers throw for unsupported non encodable values")
        func encodeUnsupportedValuesThrows() throws {
            #expect {
                _ = try Json.encode(KeyedFixture(skipNonEncodableValues: false))
            } throws: { error in
                guard let error = error as? EncodingError else {
                    return false
                }
                if case .invalidValue = error {
                    return true
                }
                return false
            }
        }
    }
}

