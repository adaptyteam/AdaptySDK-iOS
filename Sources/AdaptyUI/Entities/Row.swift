//
//  Row.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Row {
        package let spacing: Double
        package let items: [GridItem]
    }
}

#if DEBUG
    package extension AdaptyUI.Row {
        static func create(
            spacing: Double = 0,
            items: [AdaptyUI.GridItem]
        ) -> Self {
            .init(
                spacing: spacing,
                items: items
            )
        }
    }
#endif
