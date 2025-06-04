//
//  Section.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Section: Sendable, Hashable {
        package let id: String
        package let index: Int
        package let content: [Element]
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Section {
        static func create(
            id: String = UUID().uuidString,
            index: Int = 0,
            content: [AdaptyViewConfiguration.Element]
        ) -> Self {
            .init(
                id: id,
                index: index,
                content: content
            )
        }
    }
#endif
