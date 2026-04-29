//
//  VC.Screen.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension VC {
    struct Screen: Sendable {
        let id: String
        let poolElements: [VC.Element]
        let layoutBehaviour: LayoutBehaviour
        let cover: Box?
        let content: ElementIndex
        let footer: ElementIndex?
        let background: [AlignedElement]?
        let overlay: [AlignedElement]?
        let screenActions: ScreenActions
        let contentScrollValue: Variable?
        let footerScrollValue: Variable?
    }
}

