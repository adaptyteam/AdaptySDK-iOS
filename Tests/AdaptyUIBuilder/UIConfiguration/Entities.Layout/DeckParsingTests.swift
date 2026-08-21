//
//  DeckParsingTests.swift
//  AdaptyTests
//
//  Created by Aleksei Valiano on 21.08.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Deck Layout"),
    .feature("Deck Parsing"),
    .risk(.critical),
    .owner("Aleksei Valiano"),
    .layer(.unit),
    .tags(.codable)
)
enum DeckTests {
    @Suite(
        "Deck Parsing",
        .story("Deck Parsing")
    )
    struct DeckParsingTests {
        /// A Deck is decoded without explicit dimensions. Its default dimensions and flattened item order are preserved in the UI configuration.
        @Test("Default dimensions and item order are preserved")
        func defaultDimensionsAndItemOrderArePreserved() throws {
            let (deck, screen) = try DeckTests.deck(content: """
            {
              "type": "deck",
              "items": [
                {
                  "type": "deck_item",
                  "content": {
                    "type": "text",
                    "string_id": "title"
                  }
                },
                {
                  "type": "deck_item",
                  "content": {
                    "type": "text",
                    "string_id": "subtitle"
                  }
                }
              ]
            }
            """)

            #expect(deck.width == .fill)
            #expect(deck.height == .fill)
            #expect(deck.items.count == 2)
            #expect(deck.items[0].content == 0)
            #expect(deck.items[1].content == 1)
            #expect(screen.poolElements.count == 3)
        }

        /// A Deck is decoded with explicit dimensions. The selected sizing modes are preserved in the UI configuration.
        @Test("Explicit dimensions are preserved")
        func explicitDimensionsArePreserved() throws {
            let (deck, _) = try DeckTests.deck(content: """
            {
              "type": "deck",
              "width": "hug",
              "height": "fill",
              "items": [
                {
                  "type": "deck_item",
                  "content": {
                    "type": "text",
                    "string_id": "title"
                  }
                }
              ]
            }
            """)

            #expect(deck.width == .hug)
            #expect(deck.height == .fill)
        }

        /// A Deck is decoded with an empty items array. Schema decoding rejects the container.
        @Test("Empty items are rejected")
        func emptyItemsAreRejected() {
            #expect(throws: (any Error).self) {
                try DeckTests.screen(content: ##"{"type":"deck","items":[]}"##)
            }
        }
    }

    @Suite(
        "DeckItem Parsing",
        .story("DeckItem Parsing")
    )
    struct DeckItemParsingTests {
        /// A DeckItem is decoded without explicit sizing or alignment. Content sizing and centered alignment are applied.
        @Test("Default sizing and alignment are applied")
        func defaultSizingAndAlignmentAreApplied() throws {
            let (deck, screen) = try DeckTests.deck(content: """
            {
              "type": "deck",
              "items": [
                {
                  "type": "deck_item",
                  "content": {
                    "type": "text",
                    "string_id": "title"
                  }
                }
              ]
            }
            """)

            let item = try #require(deck.items.first)
            guard case .content = item.width else {
                Issue.record("Expected content-based width")
                return
            }
            guard case .content = item.height else {
                Issue.record("Expected content-based height")
                return
            }
            #expect(item.horizontalAlignment == .center)
            #expect(item.verticalAlignment == .center)

            guard case .text = screen.poolElements[item.content] else {
                Issue.record("Expected DeckItem content to be a text element")
                return
            }
        }

        /// A DeckItem is decoded with fixed and parent-relative sizing plus explicit alignment. Every value is preserved in the UI configuration.
        @Test("Explicit sizing and alignment are preserved")
        func explicitSizingAndAlignmentArePreserved() throws {
            let (deck, _) = try DeckTests.deck(content: """
            {
              "type": "deck",
              "items": [
                {
                  "type": "deck_item",
                  "width": 24,
                  "height": { "parent": 1.5 },
                  "h_align": "justified",
                  "v_align": "bottom",
                  "content": {
                    "type": "text",
                    "string_id": "title"
                  }
                }
              ]
            }
            """)

            let item = try #require(deck.items.first)
            #expect(item.horizontalAlignment == .justified)
            #expect(item.verticalAlignment == .bottom)

            guard case let .fixed(.point(width)) = item.width else {
                Issue.record("Expected a fixed point width")
                return
            }
            #expect(width == 24)

            guard case let .parent(height) = item.height else {
                Issue.record("Expected a parent-relative height")
                return
            }
            #expect(height == 1.5)
        }

        /// A DeckItem is decoded with an invalid discriminator or a negative length. Schema decoding rejects the item.
        @Test("Invalid discriminator and negative lengths are rejected", arguments: [
            ##"{"type":"item","content":{"type":"text","string_id":"title"}}"##,
            ##"{"type":"deck_item","width":-1,"content":{"type":"text","string_id":"title"}}"##,
            ##"{"type":"deck_item","width":{"parent":-0.1},"content":{"type":"text","string_id":"title"}}"##,
        ])
        func invalidDiscriminatorAndNegativeLengthsAreRejected(item: String) {
            #expect(throws: (any Error).self) {
                try DeckTests.screen(content: ##"{"type":"deck","items":[\##(item)]}"##)
            }
        }
    }
}

private extension DeckTests {
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
            id: "deck-test",
            withLocaleId: "en",
            envoriment: .deckTest
        )

        return try #require(configuration.screens["main"])
    }

    enum TestError: Error {
        case expectedDeck
    }
}

private extension VC.EnvironmentConstants {
    static let deckTest = Self(
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
            abTestName: "test",
            name: "test",
            products: []
        )
    )
}
