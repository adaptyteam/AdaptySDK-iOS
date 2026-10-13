//
//  Schema.TextAttributesDecodingTests.swift
//  AdaptyTests
//

import Testing
@testable import AdaptyUIBuilder

struct SchemaTextAttributesDecodingTests {
    @Test("new text attributes take precedence over legacy attributes")
    func newAttributesTakePrecedence() throws {
        let attributes = try Json(##"""
        {
            "text_color": "new_color",
            "color": 1,
            "text_background": "new_background",
            "background": 1
        }
        """##).decode(Schema.TextAttributes.self)

        guard case let .assetId(color)? = attributes.color else {
            Issue.record("Expected text_color to decode as an asset identifier")
            return
        }
        guard case let .assetId(background)? = attributes.background else {
            Issue.record("Expected text_background to decode as an asset identifier")
            return
        }

        #expect(color == "new_color")
        #expect(background == "new_background")
    }

    @Test("legacy text attributes remain supported")
    func legacyAttributesRemainSupported() throws {
        let attributes = try Json(##"""
        {
            "color": "legacy_color",
            "background": "legacy_background"
        }
        """##).decode(Schema.TextAttributes.self)

        guard case let .assetId(color)? = attributes.color else {
            Issue.record("Expected legacy color to decode as an asset identifier")
            return
        }
        guard case let .assetId(background)? = attributes.background else {
            Issue.record("Expected legacy background to decode as an asset identifier")
            return
        }

        #expect(color == "legacy_color")
        #expect(background == "legacy_background")
    }

    @Test(
        "invalid legacy text attributes throw when no new attribute is present",
        arguments: [
            Json(##"{ "color": 1 }"##),
            Json(##"{ "background": 1 }"##),
        ]
    )
    func invalidLegacyAttributesThrow(json: Json) {
        #expect(throws: (any Error).self) {
            try json.decode(Schema.TextAttributes.self)
        }
    }
}
