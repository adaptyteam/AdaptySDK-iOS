//
//  VC.AlignedElement.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 12.03.2026.
//

import Foundation

extension VC {
    struct AlignedElement: Hashable {
        let horizontalAlignment: VC.HorizontalAlignment
        let verticalAlignment: VC.VerticalAlignment
        let content: ElementIndex
    }
}
