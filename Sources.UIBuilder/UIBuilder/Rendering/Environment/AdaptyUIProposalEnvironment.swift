//
//  AdaptyUIProposalEnvironment.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// The axes on which the parent proposes an unspecified length to this subtree.
///
/// A greedy `GeometryReader` cannot tell "proposal nil" from "proposal small" — it
/// sees a number either way — so the elements built on one floor themselves at their
/// measured content to survive a nil proposal. That floor is what makes the layout
/// ratchet: it is a hard minimum, so a smaller proposal never reaches the content, and
/// every parent above is pinned with it.
///
/// The one thing a reader cannot derive, it can be told. An unspecified length comes
/// from two kinds of place in the renderer: a view that hands its content a nil
/// proposal through `fixedSize` — a `box` that shrinks on an axis, a footer that hugs
/// its content — and the scroll axis of a scroll container, vertical in all of them
/// here. Those declare the axis, and the elements below floor an axis only while it is
/// declared.
struct AdaptyUIUnspecifiedProposalAxesKey: EnvironmentKey {
    static let defaultValue: Axis.Set = []
}

extension EnvironmentValues {
    var adaptyUnspecifiedProposalAxes: Axis.Set {
        get { self[AdaptyUIUnspecifiedProposalAxesKey.self] }
        set { self[AdaptyUIUnspecifiedProposalAxesKey.self] = newValue }
    }
}

extension View {
    /// Declares what this view proposes to its content on `axes`. A view that leaves
    /// the length to the content passes `true`; one that hands down a length of its
    /// own passes `false`. `nil` declares nothing, and so does leaving an axis out of
    /// `axes`: both keep the value set further up, which is also what a view that
    /// merely forwards its own proposal must do by not calling this at all.
    @ViewBuilder
    func declaringProposal(_ axes: Axis.Set, unspecified: Bool?) -> some View {
        if let unspecified {
            transformEnvironment(\.adaptyUnspecifiedProposalAxes) {
                if unspecified { $0.formUnion(axes) } else { $0.subtract(axes) }
            }
        } else {
            self
        }
    }
}

#endif
