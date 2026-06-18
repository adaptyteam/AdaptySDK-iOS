//
//  VC.Pager.LastPagePositioning.swift
//  AdaptyUIBuilder
//

import Foundation

extension VC.Pager {
    /// Horizontal positioning of the last page when `pageWidth` is smaller than
    /// the pager viewport.
    ///
    /// - `leading`: the last page is leading-snapped like every other page, which
    ///   leaves an empty trailing gap (legacy behaviour, the default).
    /// - `trailing`: the scroll is clamped so the last page is pinned to the
    ///   trailing edge of the viewport, removing the gap.
    enum LastPagePositioning: Sendable {
        case leading
        case trailing
    }
}
