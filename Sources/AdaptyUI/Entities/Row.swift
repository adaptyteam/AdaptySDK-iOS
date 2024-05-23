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
        static let `default` = Row(
            verticalAlignment: .center,
            spacing: 0,
            items: []
        )

        package let verticalAlignment: VerticalAlignment
        package let spacing: Double
        package let items: [RowOrColumnItem]
    }

    package enum RowOrColumnItem {
        case fixed(length: Unit, content: Element)
        case flexable(weight: Double, content: Element)
    }
}

#if DEBUG
    package extension AdaptyUI.Row {
        static func create(
            verticalAlignment: AdaptyUI.VerticalAlignment = `default`.verticalAlignment,
            spacing: Double = `default`.spacing,
            items: [AdaptyUI.RowOrColumnItem] = `default`.items
        ) -> Self {
            .init(
                verticalAlignment: verticalAlignment,
                spacing: spacing,
                items: items
            )
        }
    }
#endif
