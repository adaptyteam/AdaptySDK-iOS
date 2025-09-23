//
//  Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUIConfiguration {
    package struct Screen: Sendable, Hashable {
        static let defaultBackground: AdaptyUIConfiguration.Background = .filling(.same(.solidColor(.black)))

        package let background: AdaptyUIConfiguration.Background
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
        package let selectedAdaptyProductId: String?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Screen {
    static func create(
        background: AdaptyUIConfiguration.Background = AdaptyUIConfiguration.Screen.defaultBackground,
        cover: AdaptyUIConfiguration.Box? = nil,
        content: AdaptyUIConfiguration.Element,
        footer: AdaptyUIConfiguration.Element? = nil,
        overlay: AdaptyUIConfiguration.Element? = nil,
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
