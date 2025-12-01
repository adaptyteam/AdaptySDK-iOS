//
//  VC.Action.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension VC {
    enum Action: Sendable, Hashable {
        case openUrl(String?)
        case restore
        case custom(id: String)
        case selectProduct(id: String, groupId: String)
        case purchaseProduct(id: String, service: PaymentService)
        case unselectProduct(groupId: String)
        case purchaseSelectedProduct(groupId: String, service: PaymentService)
        case close
        case switchSection(id: String, index: Int)
        case openScreen(id: String)
        case closeScreen
        case openWebPaywall(openIn: WebOpenInParameter)
    }
}
