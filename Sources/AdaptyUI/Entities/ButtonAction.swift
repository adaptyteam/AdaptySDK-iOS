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
        case selectProductId(id: String)
        case purchaseProductId(id: String)
        case purchaseSelectedProduct
        case close
        case switchSection(id: String, index: Int)
        case openScreen(id: String)
        case closeScreen

    }
}
