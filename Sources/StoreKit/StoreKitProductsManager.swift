//
//  StoreKitProductsManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.10.2024
//

import StoreKit

protocol StoreKitProductsManager: Actor, Sendable {
    func fillPurchasedTransactionSK1(
        sk1Transaction: SK1TransactionWithIdentifier,
        payload: PurchasePayload?
    ) async -> PurchasedTransaction

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func fillPurchasedTransactionSK2(
        sk2Transaction: SK2Transaction,
        payload: PurchasePayload?
    ) async -> PurchasedTransaction
}

extension SK1ProductsManager: StoreKitProductsManager {
    func fillPurchasedTransactionSK1(
        sk1Transaction: SK1TransactionWithIdentifier,
        payload: PurchasePayload?
    ) async -> PurchasedTransaction {
        await PurchasedTransaction(
            sk1Product: try? fetchSK1Product(
                id: sk1Transaction.unfProductID,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            sk1Transaction: sk1Transaction,
            payload: payload
        )
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func fillPurchasedTransactionSK2(
        sk2Transaction: SK2Transaction,
        payload: PurchasePayload?
    ) async -> PurchasedTransaction {
        await PurchasedTransaction(
            sk1Product: try? fetchSK1Product(
                id: sk2Transaction.unfProductID,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            sk2Transaction: sk2Transaction,
            payload: payload
        )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2ProductsManager: StoreKitProductsManager {
    func fillPurchasedTransactionSK1(
        sk1Transaction: SK1TransactionWithIdentifier,
        payload: PurchasePayload?
    ) async -> PurchasedTransaction {
        await .init(
            sk2Product: try? fetchSK2Product(
                id: sk1Transaction.unfProductID,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            sk1Transaction: sk1Transaction,
            payload: payload
        )
    }

    func fillPurchasedTransactionSK2(
        sk2Transaction: SK2Transaction,
        payload: PurchasePayload?
    ) async -> PurchasedTransaction {
        await .init(
            sk2Product: try? fetchSK2Product(
                id: sk2Transaction.unfProductID,
                fetchPolicy: .returnCacheDataElseLoad
            ),
            sk2Transaction: sk2Transaction,
            payload: payload
        )
    }
}
