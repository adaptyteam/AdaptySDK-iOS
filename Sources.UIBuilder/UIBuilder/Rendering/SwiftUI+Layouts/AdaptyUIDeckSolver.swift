//
//  AdaptyUIDeckSolver.swift
//  AdaptyUIBuilder
//

import Foundation

/// Layout arithmetic of the `Deck` element.
///
/// Deliberately free of SwiftUI and of `#if canImport(UIKit)`: the contract is
/// then covered by unit tests that run on a plain `swift test` instead of only in
/// a simulator build. `AdaptyUIDeckLayout` is the SwiftUI side of this.
enum AdaptyUIDeckSolver {
    /// A `DeckItem` length with every unit already resolved to points, so the
    /// arithmetic below needs neither the environment nor the layout direction.
    enum Length: Sendable, Equatable {
        /// No length in the configuration: the child is sized by its content.
        case content
        case points(CGFloat)
        /// A fraction of the deck's inner size along the same axis.
        case parent(CGFloat)
    }

    /// One child as the layout sees it. Anchors are fractions of the free space —
    /// `0` leading/top, `0.5` center, `1` trailing/bottom — already mapped for the
    /// current layout direction.
    struct Item: Sendable, Equatable {
        let width: Length
        let height: Length
        let anchorX: CGFloat
        let anchorY: CGFloat
    }

    /// The deck's inner size plus one frame per child, in the deck's own
    /// coordinate space with the origin at its inner top-leading corner.
    struct Result: Sendable, Equatable {
        let size: CGSize
        let frames: [CGRect]
    }

    /// Inner size an axis falls back to when nothing finite constrains it: `fill`
    /// in unbounded space, or `hug` whose children are all `parent`-sized.
    static let fallbackLength: CGFloat = 10

    /// Resolves the deck and its children.
    ///
    /// The width pass runs first so a content height is measured against a width
    /// that is already final and text wraps inside it. A child sized by its content
    /// across takes its height from the same measurement that gave its width:
    /// asking again with that width would hand the child its own answer, and
    /// content that picks its layout from the proposal could answer for another
    /// layout than the one it is placed with. A `parent` child never
    /// sizes the deck: it is excluded from a `hug` measurement and then takes its
    /// fraction of the result, overflowing the deck when the fraction exceeds `1`.
    ///
    /// `measure` reports the size of child `index` for a proposal where `nil` on
    /// an axis asks for the child's own extent along it. It is called only for
    /// children whose length on that axis is `.content`.
    ///
    /// Every size here is the deck's *inner* area: padding belongs to the
    /// surrounding decorator, so both the proposal and the result exclude it.
    static func solve(
        width widthMode: AdaptyUILayoutSizing,
        height heightMode: AdaptyUILayoutSizing,
        items: [Item],
        proposedWidth: CGFloat?,
        proposedHeight: CGFloat?,
        measure: (_ index: Int, _ proposedWidth: CGFloat?, _ proposedHeight: CGFloat?) -> CGSize
    ) -> Result {
        var naturalSizes = [CGSize?](repeating: nil, count: items.count)
        for (index, item) in items.enumerated() where item.width == .content {
            naturalSizes[index] = measure(index, nil, nil)
        }
        let naturalWidths = naturalSizes.map { $0?.width }

        let width = innerLength(
            mode: widthMode,
            proposed: proposedWidth,
            bases: items.indices.map { baseLength(items[$0].width, natural: naturalWidths[$0]) }
        )

        let childWidths = items.indices.map {
            resolvedLength(items[$0].width, natural: naturalWidths[$0], inner: width)
        }

        var contentHeights = [CGFloat?](repeating: nil, count: items.count)
        for (index, item) in items.enumerated() where item.height == .content {
            contentHeights[index] = (naturalSizes[index] ?? measure(index, childWidths[index], nil)).height
        }

        let height = innerLength(
            mode: heightMode,
            proposed: proposedHeight,
            bases: items.indices.map { baseLength(items[$0].height, natural: contentHeights[$0]) }
        )

        let frames = items.indices.map { index in
            let size = CGSize(
                width: childWidths[index],
                height: resolvedLength(items[index].height, natural: contentHeights[index], inner: height)
            )

            return CGRect(
                origin: CGPoint(
                    x: items[index].anchorX * (width - size.width),
                    y: items[index].anchorY * (height - size.height)
                ),
                size: size
            )
        }

        return Result(size: CGSize(width: width, height: height), frames: frames)
    }

    /// The deck's inner size along one axis.
    private static func innerLength(
        mode: AdaptyUILayoutSizing,
        proposed: CGFloat?,
        bases: [CGFloat?]
    ) -> CGFloat {
        switch mode {
        case .hug:
            bases.compactMap { $0 }.max() ?? fallbackLength
        case .fill:
            if let proposed, proposed.isFinite { max(0, proposed) } else { fallbackLength }
        }
    }

    /// The size a child contributes to a `hug` axis. `parent` children are
    /// excluded by contract: they follow the deck instead of sizing it.
    private static func baseLength(_ length: Length, natural: CGFloat?) -> CGFloat? {
        switch length {
        case .content: natural.map { max(0, $0) }
        case let .points(value): max(0, value)
        case .parent: nil
        }
    }

    /// The final size of one child along an axis whose deck size is known.
    private static func resolvedLength(_ length: Length, natural: CGFloat?, inner: CGFloat) -> CGFloat {
        switch length {
        case .content: max(0, natural ?? 0)
        case let .points(value): max(0, value)
        case let .parent(factor): max(0, factor * inner)
        }
    }
}
