//
//  VC.AlignedElement.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension VC {
    struct AlignedElement: Sendable {
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: ElementIndex
    }
}
