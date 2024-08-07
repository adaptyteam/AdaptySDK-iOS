//
//  Column.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Column: Hashable, Sendable {
        package let spacing: Double
        package let items: [GridItem]
    }
}

#if DEBUG
    package extension AdaptyUI.Column {
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
