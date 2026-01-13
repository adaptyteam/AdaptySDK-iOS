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
        package let color: VC.AssetReference?
        package let selectedColor: VC.AssetReference?
    }
}
