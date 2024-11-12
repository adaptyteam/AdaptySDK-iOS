//
//  Screen.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyViewConfiguration {
    package struct Screen: Sendable, Hashable {
        static let defaultBackground: AdaptyViewConfiguration.Background = .filling(.same(.solidColor(.black)))

        package let background: AdaptyViewConfiguration.Background
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
        package let selectedAdaptyProductId: String?
    }
}

#if DEBUG
    package extension AdaptyViewConfiguration.Screen {
        static func create(
            background: AdaptyViewConfiguration.Background = AdaptyViewConfiguration.Screen.defaultBackground,
            cover: AdaptyViewConfiguration.Box? = nil,
            content: AdaptyViewConfiguration.Element,
            footer: AdaptyViewConfiguration.Element? = nil,
            overlay: AdaptyViewConfiguration.Element? = nil,
            selectedAdaptyProductId: String? = nil
        ) -> Self {
            .init(
                background: background,
                cover: cover,
                content: content,
                footer: footer,
                overlay: overlay,
                selectedAdaptyProductId: selectedAdaptyProductId
            )
        }
    }
#endif
