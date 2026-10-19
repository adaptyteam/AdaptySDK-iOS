//
//  LayoutProposalTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import SwiftUI
import Testing
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Renders the containers for real and checks what a child is proposed when it is
/// placed. Content that picks its layout from the proposal — `flex`, `flex_stack`,
/// `switch` — only places the layout it was measured with if the proposal it is
/// placed with matches the one it was measured with on every axis the container
/// measured it on.
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
@MainActor
struct LayoutProposalTests {
    /// Every proposal one child saw, in order.
    final class Log {
        var measured: [ProposedViewSize] = []
        var placed: [ProposedViewSize] = []
    }

    /// A child that answers a size of its own, whatever the proposal, and logs
    /// what it is asked. It answers wider than any cell below, as content that
    /// overflows its cell does.
    struct Recorder: Layout {
        let log: Log
        var size = CGSize(width: 248, height: 44)

        func sizeThatFits(proposal: ProposedViewSize, subviews _: Subviews, cache _: inout ()) -> CGSize {
            log.measured.append(proposal)
            return size
        }

        func placeSubviews(in _: CGRect, proposal: ProposedViewSize, subviews _: Subviews, cache _: inout ()) {
            log.placed.append(proposal)
        }
    }

    static func render(_ view: some View, width: CGFloat = 354, height: CGFloat = 600) {
        let root = view.frame(width: width, height: height, alignment: .topLeading)
        #if canImport(UIKit)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: height))
        window.rootViewController = UIHostingController(rootView: root)
        window.makeKeyAndVisible()
        window.rootViewController?.view.layoutIfNeeded()
        window.isHidden = true
        #else
        let host = NSHostingView(rootView: root)
        host.frame = CGRect(x: 0, y: 0, width: width, height: height)
        host.layoutSubtreeIfNeeded()
        #endif
    }

    static func item(_ length: AdaptyUIWeightedSolver.Length) -> AdaptyUIWeightedSolver.Item {
        .init(length: length, anchorX: 0.5, anchorY: 0.5)
    }

