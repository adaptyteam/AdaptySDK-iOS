//
//  BottomSheet.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct BottomSheet: Sendable, Hashable {
        package let content: Element
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.BottomSheet {
        static func create(
            content: AdaptyViewConfiguration.Element
        ) -> Self {
            .init(
                content: content
            )
        }
    }
#endif
