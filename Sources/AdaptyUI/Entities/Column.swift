//
//  Row.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Column {
        static let `default` = Column(
            horizontalAlignment: .center,
            spacing: 0,
            items: []
        )

        package let horizontalAlignment: HorizontalAlignment
        package let spacing: Double
        package let items: [RowOrColumnItem]
    }
}

#if DEBUG
    package extension AdaptyUI.Column {
        static func create(
            horizontalAlignment: AdaptyUI.HorizontalAlignment = `default`.horizontalAlignment,
            spacing: Double = `default`.spacing,
            items: [AdaptyUI.RowOrColumnItem] = `default`.items
        ) -> Self {
            .init(
                horizontalAlignment: horizontalAlignment,
                spacing: spacing,
                items: items
            )
        }
    }
#endif
