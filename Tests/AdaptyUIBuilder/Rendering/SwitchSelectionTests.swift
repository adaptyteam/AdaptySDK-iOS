//
//  SwitchSelectionTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import SwiftUI
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Switch Layout"),
    .feature("Switch Selection"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
struct SwitchSelectionTests {
    static let phone = CGSize(width: 402, height: 874)

    static func text(_ id: String) -> String { "{ \"type\": \"text\", \"string_id\": \"\(id)\" }" }

    /// A switch with a wide case, an orientation case and a default.
    static func switchElement() throws -> (VC.Switch, [VC.Element]) {
        let screen = try DeckTests.screen(content: """
        { "type": "switch",
          "cases": [
            { "condition": [{ "metric": "available_width", "min": 600 }], "content": \(text("wide")) },
            { "condition": [{ "orientation": "landscape" }], "content": \(text("landscape")) }
          ],
          "default": \(text("default")) }
        """)
        guard case let .switch(element, _) = screen.poolElements[screen.content] else {
            throw DeckTests.TestError.expectedDeck
        }
        return (element, screen.poolElements)
    }

    static func shown(_ element: VC.Switch, _ pool: [VC.Element], available: CGSize, screen: CGSize = phone, orientation: VC.Orientation = .portrait) -> String? {
        guard case let .text(text, _) = pool[element.selectedContent(available: available, screen: screen, orientation: orientation)] else { return nil }
        return "\(text)"
    }

    @Test("The first case that holds is shown, the default when none does")
    func firstCaseThatHolds() throws {
        let (element, pool) = try Self.switchElement()
        let wide = element.selectedContent(available: CGSize(width: 700, height: 100), screen: Self.phone, orientation: .landscape)
        let landscape = element.selectedContent(available: CGSize(width: 300, height: 100), screen: Self.phone, orientation: .landscape)
        let fallback = element.selectedContent(available: CGSize(width: 300, height: 100), screen: Self.phone, orientation: .portrait)
        #expect(Set([wide, landscape, fallback]).count == 3)
        #expect(fallback == element.default)
        #expect(wide == element.cases[0].content)
        #expect(landscape == element.cases[1].content)
        _ = pool
    }

    @Test("Only a switch with available conditions probes")
    func readsAvailableSize() throws {
        let (element, _) = try Self.switchElement()
        #expect(element.readsAvailableSize)
        #expect(!VC.Condition.orientation(.portrait).readsAvailableSize)
    }

    /// The spec scenario under `shrink`: nothing proposed reads as the screen,
    /// so a case on `available_width min 600` holds on a 1024 pt screen and not
    /// on a 402 pt one.
    @Test("No length offered reads as the screen")
    func noLengthReadsTheScreen() throws {
        let (element, _) = try Self.switchElement()
        for (screen, expected) in [(Self.phone, element.default), (CGSize(width: 1024, height: 1366), element.cases[0].content)] {
            let offered = AdaptyUISwitchLayout.offered(ProposedViewSize(width: nil, height: 300), screen: screen)
            #expect(offered == ProposedViewSize(width: screen.width, height: 300))
            let available = CGSize(width: offered.width!, height: offered.height!)
            #expect(element.selectedContent(available: available, screen: screen, orientation: .portrait) == expected)
        }
        #expect(AdaptyUISwitchLayout.offered(ProposedViewSize(width: .infinity, height: 0), screen: Self.phone) == ProposedViewSize(width: 402, height: 0))
    }
}
