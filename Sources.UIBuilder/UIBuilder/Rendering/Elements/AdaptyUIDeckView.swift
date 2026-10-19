//
//  AdaptyUIDeckView.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 15.09.2026.
//

#if canImport(UIKit)

import SwiftUI

/// Renders a `Deck`: every child gets its own size and alignment inside one
/// shared area, layered in configuration order.
///
/// The view resolves units and alignment against the environment and hands plain
/// numbers to `AdaptyUIDeckLayout`, so the layout arithmetic stays independent of
/// both the environment and the interface direction.
@available(iOS 16.0, macOS 13.0, visionOS 1.0, *)
struct AdaptyUIDeckView<ScreenHolderContent: View>: View {
    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    private let deck: VC.Deck
    private let screenHolderBuilder: () -> ScreenHolderContent

    init(
        _ deck: VC.Deck,
        @ViewBuilder screenHolderBuilder: @escaping () -> ScreenHolderContent
    ) {
        self.deck = deck
        self.screenHolderBuilder = screenHolderBuilder
    }

    var body: some View {
        AdaptyUIDeckLayout(
            width: layoutSizing(deck.width),
            height: layoutSizing(deck.height),
            items: deck.items.map(layoutItem)
        ) {
            ForEach(0 ..< deck.items.count, id: \.self) { idx in
                // The wrapper turns the layout's proposal into the item's actual
                // size; without it a content-sized child would ignore it.
                AdaptyUIDeckItemLayout(contentAxes: contentAxes(deck.items[idx])) {
                    AdaptyUIElementView(
                        deck.items[idx].content,
                        screenHolderBuilder: screenHolderBuilder
                    )
                    .declaringProposal(.horizontal, unspecified: fixes(deck.items[idx].width) ? false : nil)
                    .declaringProposal(.vertical, unspecified: fixes(deck.items[idx].height) ? false : nil)
                }
            }
        }
    }

    private func layoutSizing(_ mode: VC.AutoSizeMode) -> AdaptyUILayoutSizing {
        switch mode {
        case .hug: .hug
        // The schema decodes only `hug` and `fill` for a deck, so `legacy` never
        // arrives here; were it to, it would behave as `fill`.
        case .fill, .legacy: .fill
        }
    }

    /// A fixed length is the item's own; a share of the deck is only as definite
    /// as the deck's.
    private func fixes(_ length: VC.DeckItem.Length) -> Bool {
        if case .fixed = length { true } else { false }
    }

    private func contentAxes(_ item: VC.DeckItem) -> Axis.Set {
        var axes: Axis.Set = []
        if case .content = item.width { axes.insert(.horizontal) }
        if case .content = item.height { axes.insert(.vertical) }
        return axes
    }

    private func layoutItem(_ item: VC.DeckItem) -> AdaptyUIDeckSolver.Item {
        .init(
            width: layoutLength(item.width, .horizontal),
            height: layoutLength(item.height, .vertical),
            anchorX: item.deprecatedHorizontalAlignment.anchorFraction(with: layoutDirection),
            anchorY: item.deprecatedVerticalAlignment.anchorFraction
        )
    }

    private func layoutLength(
        _ length: VC.DeckItem.Length,
        _ direction: VC.Unit.Direction
    ) -> AdaptyUIDeckSolver.Length {
        switch length {
        case .content:
            .content
        case let .fixed(unit):
            .points(unit.points(direction, screenSize, safeArea).cgFloatValue)
        case let .parent(factor):
            .parent(factor.cgFloatValue)
        }
    }
}

#endif
