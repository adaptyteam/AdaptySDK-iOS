//
//  Screen.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension AdaptyUI {
    package struct Screen: Hashable, Sendable {
        static let defaultBackground: AdaptyUI.Background = .filling(.color(AdaptyUI.Color.black))

        package let background: AdaptyUI.Background
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
        package let selectedAdaptyProductId: String?
    }
}

#if DEBUG
    package extension AdaptyUI.Screen {
        static func create(
            background: AdaptyUI.Background = AdaptyUI.Screen.defaultBackground,
            cover: AdaptyUI.Box? = nil,
            content: AdaptyUI.Element,
            footer: AdaptyUI.Element? = nil,
            overlay: AdaptyUI.Element? = nil,
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
