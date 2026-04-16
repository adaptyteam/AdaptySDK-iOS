//
//  VC.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension VC {
    struct Screen: Sendable, Hashable {
        let id: String
        let layoutBehaviour: LayoutBehaviour
        let cover: Box?
        let content: Element
        let footer: Element?
        let background: [AlignedElement]?
        let overlay: [AlignedElement]?
        let screenActions: ScreenActions
        let contentScrollValue: Variable?
        let footerScrollValue: Variable?
    }
}

