//
//  Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUICore {
    package struct Screen: Sendable, Hashable {
        static let defaultBackground: AdaptyUICore.Background = .filling(.same(.solidColor(.black)))

        package let background: AdaptyUICore.Background
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
        package let selectedAdaptyProductId: String?
    }
}

#if DEBUG
    package extension AdaptyUICore.Screen {
        static func create(
            background: AdaptyUICore.Background = AdaptyUICore.Screen.defaultBackground,
            cover: AdaptyUICore.Box? = nil,
            content: AdaptyUICore.Element,
            footer: AdaptyUICore.Element? = nil,
            overlay: AdaptyUICore.Element? = nil,
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
