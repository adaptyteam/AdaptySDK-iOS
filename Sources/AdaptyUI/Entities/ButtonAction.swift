//
//  ButtonAction.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    package enum ButtonAction {
        case openUrl(String?)
        case restore
        case custom(id: String)
        case selectProduct(id: String, groupId: String)
        case purchaseProduct(id: String)
        case unselectProduct(groupId: String)
        case purchaseSelectedProduct(groupId: String)
        case close
        case switchSection(id: String, index: Int)
        case openScreen(id: String)
        case closeScreen
    }
}
