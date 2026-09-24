//
//  AdaptyUILineHeightMultipleModifier.swift
//  AdaptyUIBuilder
//

import Foundation

/// How a text element's `line_height` maps onto `_lineHeightMultiple`.
/// `nil` when nothing has to be applied.
struct AdaptyUILineHeightAdjustment: Equatable {
    let multiple: CGFloat
    let topPadding: CGFloat

    init?(lineHeight: CGFloat?, naturalLineHeight: CGFloat) {
        guard let lineHeight, naturalLineHeight > 0, lineHeight != naturalLineHeight else { return nil }
        multiple = lineHeight / naturalLineHeight
        topPadding = max(0, naturalLineHeight - lineHeight)
    }
}

#if canImport(UIKit)

import SwiftUI

extension View {
    /// Applies `line_height` as an absolute distance between lines, the way
    /// Android's `TextStyle.lineHeight` does, for tighter and looser lines alike.
    ///
    /// Why `EnvironmentValues._lineHeightMultiple`:
    ///
    /// - `.lineSpacing()` can only add space: SwiftUI discards a negative value,
    ///   so a `line_height` below the font's natural height never tightened the text.
    /// - `.lineHeight(.exact(points:))` (iOS 26+) is the public absolute API, but it
    ///   sizes the frame to `lines × lineHeight` and clips the glyphs of the last line
    ///   whenever the line is tighter than the font.
    /// - `_lineHeightMultiple` (iOS 14+) scales every line by
    ///   `lineHeight / font.lineHeight`. It is declared `public` in SwiftUICore and
    ///   exported in its `.tbd`, so App Review does not treat it as a private API, but
    ///   it is undocumented. If a future iOS changes its behaviour, the replacement is
    ///   `.lineHeight(.exact(points:))` plus a fix for the clipped last line.
    ///
    /// For a line tighter than the font, `_lineHeightMultiple` takes the whole
    /// difference from above the first line: its ascenders leave the frame and a
    /// decorated parent clips them. The top padding gives that space back, so the
    /// frame becomes `ascent + (lines − 1) × lineHeight + descent`, the frame Android
    /// produces. For a looser line the frame is already `lines × lineHeight`.
    ///
    /// `font` must be the font the text is actually rendered with, including the
    /// element's own `size`, otherwise the multiple is computed from the wrong height.
    @ViewBuilder
    func lineHeightMultiple(_ lineHeight: CGFloat?, font: UIFont) -> some View {
        if let adjustment = AdaptyUILineHeightAdjustment(
            lineHeight: lineHeight,
            naturalLineHeight: font.lineHeight
        ) {
            if adjustment.topPadding > 0 {
                environment(\._lineHeightMultiple, adjustment.multiple)
                    .padding(.top, adjustment.topPadding)
            } else {
                environment(\._lineHeightMultiple, adjustment.multiple)
            }
        } else {
            self
        }
    }
}

#endif
