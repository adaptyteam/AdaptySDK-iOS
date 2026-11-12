//
//  AdaptyUIProposalEnvironment.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

/// The axes on which this subtree has no length from above: its proposal there is
/// no length of the parent's, whatever number it carries.
///
/// A proposal does not say where its number comes from. Without a length a
/// parent may still hand one down: a native stack in a scroll places a child with
/// a share of a length it never had, and SwiftUI on iOS 16 measures and places
/// such a child with made-up heights; a parent may place a child with the size
/// the child answered. A container that picks its layout from `available_*`
/// would compare that number and lay out differently from what it was measured
/// for. Such containers read the proposal only on the axes not declared here.
///
/// The axis is declared where a length stops coming from above — the scroll axis
/// of a scroll container, vertical in all of them here, a footer that hugs its
/// content, a `box` that shrinks — and cleared where a length is handed down
/// again: a `box` of a fixed length, a cell of a fixed length, a `deck` item of a
/// fixed length, a `pager` page, the cover of a hero screen. A view that passes
/// its own proposal on, clamped or not, declares nothing.
struct AdaptyUIUnspecifiedProposalAxesKey: EnvironmentKey {
    static let defaultValue: Axis.Set = []
}

/// The axes on which a box with `shrink` hugs this subtree.
///
/// Unlike `AdaptyUIUnspecifiedProposalAxesKey` it is set by the box alone, not by
/// scroll axes and footers: a container that picks its layout from `available_*`
/// compares an axis without a length with its own content under such a box and
/// with the screen anywhere else.
struct AdaptyUIHuggedAxesKey: EnvironmentKey {
    static let defaultValue: Axis.Set = []
}

extension EnvironmentValues {
    var adaptyUnspecifiedProposalAxes: Axis.Set {
        get { self[AdaptyUIUnspecifiedProposalAxesKey.self] }
        set { self[AdaptyUIUnspecifiedProposalAxesKey.self] = newValue }
    }

    var adaptyHuggedAxes: Axis.Set {
        get { self[AdaptyUIHuggedAxesKey.self] }
        set { self[AdaptyUIHuggedAxesKey.self] = newValue }
    }
}

extension View {
    /// Declares what this view proposes to its content on `axes`. A view that leaves
    /// the length to the content passes `true`; one that hands down a length of its
    /// own passes `false`. `nil` declares nothing, and so does leaving an axis out of
    /// `axes`: both keep the value set further up, which is also what a view that
    /// merely forwards its own proposal must do by not calling this at all.
    /// See `AdaptyUIUnspecifiedProposalAxesKey`.
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

    /// Declares whether a box hugs its content on `axes`, by the same rule as
    /// `declaringProposal(_:unspecified:)`: `true` hugs, `false` hands down a
    /// length, `nil` keeps what was declared further up.
    @ViewBuilder
    func declaringHug(_ axes: Axis.Set, _ hugs: Bool?) -> some View {
        if let hugs {
            transformEnvironment(\.adaptyHuggedAxes) {
                if hugs { $0.formUnion(axes) } else { $0.subtract(axes) }
            }
        } else {
            self
        }
    }
}

#endif
