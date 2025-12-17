//
//  VC.GridItem.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

package extension VC {
    struct GridItem: Sendable, Hashable {
        package let length: Length
        package let horizontalAlignment: VC.HorizontalAlignment
        package let verticalAlignment: VC.VerticalAlignment
        package let content: VC.Element
    }
}
