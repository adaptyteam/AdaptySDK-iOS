//
//  StoreKitProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import StoreKit

enum ProductsFetchPolicy: Sendable, Hashable {
    case `default`
    case returnCacheDataElseLoad
}

protocol StoreKitProductsManager: Actor, Sendable {
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK1Transaction: (value: SK1Transaction, id: String)
    ) async -> PurchasedTransaction

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func fillPurchasedTransaction(
        variationId: String?,
        persistentVariationId: String?,
        purchasedSK2Transaction: SK2Transaction
    ) async -> PurchasedTransaction
}
