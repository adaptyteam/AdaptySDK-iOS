//
//  VC.DeckItem+LayoutPoints.swift
//  AdaptyUIBuilder
//

import SwiftUI

extension VC.DeckItem {
    /// `anchor` in the coordinates a `Layout` places in, see `layoutPoint(_:with:)`.
    func layoutAnchor(with layoutDirection: LayoutDirection) -> CGPoint {
        layoutPoint(anchor, with: layoutDirection)
    }

    /// `position` in the coordinates a `Layout` places in, see `layoutPoint(_:with:)`.
    func layoutPosition(with layoutDirection: LayoutDirection) -> CGPoint {
        layoutPoint(position, with: layoutDirection)
    }

    /// The configuration gives physical points: `x = 0` is the left edge in both
    /// directions. SwiftUI mirrors a `Layout` in RTL, so its `x = 0` is the leading
    /// edge. A physical point therefore flips in RTL, while a point that mirrors with
    /// the interface — `mirrorInRTL`, which `leading`/`trailing` decode to — stays.
    private func layoutPoint(_ point: VC.Point, with layoutDirection: LayoutDirection) -> CGPoint {
        let flipsX = layoutDirection == .rightToLeft && !mirrorInRTL
        return CGPoint(x: flipsX ? 1 - point.x : point.x, y: point.y)
    }
}
