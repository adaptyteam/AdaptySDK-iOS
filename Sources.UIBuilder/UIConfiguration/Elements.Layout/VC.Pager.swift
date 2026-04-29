//
//  VC.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

extension VC {
    struct Pager: Sendable, Hashable {
        let pageWidth: Length
        let pageHeight: Length
        let pagePadding: EdgeInsets
        let spacing: Double
        let content: [ElementIndex]
        let pageControl: PageControl?
        let animation: Animation?
        let interactionBehavior: InteractionBehavior
        let pageIndex: Variable?
    }
}
