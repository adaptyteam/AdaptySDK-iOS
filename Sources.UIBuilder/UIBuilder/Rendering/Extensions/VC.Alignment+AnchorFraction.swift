//
//  VC.Alignment+AnchorFraction.swift
//  AdaptyUIBuilder
//

import SwiftUI

extension VC.HorizontalAlignment {
    /// Where the child sits in the free space along the horizontal axis: `0` at the
    /// leading edge, `0.5` centered, `1` at the trailing edge.
    ///
    /// A `Layout` places by fraction, while `swiftuiValue(with:)` returns an
    /// alignment guide, so the two cannot share a return type. The rules are the
    /// same ones: `leading` and `trailing` follow the interface direction, `left`
    /// and `right` stay physical, and `justified` behaves as `center` until its
    /// global semantics change.
    func anchorFraction(with layoutDirection: LayoutDirection) -> CGFloat {
        switch self {
        case .leading: 0
        case .trailing: 1
        case .center, .justified: 0.5
        case .left:
            switch layoutDirection {
            case .rightToLeft: 1
            default: 0
            }
        case .right:
            switch layoutDirection {
            case .rightToLeft: 0
            default: 1
            }
        }
    }
}

extension VC.VerticalAlignment {
    /// Where the child sits in the free space along the vertical axis: `0` at the
    /// top, `0.5` centered, `1` at the bottom.
    var anchorFraction: CGFloat {
        switch self {
        case .top: 0
        case .center: 0.5
        case .bottom: 1
        }
    }
}
