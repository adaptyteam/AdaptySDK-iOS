//
//  VC.Condition+Proposal.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

extension VC.Condition {
    /// Whether evaluating `conditions` needs the available size at all.
    ///
    /// `screen_*` and `orientation` come from the environment, so a condition set
    /// built only from those is a pure function of it — no measuring, no state, and
    /// it re-evaluates on its own when the environment changes. Only `available_*`
    /// ties the answer to the space the parent offers.
    static func readsAvailableSize(_ conditions: [VC.Condition]) -> Bool {
        conditions.contains { condition in
            switch condition {
            case .availableWidth, .availableHeight: true
            case .screenWidth, .screenHeight, .orientation: false
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
extension VC.Condition {
    /// The `available` size to evaluate `conditions` against, or `nil` when the
    /// proposal does not carry the axis a condition actually reads.
    ///
    /// Only the axes the conditions mention have to be concrete. Requiring both
    /// would make every `available_width` condition undecidable inside a parent
    /// that hugs its height (the common case: a card whose height comes from its
    /// content proposes `nil` height), silently falling back to the declared
    /// direction and never reacting to width at all.
    ///
    /// An axis proposed `nil` or infinite is SwiftUI probing for the smallest and
    /// largest size the layout accepts. Feeding those into an `available_*`
    /// condition would answer a question the parent did not ask, so the caller is
    /// told to reuse its previous decision instead.
    ///
    /// `.zero` is the third of SwiftUI's probe values — the one asking for the
    /// minimum size — and is treated the same way even though both of its axes are
    /// finite. Answering it literally would resolve every `available_*` condition
    /// against zero space, so a container would report its minimum for one
    /// direction and then lay out in the other, which is what the parent's own
    /// flexibility calculation is built on. A parent offering a genuinely empty rect
    /// is indistinguishable here, and reusing the last direction is the better
    /// answer for it too.
    static func availableSize(
        for conditions: [VC.Condition],
        proposal: ProposedViewSize
    ) -> CGSize? {
        guard proposal != .zero else { return nil }

        var size = CGSize.zero

        for condition in conditions {
            switch condition {
            case .availableWidth:
                guard let width = proposal.width, width.isFinite else { return nil }
                size.width = width
            case .availableHeight:
                guard let height = proposal.height, height.isFinite else { return nil }
                size.height = height
            case .screenWidth, .screenHeight, .orientation:
                // Resolved from the environment, not from the proposal.
                continue
            }
        }

        return size
    }
}

#endif
