//
//  Schema.WheelItemsPickerTests.swift
//  AdaptyTests
//
//  Created by Codex on 21.08.2025.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

extension SchemaTests {
    struct WheelItemsPickerTests {}
}

private extension SchemaTests.WheelItemsPickerTests {
    typealias Value = Schema.WheelItemsPicker

    static let boolJson = Json(
        ##"""
        {
            "value": { "var": "profile.flag" },
            "items": [
                { "string_id": "first", "value": true },
                { "string_id": "second", "value": false }
            ]
        }
        """##
    )

    static let doubleJson = Json(
        ##"""
        {
            "value": { "var": "profile.score" },
            "items": [
                { "string_id": "first", "value": 1.5 },
                { "string_id": "second", "value": 2.5 }
            ]
        }
        """##
    )

    static let stringJson = Json(
        ##"""
        {
            "value": { "var": "profile.name" },
            "items": [
                { "string_id": "first", "value": "A" },
                { "string_id": "second", "value": "B" }
            ]
        }
        """##
    )

    static let invalidJson = Json(
        ##"""
        {
            "value": { "var": "profile.mixed" },
            "items": [
                { "string_id": "first", "value": true },
                { "string_id": "second", "value": "B" }
            ]
        }
        """##
    )

    @Test("decode bool items picker")
    func decodeBool() throws {
        let decoded = try Self.boolJson.decode(Value.self)
print(decoded)
//        #expect(
//            decoded.items == .bool([
//                .init(stringId: "first", value: true),
//                .init(stringId: "second", value: false),
//            ])
//        )
    }

    @Test("decode double items picker")
    func decodeDouble() throws {
        let decoded = try Self.doubleJson.decode(Value.self)
        print(decoded)

//        #expect(
//            decoded.items == .double([
//                .init(stringId: "first", value: 1.5),
//                .init(stringId: "second", value: 2.5),
//            ])
//        )
    }

    @Test("decode string items picker")
    func decodeString() throws {
        let decoded = try Self.stringJson.decode(Value.self)
        print(decoded)

//        #expect(
//            decoded.items == .string([
//                .init(stringId: "first", value: "A"),
//                .init(stringId: "second", value: "B"),
//            ])
//        )
    }

    @Test("decode mixed item values throws error")
    func decodeMixedValues() {
        #expect(throws: (any Error).self) {
            try Self.invalidJson.decode(Value.self)
        }
    }

    @Test("encode decode roundtrip preserves item type")
    func roundtrip() throws {
        let value = try Self.doubleJson.decode(Value.self)
        let decoded = try Json.encode(value).decode(Value.self)

        #expect(decoded == value)
    }
}
