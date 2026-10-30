//
//  AvailableHeightTraversalTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

/// Which row items are placed without the row's height: those whose content, at
/// any depth, has a `flex`, `flex_stack` or `switch` that picks its layout from `available_height`.
@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Row and Column Layout"),
    .feature("Layout Proposals"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
struct AvailableHeightTraversalTests {
    static func flexStack(_ metric: String) -> String {
        """
        { "type": "flex_stack", "direction": "h_stack", "condition": [{ "metric": "\(metric)", "min": 100 }],
          "content": [{ "type": "text", "string_id": "a" }] }
        """
    }

    static func picks(_ content: String) throws -> Bool {
        let screen = try DeckLayoutPointsTests.screen(content: content)
        return screen.poolElements.picksLayoutFromHeight(screen.content)
    }

    @Test(
        "Content picking its layout from available_height is found at any depth",
        arguments: [
            // The container itself.
            flexStack("available_height"),
            "{ \"type\": \"flex\", \"direction\": \"row\", \"condition\": [{ \"metric\": \"available_height\", \"min\": 100 }], \"items\": [{ \"type\": \"grid_item\", \"weight\": 1, \"content\": { \"type\": \"text\", \"string_id\": \"a\" } }] }",
            // Under boxes and another container.
            "{ \"type\": \"box\", \"content\": { \"type\": \"v_stack\", \"content\": [{ \"type\": \"box\", \"content\": \(flexStack("available_height")) }] } }",
            // A switch on available_height.
            "{ \"type\": \"switch\", \"cases\": [{ \"condition\": [{ \"metric\": \"available_height\", \"min\": 500 }], \"content\": { \"type\": \"text\", \"string_id\": \"a\" } }], \"default\": { \"type\": \"text\", \"string_id\": \"b\" } }",
            // A switch case holding one.
            "{ \"type\": \"switch\", \"cases\": [{ \"condition\": [], \"content\": \(flexStack("available_height")) }], \"default\": { \"type\": \"text\", \"string_id\": \"b\" } }",
            // An overlay.
            "{ \"type\": \"box\", \"overlay\": [{ \"content\": \(flexStack("available_height")) }] }",
        ]
    )
    func foundAtAnyDepth(content: String) throws {
        #expect(try Self.picks(content))
    }

    @Test(
        "Content without a condition on available_height is not",
        arguments: [
            flexStack("available_width"),
            "{ \"type\": \"box\", \"content\": { \"type\": \"text\", \"string_id\": \"a\" } }",
            "{ \"type\": \"switch\", \"cases\": [{ \"condition\": [{ \"metric\": \"screen_height\", \"min\": 500 }], \"content\": { \"type\": \"text\", \"string_id\": \"a\" } }], \"default\": { \"type\": \"text\", \"string_id\": \"b\" } }",
        ]
    )
    func notFound(content: String) throws {
        #expect(try !Self.picks(content))
    }
}
