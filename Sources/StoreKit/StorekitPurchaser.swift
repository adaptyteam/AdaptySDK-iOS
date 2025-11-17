//
//  StorekitPurchaser.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 06.08.2025.
//

import StoreKit

protocol StorekitPurchaser: Actor, Sendable {
    func makePurchase(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        product: AdaptyPaywallProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult
}

extension SK1QueueManager: StorekitPurchaser {}

extension SK2Purchaser: StorekitPurchaser {}
