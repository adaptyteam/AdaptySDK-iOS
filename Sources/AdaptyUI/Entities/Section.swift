//
//  Section.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 23.05.2024
//
//

import Foundation

extension AdaptyUI {
    package struct Section: Hashable, Sendable {
        package let id: String
        package let index: Int
        package let content: [Element]
    }
}

#if DEBUG
    package extension AdaptyUI.Section {
        static func create(
            id: String = UUID().uuidString,
            index: Int = 0,
            content: [AdaptyUI.Element]
        ) -> Self {
            .init(
                id: id,
                index: index,
                content: content
            )
        }
    }
#endif
