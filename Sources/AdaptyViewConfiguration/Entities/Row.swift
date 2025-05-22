//
//  Row.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Row: Sendable, Hashable {
        package let spacing: Double
        package let items: [GridItem]
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Row {
        static func create(
            spacing: Double = 0,
            items: [AdaptyViewConfiguration.GridItem]
        ) -> Self {
            .init(
                spacing: spacing,
                items: items
            )
        }
    }
#endif
