//
//  Action.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUICore {
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

extension AdaptyUICore.ActionAction: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .openUrl(value):
            hasher.combine(1)
            hasher.combine(value)
        case let .custom(value):
            hasher.combine(2)
            hasher.combine(value)
        case let .selectProduct(id, groupId):
            hasher.combine(3)
            hasher.combine(id)
            hasher.combine(groupId)
        case let .purchaseProduct(id):
            hasher.combine(4)
            hasher.combine(id)
        case let .unselectProduct(groupId):
            hasher.combine(5)
            hasher.combine(groupId)
        case let .purchaseSelectedProduct(groupId):
            hasher.combine(6)
            hasher.combine(groupId)
        case let .switchSection(id, index):
            hasher.combine(7)
            hasher.combine(id)
            hasher.combine(index)
        case let .openScreen(id):
            hasher.combine(8)
            hasher.combine(id)
        case .restore:
            hasher.combine(9)
        case .close:
            hasher.combine(10)
        case .closeScreen:
            hasher.combine(11)
        }
    }
}
