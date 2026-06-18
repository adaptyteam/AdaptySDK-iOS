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
        let spacing: Double
        let content: [ElementIndex]
        let pageControl: PageControl?
        let animation: Animation?
        let interactionBehavior: InteractionBehavior
        let pageIndex: Variable?
        let lastPagePositioning: LastPagePositioning
    }
}

extension VC.Pager {
    // TEMP: `lastPagePositioning` is not yet part of the schema. It is wired
    // through this constant so it can be toggled by hand (flip to `.trailing`)
    // until the field is decoded from the paywall config. Remove once the
    // schema exposes it.
    static let lastPagePositioningDefault: LastPagePositioning = .leading
}
