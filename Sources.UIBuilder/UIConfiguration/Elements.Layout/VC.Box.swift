//
//  VC.Box.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.03.2024
//

import Foundation

extension VC {
    struct Box: Sendable {
        let width: Length?
        let height: Length?
        let horizontalAlignment: HorizontalAlignment
        let verticalAlignment: VerticalAlignment
        let content: ElementIndex?
    }
}
