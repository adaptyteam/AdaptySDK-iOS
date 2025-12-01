//
//  VC.Pager.PageControl.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

package extension VC.Pager {
    struct PageControl: Sendable, Hashable {
        package let layout: Layout
        package let verticalAlignment: VC.VerticalAlignment
        package let padding: VC.EdgeInsets
        package let dotSize: Double
        package let spacing: Double
        package let color: VC.Mode<VC.Color>
        package let selectedColor: VC.Mode<VC.Color>
    }
}

extension VC.Pager.PageControl {
    static let `default`: Self = Self(
        layout: .stacked,
        verticalAlignment: .bottom,
        padding: .init(same: .point(6)),
        dotSize: 6,
        spacing: 6,
        color: .same(VC.Color.white),
        selectedColor: .same(.lightGray)
    )
}

#if DEBUG
package extension VC.Pager.PageControl {
    static func create(
        layout: Layout = `default`.layout,
        verticalAlignment: VC.VerticalAlignment = `default`.verticalAlignment,
        padding: VC.EdgeInsets = `default`.padding,
        dotSize: Double = `default`.dotSize,
        spacing: Double = `default`.spacing,
        color: VC.Mode<VC.Color> = `default`.color,
        selectedColor: VC.Mode<VC.Color> = `default`.selectedColor
    ) -> Self {
        .init(
            layout: layout,
            verticalAlignment: verticalAlignment,
            padding: padding,
            dotSize: dotSize,
            spacing: spacing,
            color: color,
            selectedColor: selectedColor
        )
    }
}
#endif
