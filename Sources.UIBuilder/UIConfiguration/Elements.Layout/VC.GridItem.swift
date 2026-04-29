//
//  VC.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension VC {
    struct GridItem: Sendable, Hashable {
        let length: Length
        let horizontalAlignment: VC.HorizontalAlignment
        let verticalAlignment: VC.VerticalAlignment
        let content: ElementIndex
    }
}