    /// A row cell is the item's share of the width: the child is measured with it
    /// and placed with it, not with the wider size it reported.
    @Test("Row cell places with the width it measured with")
    func rowCellMainAxis() throws {
        let log = Log()
        Self.render(
            AdaptyUIWeightedLayout(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 8,
                items: [Self.item(.weight(1)), Self.item(.weight(1))]
            ) {
                Recorder(log: log) { Color.clear }
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 0)
                Color.clear.frame(height: 44)
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 1)
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed.width == 173)
        #expect(log.measured.allSatisfy { $0.width == 173 })
    }

    /// A row measures children without a height and places them with its own; a
    /// child that picks its layout from `available_height` is placed without one,
    /// as it was measured.
    @Test("Row cell places height-conditional content without a height")
    func rowCellCrossAxis() throws {
        let log = Log()
        var item = Self.item(.weight(1))
        item.placesAsMeasured = true
        Self.render(
            AdaptyUIWeightedLayout(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 8,
                items: [item, Self.item(.weight(1))]
            ) {
                Recorder(log: log) { Color.clear }
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 0)
                Color.clear.frame(height: 96)
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 1)
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed == ProposedViewSize(width: 173, height: nil))
        #expect(log.measured.allSatisfy { $0 == placed })
    }

    /// A flex lays out as the row or the column it turns into, chosen from the
    /// proposal of the same pass: the child gets the cell width of that direction,
    /// half the row or the whole column.
    @Test("Flex lays out as the row or the column it turns into", arguments: [(300, 173), (400, 354)] as [(Double, CGFloat)])
    func flexChoosesDirection(minWidth: Double, width: CGFloat) throws {
        let log = Log()
        let items = [Self.item(.weight(1)), Self.item(.weight(1))]
        Self.render(
            AdaptyUIFlexLayout(
                conditions: [.availableWidth(min: minWidth, max: nil)],
                direction: .horizontal,
                screenSize: CGSize(width: 402, height: 874),
                orientation: .portrait,
                huggedAxes: [],
                row: AdaptyUIWeightedLayout(axis: .horizontal, mainAxisSizing: .fill, crossAxisSizing: .hug, spacing: 8, items: items),
                column: AdaptyUIWeightedLayout(axis: .vertical, mainAxisSizing: .hug, crossAxisSizing: .fill, spacing: 8, items: [
                    Self.item(.points(600)), Self.item(.points(40)),
                ])
            ) {
                Recorder(log: log) { Color.clear }
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 0)
                Color.clear.frame(height: 44)
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 1)
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed.width == width)
        #expect(log.measured.allSatisfy { $0.width == width })
    }

    /// A switch takes the size of its branch, not what its parent offers, and
    /// places its probe with what the parent offers.
    @Test("Switch takes its branch and probes the parent")
    func switchTakesItsBranch() throws {
        let probe = Log()
        let branch = Log()
        let frames = BoxFrameLayoutTests.Frames()
        Self.render(
            BoxFrameLayoutTests.Root(proposal: ProposedViewSize(width: 402, height: nil), frames: frames) {
                AdaptyUISwitchLayout(screenSize: CGSize(width: 402, height: 874), probes: true) {
                    Recorder(log: probe) { Color.clear }
                    Recorder(log: branch, size: CGSize(width: 250, height: 44)) { Color.clear }
                }
            },
            width: 402
        )

        #expect(frames.box?.size == CGSize(width: 250, height: 44))
        #expect(try #require(probe.placed.last) == ProposedViewSize(width: 402, height: 874))
        #expect(branch.placed.allSatisfy { $0.width == 402 })
    }

    /// A column cell with a length is the whole cell on both axes.
    @Test("Column cell places with the cell it measured with")
    func columnCellBothAxes() throws {
        let log = Log()
        Self.render(
            AdaptyUIWeightedLayout(
                axis: .vertical,
                mainAxisSizing: .hug,
                crossAxisSizing: .fill,
                spacing: 8,
                items: [Self.item(.points(150)), Self.item(.points(40))]
            ) {
                Recorder(log: log) { Color.clear }
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 0)
                Color.clear
                    .layoutValue(key: AdaptyUIWeightedItemKey.self, value: 1)
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed == ProposedViewSize(width: 354, height: 150))
        #expect(log.measured.allSatisfy { $0 == placed })
    }

    /// A deck item without lengths is sized by its content: measured without a
    /// length on either axis, and placed without one.
    @Test("Deck item without lengths places without a proposal")
    func deckItemWithoutLengths() throws {
        let log = Log()
        Self.render(
            AdaptyUIDeckLayout(
                width: .fill,
                height: .hug,
                items: [.init(width: .content, height: .content, anchorX: 0.5, anchorY: 0.5)]
            ) {
                AdaptyUIDeckItemLayout(contentAxes: [.horizontal, .vertical]) {
                    Recorder(log: log) { Color.clear }
                }
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed == .unspecified)
        #expect(log.measured.allSatisfy { $0 == .unspecified })
    }

    /// A deck item with a width but no height is placed with its width and
    /// without a height, as it was measured.
    @Test("Deck item with a width places without a height")
    func deckItemWithWidth() throws {
        let log = Log()
        Self.render(
            AdaptyUIDeckLayout(
                width: .fill,
                height: .hug,
                items: [.init(width: .points(200), height: .content, anchorX: 0.5, anchorY: 0.5)]
            ) {
                AdaptyUIDeckItemLayout(contentAxes: [.vertical]) {
                    Recorder(log: log) { Color.clear }
                }
            }
        )

        let placed = try #require(log.placed.last)
        #expect(placed == ProposedViewSize(width: 200, height: nil))
        #expect(log.measured.allSatisfy { $0 == placed })
    }
}
