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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Purchaser: StorekitPurchaser {}
