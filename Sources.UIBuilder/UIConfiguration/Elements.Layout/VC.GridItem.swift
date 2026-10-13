//
//  VC.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension VC {
    struct GridItem: Sendable {
        let length: Length
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: ElementIndex
    }
}
