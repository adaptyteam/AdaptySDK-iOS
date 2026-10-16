//
//  DeckLayoutTests.swift
//  AdaptyTests
//
//  Created by Aleksey Goncharov on 15.09.2026.
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Deck Layout"),
    .feature("Deck Rendering"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
enum DeckLayoutTests {
    fileprivate static func item(
        width: AdaptyUIDeckSolver.Length = .content,
        height: AdaptyUIDeckSolver.Length = .content,
        anchorX: CGFloat = 0.5,
        anchorY: CGFloat = 0.5
    ) -> AdaptyUIDeckSolver.Item {
        .init(width: width, height: height, anchorX: anchorX, anchorY: anchorY)
    }

    /// Reports the same size for every child, whatever the proposal.
    fileprivate static func fixedMeasure(
        _ size: CGSize
    ) -> (Int, CGFloat?, CGFloat?) -> CGSize {
        { _, _, _ in size }
    }

    @Suite(
        "Deck Sizing",
        .story("Deck Sizing")
    )
    struct DeckSizingTests {
        /// A `fill` axis takes the proposal it is given, however large the children are.
        @Test("Fill uses the finite proposal")
        func fillUsesTheFiniteProposal() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [DeckLayoutTests.item()],
                proposedWidth: 300,
                proposedHeight: 200,
                measure: DeckLayoutTests.fixedMeasure(CGSize(width: 500, height: 400))
            )

            #expect(result.size == CGSize(width: 300, height: 200))
            #expect(result.frames[0].size == CGSize(width: 500, height: 400))
        }

        /// Without a finite proposal there is nothing to fill, so the axis falls back.
        @Test("Fill in unbounded space falls back to ten points")
        func fillInUnboundedSpaceFallsBack() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [DeckLayoutTests.item(width: .parent(1), height: .parent(1))],
                proposedWidth: .infinity,
                proposedHeight: nil,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.size == CGSize(width: 10, height: 10))
            #expect(result.frames[0].size == CGSize(width: 10, height: 10))
        }

        /// `hug` measures against children sized by content or by a fixed length.
        @Test("Hug takes the largest independent child")
        func hugTakesTheLargestIndependentChild() {
            let result = AdaptyUIDeckSolver.solve(
                width: .hug,
                height: .hug,
                items: [
                    DeckLayoutTests.item(),
                    DeckLayoutTests.item(width: .points(80), height: .points(30)),
                ],
                proposedWidth: 1000,
                proposedHeight: 1000,
                measure: DeckLayoutTests.fixedMeasure(CGSize(width: 120, height: 40))
            )

            #expect(result.size == CGSize(width: 120, height: 40))
        }

        /// A relative child follows the deck instead of sizing it.
        @Test("Hug ignores parent children")
        func hugIgnoresParentChildren() {
            let result = AdaptyUIDeckSolver.solve(
                width: .hug,
                height: .hug,
                items: [
                    DeckLayoutTests.item(width: .parent(0.5), height: .parent(0.5)),
                    DeckLayoutTests.item(width: .points(100), height: .points(60)),
                ],
                proposedWidth: 1000,
                proposedHeight: 1000,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.size == CGSize(width: 100, height: 60))
            #expect(result.frames[0].size == CGSize(width: 50, height: 30))
        }

        /// With nothing else to measure, `hug` falls back and the fractions follow it.
        @Test("Hug with only parent children falls back to ten points")
        func hugWithOnlyParentChildrenFallsBack() {
            let result = AdaptyUIDeckSolver.solve(
                width: .hug,
                height: .hug,
                items: [DeckLayoutTests.item(width: .parent(0.5), height: .parent(2))],
                proposedWidth: 1000,
                proposedHeight: 1000,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.size == CGSize(width: 10, height: 10))
            #expect(result.frames[0].size == CGSize(width: 5, height: 20))
        }
    }

    @Suite(
        "Deck Item Sizing",
        .story("Deck Item Sizing")
    )
    struct DeckItemSizingTests {
        /// The fraction applies to the deck's inner size along the same axis.
        @Test("Parent fraction resolves against the deck")
        func parentFractionResolvesAgainstTheDeck() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [DeckLayoutTests.item(width: .parent(0.5), height: .parent(0.25))],
                proposedWidth: 300,
                proposedHeight: 200,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.frames[0].size == CGSize(width: 150, height: 50))
        }

        /// A missing length means the child keeps the size of its own content.
        @Test("Missing length uses the measured content")
        func missingLengthUsesTheMeasuredContent() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [DeckLayoutTests.item()],
                proposedWidth: 300,
                proposedHeight: 200,
                measure: DeckLayoutTests.fixedMeasure(CGSize(width: 140, height: 90))
            )

            #expect(result.frames[0].size == CGSize(width: 140, height: 90))
        }

        /// A child sized by its content on both axes is measured once, without a
        /// length: asking for its height at its own width would hand it back its
        /// own answer.
        @Test("Content child is measured without a length only")
        func contentChildIsMeasuredWithoutLengthOnly() {
            var proposals: [CGSize?] = []
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .hug,
                items: [DeckLayoutTests.item()],
                proposedWidth: 300,
                proposedHeight: nil,
                measure: { _, proposedWidth, proposedHeight in
                    proposals.append(proposedWidth.map { CGSize(width: $0, height: proposedHeight ?? -1) })
                    // Picks a wide layout without a width and a tall one at 248 pt.
                    return (proposedWidth ?? .infinity) > 248
                        ? CGSize(width: 248, height: 44)
                        : CGSize(width: 120, height: 96)
                }
            )

            #expect(proposals == [nil])
            #expect(result.frames[0].size == CGSize(width: 248, height: 44))
            #expect(result.size == CGSize(width: 300, height: 44))
        }

        /// Negative literals are rejected while decoding; a negative resolved size
        /// still collapses to zero instead of inverting the layout.
        @Test("Negative length collapses to zero")
        func negativeLengthCollapsesToZero() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [DeckLayoutTests.item(width: .points(-20), height: .parent(-0.5))],
                proposedWidth: 300,
                proposedHeight: 200,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.frames[0].size == .zero)
            #expect(result.size == CGSize(width: 300, height: 200))
        }

        /// Height is measured only once the width is final, so wrapped text reports
        /// the height it actually occupies at that width.
        @Test("Width resolves before height")
        func widthResolvesBeforeHeight() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .hug,
                items: [DeckLayoutTests.item(width: .parent(0.5))],
                proposedWidth: 300,
                proposedHeight: 1000,
                measure: { _, proposedWidth, _ in
                    // Narrower than 150 pt the text needs a second line.
                    CGSize(width: 400, height: (proposedWidth ?? 0) >= 150 ? 40 : 90)
                }
            )

            #expect(result.frames[0].size == CGSize(width: 150, height: 40))
            #expect(result.size == CGSize(width: 300, height: 40))
        }
    }

    @Suite(
        "Deck Placement",
        .story("Deck Placement")
    )
    struct DeckPlacementTests {
        /// Every child is aligned on its own inside the shared area.
        @Test("Children are aligned independently")
        func childrenAreAlignedIndependently() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [
                    DeckLayoutTests.item(width: .points(100), height: .points(50), anchorX: 0, anchorY: 0),
                    DeckLayoutTests.item(width: .points(100), height: .points(50), anchorX: 1, anchorY: 1),
                    DeckLayoutTests.item(width: .points(100), height: .points(50)),
                ],
                proposedWidth: 300,
                proposedHeight: 200,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.frames[0].origin == CGPoint(x: 0, y: 0))
            #expect(result.frames[1].origin == CGPoint(x: 200, y: 150))
            #expect(result.frames[2].origin == CGPoint(x: 100, y: 75))
        }

        /// The frames come back in configuration order, which is the Z order.
        @Test("Item order is preserved")
        func itemOrderIsPreserved() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [
                    DeckLayoutTests.item(width: .points(10), height: .points(10)),
                    DeckLayoutTests.item(width: .points(20), height: .points(20)),
                    DeckLayoutTests.item(width: .points(30), height: .points(30)),
                ],
                proposedWidth: 300,
                proposedHeight: 200,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.frames.map(\.width) == [10, 20, 30])
        }

        /// A fraction above one overflows the deck instead of shrinking or growing it.
        @Test("Overflow keeps both the child size and the deck size")
        func overflowKeepsBothSizes() {
            let result = AdaptyUIDeckSolver.solve(
                width: .fill,
                height: .fill,
                items: [DeckLayoutTests.item(width: .parent(1.5), height: .parent(1.5))],
                proposedWidth: 200,
                proposedHeight: 100,
                measure: DeckLayoutTests.fixedMeasure(.zero)
            )

            #expect(result.size == CGSize(width: 200, height: 100))
            #expect(result.frames[0].size == CGSize(width: 300, height: 150))
            #expect(result.frames[0].origin == CGPoint(x: -50, y: -25))
        }
    }
}
