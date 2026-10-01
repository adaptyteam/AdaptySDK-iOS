//
//  AdaptyUIProposalEnvironment.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// Whether the parent proposes an unspecified width to this subtree.
///
/// A greedy `GeometryReader` cannot tell "proposal nil" from "proposal small" — it
/// sees a number either way — so the elements built on one floor themselves at their
/// measured content to survive a nil proposal. On the width axis that floor is what
/// makes the layout ratchet: it is a hard minimum, so a narrower proposal never
/// reaches the content, and every parent above is pinned with it.
///
/// The one thing a reader cannot derive, it can be told. Unspecified width comes from
/// exactly one place in the renderer — a `box` whose width is `shrink`, which applies
/// `fixedSize(horizontal:)`; every scroll container here scrolls vertically, so the
/// scroll axis only ever leaves the height unspecified. That box sets this flag, and
/// the elements below floor their width only while it is set.
struct AdaptyUIUnspecifiedWidthProposalKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var adaptyUnspecifiedWidthProposal: Bool {
        get { self[AdaptyUIUnspecifiedWidthProposalKey.self] }
        set { self[AdaptyUIUnspecifiedWidthProposalKey.self] = newValue }
    }
}

extension View {
    /// Declares what this view proposes to its content on the width axis. A view that
    /// leaves the width to the content passes `true`; one that hands down a width of
    /// its own passes `false`. A view that merely forwards its own proposal must not
    /// call this at all, so the flag keeps the value set further up.
    func withUnspecifiedWidthProposal(_ value: Bool) -> some View {
        environment(\.adaptyUnspecifiedWidthProposal, value)
    }
}

#endif
