//
//  Action.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    package enum ActionAction: Sendable {
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

extension AdaptyUI.ActionAction: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .openUrl(value):
            hasher.combine(value)
        case let .custom(value):
            hasher.combine(value)
        case let .selectProduct(id, groupId):
            hasher.combine(id)
            hasher.combine(groupId)
        case let .purchaseProduct(id):
            hasher.combine(id)
        case let .unselectProduct(groupId):
            hasher.combine(groupId)
        case let .purchaseSelectedProduct(groupId):
            hasher.combine(groupId)
        case let .switchSection(id, index):
            hasher.combine(id)
            hasher.combine(index)
        case let .openScreen(id):
            hasher.combine(id)
        case .restore, .close, .closeScreen:
            break
        }
    }
}
