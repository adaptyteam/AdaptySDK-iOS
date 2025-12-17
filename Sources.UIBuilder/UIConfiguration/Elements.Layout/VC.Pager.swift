//
//  VC.Pager.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.05.2024
//

import Foundation

package extension VC {
    struct Pager: Sendable, Hashable {
        package let pageWidth: Length
        package let pageHeight: Length
        package let pagePadding: EdgeInsets
        package let spacing: Double
        package let content: [Element]
        package let pageControl: PageControl?
        package let animation: Animation?
        package let interactionBehavior: InteractionBehavior
    }
}
