//
//  WeightedLayoutTests.swift
//  AdaptyTests
//

@testable import AdaptyUIBuilder
import Foundation
import Testing

@Suite(
    "AdaptyUIBuilder Tests",
    .component("AdaptyUIBuilder"),
    .epic("Row and Column Layout"),
    .feature("Row and Column Rendering"),
    .risk(.critical),
    .owner("Aleksey Goncharov"),
    .layer(.unit),
    .tags(.logic)
)
enum WeightedLayoutTests {
    typealias Solver = AdaptyUIWeightedSolver

    fileprivate static func item(
        _ length: Solver.Length,
        anchorX: CGFloat = 0.5,
        anchorY: CGFloat = 0.5
    ) -> Solver.Item {
        .init(length: length, anchorX: anchorX, anchorY: anchorY)
    }

    /// Reports the same size for every child, whatever the proposal.
    fileprivate static func fixedMeasure(
        _ size: CGSize
    ) -> (Int, CGFloat?, CGFloat?) -> CGSize {
        { _, _, _ in size }
    }

    /// Reports a size of its own for each child, whatever the proposal.
    fileprivate static func measure(
        _ sizes: [CGSize]
    ) -> (Int, CGFloat?, CGFloat?) -> CGSize {
        { index, _, _ in sizes[index] }
    }

    /// What the view passes today: a row hugs its height, a column fills its width.
    fileprivate static func historicalCrossAxisSizing(_ axis: Solver.Axis) -> AdaptyUILayoutSizing {
        axis == .horizontal ? .hug : .fill
    }

    /// Behaves like a line of text `naturalWidths[index]` wide and 20 tall: given
    /// less width it wraps and grows taller.
    fileprivate static func textMeasure(
        _ naturalWidths: [CGFloat]
    ) -> (Int, CGFloat?, CGFloat?) -> CGSize {
        { index, proposedWidth, _ in
            let natural = naturalWidths[index]
            let width = proposedWidth.map { min($0, natural) } ?? natural
            return CGSize(width: width, height: 20 * (natural / max(width, 1)).rounded(.up))
        }
    }

    /// Main-axis lengths of the cells, in configuration order.
    fileprivate static func mainLengths(_ result: Solver.Result, _ axis: Solver.Axis) -> [CGFloat] {
        result.frames.map { axis == .horizontal ? $0.cell.width : $0.cell.height }
    }

