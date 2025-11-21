//
//  VC.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

package extension VC {
    struct Screen: Sendable, Hashable {
        static let defaultBackground: VC.Background = .filling(.same(.solidColor(.black)))

        package let background: VC.Background
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let overlay: Element?
        package let selectedAdaptyProductId: String?
    }
}

#if DEBUG
package extension VC.Screen {
    static func create(
        background: VC.Background = VC.Screen.defaultBackground,
        cover: VC.Box? = nil,
        content: VC.Element,
        footer: VC.Element? = nil,
        overlay: VC.Element? = nil,
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
