//
//  VC.Pager.PageControl.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension VC.Pager {
    struct PageControl: Sendable, Hashable {
        let layout: Layout
        let verticalAlignment: VC.VerticalAlignment
        let padding: VC.EdgeInsets
        let dotSize: Double
        let spacing: Double
        let color: VC.AssetReference?
        let selectedColor: VC.AssetReference?
    }
}