    @Suite(
        "Weighted Main Axis",
        .story("Weighted Main Axis")
    )
    struct MainAxisTests {
        /// Weighted items share what the fixed items and the spacing leave over.
        @Test("Weights share the specified length", arguments: [Solver.Axis.horizontal, .vertical])
        func weightsShareTheSpecifiedLength(axis: Solver.Axis) {
            let result = Solver.solve(
                axis: axis,
                mainAxisSizing: .fill,
                crossAxisSizing: WeightedLayoutTests.historicalCrossAxisSizing(axis),
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.points(100)),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(3)),
                ],
                proposedWidth: 300,
                proposedHeight: 300,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 10))
            )

            #expect(WeightedLayoutTests.mainLengths(result, axis) == [100, 50, 150])
        }

        /// The spacing is reserved before the weights are applied.
        @Test("Spacing is reserved before weights")
        func spacingIsReservedBeforeWeights() {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 8,
                items: [
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(2)),
                ],
                proposedWidth: 216,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 10))
            )

            #expect(WeightedLayoutTests.mainLengths(result, .horizontal) == [50, 50, 100])
            #expect(result.frames.map(\.cell.minX) == [0, 58, 116])
            #expect(result.size.width == 216)
        }

        /// The remainder never goes negative: weights get nothing, fixed items keep
        /// their length and overflow the container.
        @Test("Fixed items wider than the container")
        func fixedItemsWiderThanTheContainer() {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 8,
                items: [
                    WeightedLayoutTests.item(.points(120)),
                    WeightedLayoutTests.item(.points(120)),
                    WeightedLayoutTests.item(.weight(1)),
                ],
                proposedWidth: 200,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 10))
            )

            #expect(WeightedLayoutTests.mainLengths(result, .horizontal) == [120, 120, 0])
            #expect(result.size.width == 200)
        }

        /// A weight of zero, or no weight in total, never divides by zero.
        @Test("Zero weights get zero length")
        func zeroWeightsGetZeroLength() {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.weight(0)),
                    WeightedLayoutTests.item(.weight(0)),
                ],
                proposedWidth: .infinity,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(.zero)
            )

            #expect(WeightedLayoutTests.mainLengths(result, .horizontal) == [0, 0])
        }

        /// Without a height a column has nothing to share: weighted items collapse
        /// and the column is as tall as the fixed items and the spacing.
        @Test("Unspecified column height zeroes weighted items")
        func unspecifiedColumnHeightZeroesWeightedItems() {
            let result = Solver.solve(
                axis: .vertical,
                mainAxisSizing: .fill,
                crossAxisSizing: .fill,
                spacing: 8,
                items: [
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(2)),
                ],
                proposedWidth: 300,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 500, height: 500))
            )

            #expect(WeightedLayoutTests.mainLengths(result, .vertical) == [0, 40, 0])
            #expect(result.size == CGSize(width: 300, height: 56))
        }

        /// Without a width a row still applies its weights: one unit per weight,
        /// the unit being the largest natural width per weight, so every weighted
        /// item fits its content and the proportions hold.
        @Test(
            "Unspecified row width shares the narrowest sufficient width",
            arguments: [
                // Weights 1 : 1 with different content: both get the wider one.
                (
                    [WeightedLayoutTests.item(.weight(1)), WeightedLayoutTests.item(.weight(1))],
                    [CGFloat(20), 100], CGFloat(0), [CGFloat(100), 100], [CGFloat(0), 100], CGFloat(200)
                ),
                // Weights 2 : 1: the second item needs 80 per weight, the first 25.
                (
                    [WeightedLayoutTests.item(.weight(2)), WeightedLayoutTests.item(.weight(1))],
                    [50, 80], 0, [160, 80], [0, 160], 240
                ),
                // Fixed and weighted items with spacing.
                (
                    [
                        WeightedLayoutTests.item(.points(40)),
                        WeightedLayoutTests.item(.weight(1)),
                        WeightedLayoutTests.item(.weight(2)),
                    ],
                    [10, 30, 100], 8, [40, 50, 100], [0, 48, 106], 206
                ),
                // A weight of zero gets nothing and does not set the unit.
                (
                    [WeightedLayoutTests.item(.weight(0)), WeightedLayoutTests.item(.weight(1))],
                    [70, 30], 0, [0, 30], [0, 0], 30
                ),
            ] as [([Solver.Item], [CGFloat], CGFloat, [CGFloat], [CGFloat], CGFloat)]
        )
        func unspecifiedRowWidthSharesTheNarrowestSufficientWidth(
            items: [Solver.Item],
            naturalWidths: [CGFloat],
            spacing: CGFloat,
            expectedLengths: [CGFloat],
            expectedOrigins: [CGFloat],
            expectedWidth: CGFloat
        ) {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: spacing,
                items: items,
                proposedWidth: nil,
                proposedHeight: nil,
                measure: WeightedLayoutTests.measure(naturalWidths.map { CGSize(width: $0, height: 20) })
            )

            #expect(WeightedLayoutTests.mainLengths(result, .horizontal) == expectedLengths)
            #expect(result.frames.map(\.cell.minX) == expectedOrigins)
            #expect(result.size.width == expectedWidth)
        }

        /// `hug` sums the fixed items and the spacing; weighted items get nothing.
        @Test("Hug gives weighted items no length", arguments: [Solver.Axis.horizontal, .vertical])
        func hugGivesWeightedItemsNoLength(axis: Solver.Axis) {
            let result = Solver.solve(
                axis: axis,
                mainAxisSizing: .hug,
                crossAxisSizing: WeightedLayoutTests.historicalCrossAxisSizing(axis),
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.points(60)),
                    WeightedLayoutTests.item(.weight(1)),
                ],
                proposedWidth: 300,
                proposedHeight: 300,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 10))
            )

            #expect(WeightedLayoutTests.mainLengths(result, axis) == [60, 0])
            #expect((axis == .horizontal ? result.size.width : result.size.height) == 60)
        }

        /// A negative spacing overlaps neighbours. It shortens a hugging container,
        /// but is not handed to the weights of a filling one.
        @Test("Negative spacing overlaps items")
        func negativeSpacingOverlapsItems() {
            let hug = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .hug,
                crossAxisSizing: .hug,
                spacing: -10,
                items: [
                    WeightedLayoutTests.item(.points(80)),
                    WeightedLayoutTests.item(.points(80)),
                    WeightedLayoutTests.item(.points(80)),
                ],
                proposedWidth: 300,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 44))
            )

            #expect(hug.frames.map(\.cell.minX) == [0, 70, 140])
            #expect(hug.size.width == 220)

            let fill = Solver.solve(
                axis: .vertical,
                mainAxisSizing: .fill,
                crossAxisSizing: .fill,
                spacing: -10,
                items: [
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(1)),
                ],
                proposedWidth: 300,
                proposedHeight: 300,
                measure: WeightedLayoutTests.fixedMeasure(.zero)
            )

            #expect(WeightedLayoutTests.mainLengths(fill, .vertical) == [150, 150])
            #expect(fill.frames.map(\.cell.minY) == [0, 140])
            #expect(fill.size.height == 300)
        }
    }

    @Suite(
        "Weighted Sizing Agreement",
        .story("Weighted Sizing Agreement")
    )
    struct SizingAgreementTests {
        /// Without a main-axis proposal the size the container reports is exactly
        /// what its cells and spacing take up when placed.
        @Test(
            "Reported and placed sizes agree",
            arguments: [
                (Solver.Axis.horizontal, AdaptyUILayoutSizing.fill),
                (.vertical, .fill),
                (.horizontal, .hug),
                (.vertical, .hug),
            ]
        )
        func reportedAndPlacedSizesAgree(axis: Solver.Axis, mainAxisSizing: AdaptyUILayoutSizing) {
            let result = Solver.solve(
                axis: axis,
                mainAxisSizing: mainAxisSizing,
                crossAxisSizing: WeightedLayoutTests.historicalCrossAxisSizing(axis),
                spacing: 6,
                items: [
                    WeightedLayoutTests.item(.weight(2)),
                    WeightedLayoutTests.item(.points(30)),
                    WeightedLayoutTests.item(.weight(1)),
                ],
                proposedWidth: nil,
                proposedHeight: nil,
                measure: WeightedLayoutTests.measure([
                    CGSize(width: 70, height: 15),
                    CGSize(width: 25, height: 35),
                    CGSize(width: 45, height: 25),
                ])
            )

            let span = axis == .horizontal ? result.frames.last?.cell.maxX : result.frames.last?.cell.maxY
            let reported = axis == .horizontal ? result.size.width : result.size.height

            #expect(span == reported)
            #expect(WeightedLayoutTests.mainLengths(result, axis).reduce(0, +) + 12 == reported)
        }

        /// The size reported without a proposal, proposed back, splits into the same
        /// cells: a parent that measures with `nil` and places with the number it
        /// got must not see the items move.
        @Test(
            "Reported size proposed back keeps the cells",
            arguments: [
                // Row without a width: different content, weights 1 : 1.
                (Solver.Axis.horizontal, AdaptyUILayoutSizing.fill, CGFloat(0), [
                    WeightedLayoutTests.item(.weight(1)), WeightedLayoutTests.item(.weight(1)),
                ], [CGFloat(20), 100]),
                // Row without a width: weights 2 : 1, positive spacing.
                (.horizontal, .fill, 8, [
                    WeightedLayoutTests.item(.weight(2)), WeightedLayoutTests.item(.weight(1)),
                ], [50, 80]),
                // Row without a width: fixed and weighted items, both spacing signs.
                (.horizontal, .fill, 8, [
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(2)),
                ], [10, 30, 100]),
                (.horizontal, .fill, -10, [
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(2)),
                ], [10, 30, 100]),
                // Column without a height.
                (.vertical, .fill, 8, [
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(2)),
                ], [60, 120, 90]),
                (.vertical, .fill, -10, [
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(2)),
                ], [60, 120, 90]),
                // `hug` on both axes.
                (.horizontal, .hug, 8, [
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.points(60)),
                ], [10, 30, 100]),
                (.vertical, .hug, -10, [
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.points(60)),
                ], [10, 30, 100]),
            ] as [(Solver.Axis, AdaptyUILayoutSizing, CGFloat, [Solver.Item], [CGFloat])]
        )
        func reportedSizeProposedBackKeepsTheCells(
            axis: Solver.Axis,
            mainAxisSizing: AdaptyUILayoutSizing,
            spacing: CGFloat,
            items: [Solver.Item],
            naturalWidths: [CGFloat]
        ) {
            func solve(width: CGFloat?, height: CGFloat?) -> Solver.Result {
                Solver.solve(
                    axis: axis,
                    mainAxisSizing: mainAxisSizing,
                    crossAxisSizing: WeightedLayoutTests.historicalCrossAxisSizing(axis),
                    spacing: spacing,
                    items: items,
                    proposedWidth: width,
                    proposedHeight: height,
                    measure: WeightedLayoutTests.textMeasure(naturalWidths)
                )
            }

            let unspecified = solve(width: nil, height: nil)
            let proposedBack = solve(width: unspecified.size.width, height: unspecified.size.height)

            #expect(proposedBack == unspecified)
        }

        /// The same proposal gives the same answer, whatever was asked before.
        @Test("Answer depends only on the proposal")
        func answerDependsOnlyOnTheProposal() {
            func solve(_ width: CGFloat?) -> Solver.Result {
                Solver.solve(
                    axis: .horizontal,
                    mainAxisSizing: .fill,
                    crossAxisSizing: .hug,
                    spacing: 4,
                    items: [
                        WeightedLayoutTests.item(.points(50)),
                        WeightedLayoutTests.item(.weight(1)),
                    ],
                    proposedWidth: width,
                    proposedHeight: nil,
                    measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 90, height: 20))
                )
            }

            let first = solve(300)
            _ = solve(nil)
            _ = solve(0)
            _ = solve(.infinity)

            #expect(solve(300) == first)
        }
    }

    @Suite(
        "Weighted Cross Axis",
        .story("Weighted Cross Axis")
    )
    struct CrossAxisTests {
        /// A hugging cross axis measures children with `nil` whatever the proposal,
        /// so a child that takes any offer does not stretch the row to it; a filling
        /// one passes the proposal through, `nil` included.
        @Test(
            "Cross-axis measurement follows the cross-axis sizing",
            arguments: [AdaptyUILayoutSizing.hug, .fill],
            [CGFloat?.none, 200]
        )
        func crossAxisMeasurementFollowsTheSizing(crossAxisSizing: AdaptyUILayoutSizing, height: CGFloat?) {
            var proposedHeights: [CGFloat?] = []

            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: crossAxisSizing,
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.points(100)),
                    WeightedLayoutTests.item(.points(100)),
                ],
                proposedWidth: 200,
                proposedHeight: height,
                measure: { index, _, proposedHeight in
                    proposedHeights.append(proposedHeight)
                    // The first child takes any height it is offered, like a box
                    // with `fill_max`.
                    return CGSize(width: 10, height: index == 0 ? proposedHeight ?? 30 : 60)
                }
            )

            switch crossAxisSizing {
            case .hug:
                #expect(proposedHeights == [nil, nil])
                #expect(result.size.height == 60)
            case .fill:
                // With a proposal a filling axis takes it without measuring.
                #expect(proposedHeights == (height == nil ? [nil, nil] : []))
                #expect(result.size.height == height ?? 60)
            }
            #expect(result.frames.map(\.cell.height) == [result.size.height, result.size.height])
        }

        /// A column takes the width it is offered without measuring anything.
        @Test("Column fills the proposed width")
        func columnFillsTheProposedWidth() {
            var measured = 0

            let result = Solver.solve(
                axis: .vertical,
                mainAxisSizing: .fill,
                crossAxisSizing: .fill,
                spacing: 0,
                items: [WeightedLayoutTests.item(.points(40))],
                proposedWidth: 320,
                proposedHeight: nil,
                measure: { _, _, _ in
                    measured += 1
                    return CGSize(width: 10, height: 10)
                }
            )

            #expect(measured == 0)
            #expect(result.size == CGSize(width: 320, height: 40))
            #expect(result.frames[0].cell.width == 320)
        }

        /// Without a width a column is as wide as its widest child, measured at the
        /// height the child gets.
        @Test("Unspecified column width takes the widest child")
        func unspecifiedColumnWidthTakesTheWidestChild() {
            let result = Solver.solve(
                axis: .vertical,
                mainAxisSizing: .fill,
                crossAxisSizing: .fill,
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(1)),
                ],
                proposedWidth: nil,
                proposedHeight: 100,
                measure: { index, proposedWidth, proposedHeight in
                    #expect(proposedWidth == nil)
                    #expect(proposedHeight == [40, 60][index])
                    return CGSize(width: index == 0 ? 120 : 80, height: 10)
                }
            )

            #expect(result.size == CGSize(width: 120, height: 100))
            #expect(result.frames.map(\.cell.width) == [120, 120])
        }

        /// The cross axis sizes by the same rule as the main axis, whichever axis
        /// is the main one: `fill` takes the proposal and falls back to the largest
        /// child, `hug` always takes the largest child.
        @Test(
            "Cross-axis sizing follows the main-axis rule",
            arguments: [Solver.Axis.horizontal, .vertical],
            [
                (AdaptyUILayoutSizing.fill, CGFloat?(200), CGFloat(200)),
                (.fill, nil, 60),
                (.hug, 200, 60),
                (.hug, nil, 60),
            ]
        )
        func crossAxisSizingFollowsTheMainAxisRule(
            axis: Solver.Axis,
            sizing: (crossAxisSizing: AdaptyUILayoutSizing, proposal: CGFloat?, expected: CGFloat)
        ) {
            let result = Solver.solve(
                axis: axis,
                mainAxisSizing: .hug,
                crossAxisSizing: sizing.crossAxisSizing,
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.points(50)),
                    WeightedLayoutTests.item(.points(50)),
                ],
                proposedWidth: axis == .horizontal ? nil : sizing.proposal,
                proposedHeight: axis == .horizontal ? sizing.proposal : nil,
                measure: { index, _, _ in
                    let cross: CGFloat = index == 0 ? 30 : 60
                    return axis == .horizontal ? CGSize(width: 10, height: cross) : CGSize(width: cross, height: 10)
                }
            )

            let cross = axis == .horizontal ? result.size.height : result.size.width
            #expect(cross == sizing.expected)
        }
    }

    @Suite(
        "Weighted Probes",
        .story("Weighted Probes")
    )
    struct ProbeTests {
        /// A zero proposal leaves weights nothing and keeps fixed items.
        @Test("Zero proposal")
        func zeroProposal() {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 8,
                items: [
                    WeightedLayoutTests.item(.points(40)),
                    WeightedLayoutTests.item(.weight(1)),
                ],
                proposedWidth: 0,
                proposedHeight: 0,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 20))
            )

            #expect(WeightedLayoutTests.mainLengths(result, .horizontal) == [40, 0])
            #expect(result.size == CGSize(width: 0, height: 20))
        }

        /// An infinite proposal is a length like any other: `fill` reports it and
        /// the weights share it, while `hug` keeps the content length.
        @Test("Infinite proposal")
        func infiniteProposal() {
            let items = [
                WeightedLayoutTests.item(.points(40)),
                WeightedLayoutTests.item(.weight(1)),
            ]

            let fill = Solver.solve(
                axis: .vertical,
                mainAxisSizing: .fill,
                crossAxisSizing: .fill,
                spacing: 0,
                items: items,
                proposedWidth: .infinity,
                proposedHeight: .infinity,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 20))
            )

            #expect(fill.size == CGSize(width: CGFloat.infinity, height: .infinity))
            #expect(WeightedLayoutTests.mainLengths(fill, .vertical) == [40, .infinity])

            let hug = Solver.solve(
                axis: .vertical,
                mainAxisSizing: .hug,
                crossAxisSizing: .fill,
                spacing: 0,
                items: items,
                proposedWidth: 200,
                proposedHeight: .infinity,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 20))
            )

            #expect(hug.size == CGSize(width: 200, height: 40))
        }
    }

    @Suite(
        "Weighted Placement",
        .story("Weighted Placement")
    )
    struct PlacementTests {
        /// Each child is anchored inside its own cell.
        @Test("Children are anchored inside their cells")
        func childrenAreAnchoredInsideTheirCells() {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 0,
                items: [
                    WeightedLayoutTests.item(.weight(1), anchorX: 0, anchorY: 0),
                    WeightedLayoutTests.item(.weight(1)),
                    WeightedLayoutTests.item(.weight(1), anchorX: 1, anchorY: 1),
                ],
                proposedWidth: 270,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 80))
            )

            #expect(result.frames.map(\.anchor) == [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 135, y: 40),
                CGPoint(x: 270, y: 80),
            ])
        }

        /// Cells run from the leading edge in configuration order whatever the
        /// interface direction: SwiftUI mirrors a layout's placement for
        /// right-to-left itself, and the anchors arrive already mapped (`left`
        /// becomes `1`), so mirroring here would undo it.
        @Test("Right-to-left anchors are not mirrored again")
        func rightToLeftAnchorsAreNotMirroredAgain() {
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .fill,
                crossAxisSizing: .hug,
                spacing: 10,
                items: [
                    WeightedLayoutTests.item(.points(50), anchorX: 1),
                    WeightedLayoutTests.item(.points(50), anchorX: 0),
                ],
                proposedWidth: 200,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 10))
            )

            #expect(result.frames.map(\.cell.minX) == [0, 60])
            #expect(result.frames.map(\.anchor.x) == [50, 60])
        }
    }

    @Suite(
        "Weighted Rendered Items",
        .story("Weighted Rendered Items")
    )
    struct RenderedItemsTests {
        @Test("One subview per item keeps every item")
        func oneSubviewPerItem() {
            #expect(Solver.rendered(itemCount: 3, subviewItems: [0, 1, 2]) == [
                .init(item: 0, subviews: [0]),
                .init(item: 1, subviews: [1]),
                .init(item: 2, subviews: [2]),
            ])
        }

        /// An element that renders nothing drops out, so its neighbours become
        /// adjacent and only one spacing separates them, as in a native stack.
        @Test("An item without a subview drops out with its spacing")
        func itemWithoutSubviewDropsOut() {
            let rendered = Solver.rendered(itemCount: 3, subviewItems: [0, 2])
            #expect(rendered == [
                .init(item: 0, subviews: [0]),
                .init(item: 2, subviews: [1]),
            ])

            let items = [
                WeightedLayoutTests.item(.points(50)),
                WeightedLayoutTests.item(.points(30)),
                WeightedLayoutTests.item(.points(50)),
            ]
            let result = Solver.solve(
                axis: .horizontal,
                mainAxisSizing: .hug,
                crossAxisSizing: .hug,
                spacing: 10,
                items: rendered.map { items[$0.item] },
                proposedWidth: nil,
                proposedHeight: nil,
                measure: WeightedLayoutTests.fixedMeasure(CGSize(width: 10, height: 10))
            )

            #expect(result.size.width == 110)
            #expect(result.frames.map(\.cell.minX) == [0, 60])
        }

        @Test("Several subviews of one item stay one item")
        func severalSubviewsStayOneItem() {
            #expect(Solver.rendered(itemCount: 2, subviewItems: [0, 0, 1]) == [
                .init(item: 0, subviews: [0, 1]),
                .init(item: 1, subviews: [2]),
            ])
        }

        @Test("Subviews without a known item are left out")
        func unknownSubviewsAreLeftOut() {
            #expect(Solver.rendered(itemCount: 2, subviewItems: [nil, 1, 5, -1]) == [
                .init(item: 1, subviews: [1]),
            ])
            #expect(Solver.rendered(itemCount: 2, subviewItems: []).isEmpty)
        }
    }
}
