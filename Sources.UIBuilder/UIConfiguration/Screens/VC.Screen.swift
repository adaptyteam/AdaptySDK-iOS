//
//  VC.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

package extension VC {
    struct Screen: Sendable, Hashable {
        package let id: String
        package let layoutBehaviour: LayoutBehaviour
        package let cover: Box?
        package let content: Element
        package let footer: Element?
        package let screenActions: ScreenActions
    }
}
