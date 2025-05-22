//
//  StoreKitProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import StoreKit

protocol StoreKitProductsManager: Actor, Sendable {
    func fillPurchasedTransaction(
        paywallVariationId: String?,
        persistentPaywallVariationId: String?,
        persistentOnboardingVariationId: String?,
        sk1Transaction: SK1TransactionWithIdentifier
    ) async -> PurchasedTransaction

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func fillPurchasedTransaction(
        paywallVariationId: String?,
        persistentPaywallVariationId: String?,
        persistentOnboardingVariationId: String?,
        sk2Transaction: SK2Transaction
    ) async -> PurchasedTransaction
}
