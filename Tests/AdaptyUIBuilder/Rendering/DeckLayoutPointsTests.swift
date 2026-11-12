//
//  DeckLayoutPointsTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import SwiftUI
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Deck Layout"),
    .feature("Deck Rendering"),
    .risk(.normal),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
struct DeckLayoutPointsTests {
    private static func item(_ fields: String) throws -> VC.DeckItem {
        let (deck, _) = try DeckLayoutPointsTests.deck(content: """
        {
          "type": "deck",
          "items": [{
            "type": "deck_item",
            \(fields),
            "content": { "type": "text", "string_id": "title" }
          }]
        }
        """)
        return try #require(deck.items.first)
    }

    /// Legacy alignments keep their placement: logical ones follow the interface
    /// direction, physical ones do not, and `justified` stays centered. A `Layout`
    /// places from the leading edge, so a physical side flips in RTL.
    @Test(
        "Legacy h_align keeps its side in both directions",
        arguments: [
            ("leading", LayoutDirection.leftToRight, CGFloat(0)),
            ("leading", .rightToLeft, 0),
            ("trailing", .leftToRight, 1),
            ("trailing", .rightToLeft, 1),
            ("center", .leftToRight, 0.5),
            ("center", .rightToLeft, 0.5),
            ("justified", .rightToLeft, 0.5),
            ("left", .leftToRight, 0),
            ("left", .rightToLeft, 1),
            ("right", .leftToRight, 1),
            ("right", .rightToLeft, 0),
        ]
    )
    func legacyHorizontalAlignment(alignment: String, layoutDirection: LayoutDirection, expected: CGFloat) throws {
        let item = try Self.item(#""h_align": "\#(alignment)", "v_align": "bottom""#)

        #expect(item.layoutAnchor(with: layoutDirection) == CGPoint(x: expected, y: 1))
        #expect(item.layoutPosition(with: layoutDirection) == CGPoint(x: expected, y: 1))
    }

    /// Explicit points are physical unless the item mirrors with the interface.
    @Test(
        "Explicit points flip in RTL unless mirrored",
        arguments: [
            ("preserve", LayoutDirection.leftToRight, CGFloat(0.25), CGFloat(0.875)),
            ("preserve", .rightToLeft, 0.75, 0.125),
            ("mirror", .leftToRight, 0.25, 0.875),
            ("mirror", .rightToLeft, 0.25, 0.875),
        ]
    )
    func explicitPoints(
        rtl: String,
        layoutDirection: LayoutDirection,
        anchorX: CGFloat,
        positionX: CGFloat
    ) throws {
        let item = try Self.item(#"""
        "anchor": { "x": 0.25, "y": 0.75 }, "position": { "x": 0.875, "y": 0.2 }, "rtl": "\#(rtl)"
        """#)

        #expect(item.layoutAnchor(with: layoutDirection) == CGPoint(x: anchorX, y: 0.75))
        #expect(item.layoutPosition(with: layoutDirection) == CGPoint(x: positionX, y: 0.2))
    }
}

extension DeckLayoutPointsTests {
    static func deck(content: String) throws -> (deck: VC.Deck, screen: VC.Screen) {
        let screen = try screen(content: content)
        guard case let .deck(deck, _) = screen.poolElements[screen.content] else {
            Issue.record("Expected root element to be a Deck")
            throw TestError.expectedDeck
        }

        return (deck, screen)
    }

    static func screen(content: String) throws -> VC.Screen {
        
        let schema = try AdaptyUISchema(
            from: """
            {
              "format": "5.1.0",
              "screens": {
                "main": {
                  "content": \(content)
                }
              }
            }
            """,
            configuration: .init(device: .phone)
        )

        let configuration = try schema.extractUIConfiguration(
            id: "deck-layout-points-test",
            withLocaleId: "en",
            envoriment: .init(
                sdkVersion: "test",
                osName: "test",
                osVersion: "test",
                deviceModel: "test",
                appBundleId: nil,
                appVersion: nil,
                appBuild: nil,
                appCurrentLocale: nil,
                userLocales: [],
                userUses24HourClock: true,
                flow: .init(
                    placementId: "test",
                    variationId: "test",
                    variationName: nil,
                    abTestName: "test",
                    name: "test",
                    products: []
                )
            )
        )

        return try #require(configuration.screens["main"])
    }

    enum TestError: Error {
        case expectedDeck
    }
}
