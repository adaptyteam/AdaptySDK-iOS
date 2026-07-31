//
//  VC.GridItem+LayoutValues.swift
//  AdaptyUIBuilder
//

#if canImport(UIKit)

import SwiftUI

extension VC.GridItem.Length {
    /// Resolves the `VC.Unit` of a `fixed` length to points along `direction`.
    ///
    /// A `screen` unit measures against the width in row direction and the height
    /// in column direction, so this cannot be done before the axis is known — for
    /// `Flex` that is inside the layout pass.
    func resolved(
        _ direction: VC.Unit.Direction,
        _ screenSize: CGSize,
        _ safeArea: EdgeInsets
    ) -> VC.GridItem.ResolvedLength {
        switch self {
        case let .fixed(unit):
            .fixed(CGFloat(unit.points(direction, screenSize, safeArea)))
        case let .weight(weight):
            .weight(weight)
        }
    }
}

extension VC.GridItem {
    /// Where this item sits inside its slot, reusing the existing alignment
    /// mapping so the RTL rules are not restated.
    func anchor(with layoutDirection: LayoutDirection) -> UnitPoint {
        UnitPoint(
            x: horizontalAlignment.swiftuiValue(with: layoutDirection).adaptyAnchorFraction,
            y: verticalAlignment.swiftuiValue.adaptyAnchorFraction
        )
    }
}

#endif
