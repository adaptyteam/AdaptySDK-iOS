//
//  VC.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

extension VC {
    struct Pager: Sendable {
        let pageWidth: Length
        let pageHeight: Length
        let pagePadding: EdgeInsets
        let edgePageOverrides: EdgePageOverrides?
        let spacing: Double
        let content: [ElementIndex]
        let pageControl: PageControl?
        let animation: Animation?
        let interactionBehavior: InteractionBehavior
        let pageIndex: Variable?
    }
}

extension VC.Pager {
    @available(*, deprecated, renamed: "edgePageOverrides.leadingPadding")
    var firstPageInset: Length? {
        edgePageOverrides?.leadingPadding.map { Length.fixed($0) }
    }

    @available(*, deprecated, renamed: "edgePageOverrides.trailingPadding")
    var lastPageInset: Length? {
        edgePageOverrides?.trailingPadding.map { Length.fixed($0) }
    }
}
