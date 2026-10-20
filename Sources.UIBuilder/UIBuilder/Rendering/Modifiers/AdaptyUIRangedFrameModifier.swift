//
//  AdaptyUIRangedFrameModifier.swift
//
//
//  Created by Aleksey Goncharov on 16.05.2024.
//

#if canImport(UIKit)

import SwiftUI

extension Double {
    var cgFloatValue: CGFloat { CGFloat(self) }
}

struct AdaptyUIRangedFrameModifier: ViewModifier {
    typealias Constraints = (min: Double?, max: Double?, shrink: Bool)

    @Environment(\.adaptyScreenSize)
    private var screenSize: CGSize
    @Environment(\.adaptySafeAreaInsets)
    private var safeArea: EdgeInsets
    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    var box: VC.Box

    private func constraints(
        for lenght: VC.Box.Length?,
        screenSize: CGFloat,
        safeAreaStart: Double,
        safeAreaEnd: Double
    ) -> Constraints {
        switch lenght {
        case let .flexible(min, max):
            (
                min: min?.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                max: max?.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                false
            )
        case let .shrinkable(min, max):
            (
                min: min.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                max: max?.points(
                    screenSize: screenSize,
                    safeAreaStart: safeAreaStart,
                    safeAreaEnd: safeAreaEnd
                ),
                true
            )
        case .fillMax: (min: nil, max: .infinity, false)
        default: (min: nil, max: nil, false)
        }
    }

    func body(content: Content) -> some View {
        let wConstraints = self.constraints(
            for: self.box.width,
            screenSize: self.screenSize.width,
            safeAreaStart: self.safeArea.leading,
            safeAreaEnd: self.safeArea.trailing
        )
        let hConstraints = self.constraints(
            for: self.box.height,
            screenSize: self.screenSize.height,
            safeAreaStart: self.safeArea.top,
            safeAreaEnd: self.safeArea.bottom
        )

        self.framed(content, wConstraints, hConstraints)
            .declaringProposal(.horizontal, unspecified: self.unspecifiedProposal(wConstraints))
            .declaringProposal(.vertical, unspecified: self.unspecifiedProposal(hConstraints))
    }

    /// A `shrink` length proposes an unspecified length to the content — that is what
    /// `fixedSize` does — and any other constraint on the axis hands one down. An axis
    /// the box constrains in no way declares nothing, so the content keeps whatever the
    /// enclosing box declared. See `AdaptyUIUnspecifiedProposalAxesKey`.
    private func unspecifiedProposal(_ constraints: Constraints) -> Bool? {
        if constraints.shrink {
            true
        } else if constraints.min != nil || constraints.max != nil {
            false
        } else {
            nil
        }
    }

    @ViewBuilder
    private func framed(
        _ content: Content,
        _ wConstraints: Constraints,
        _ hConstraints: Constraints
    ) -> some View {
        if wConstraints.min == nil && wConstraints.max == nil && wConstraints.shrink == false &&
            hConstraints.min == nil && hConstraints.max == nil && hConstraints.shrink == false
        {
            content
        } else if wConstraints.min == nil && wConstraints.max == nil &&
            hConstraints.min == nil && hConstraints.max == nil
        {
            content
                .fixedSize(
                    horizontal: wConstraints.shrink,
                    vertical: hConstraints.shrink
                )
        } else {
            content
                .frame(
                    minWidth: wConstraints.min?.cgFloatValue,
                    maxWidth: wConstraints.max?.cgFloatValue,
                    minHeight: hConstraints.min?.cgFloatValue,
                    maxHeight: hConstraints.max?.cgFloatValue,
                    alignment: .from(
                        horizontal: self.box.horizontalAlignment.swiftuiValue(with: self.layoutDirection),
                        vertical: self.box.verticalAlignment.swiftuiValue
                    )
                )
                .fixedSize(
                    horizontal: wConstraints.shrink,
                    vertical: hConstraints.shrink
                )
        }
    }
}

extension View {
    func rangedFrame(box: VC.Box) -> some View {
        modifier(AdaptyUIRangedFrameModifier(box: box))
    }
}

#endif
