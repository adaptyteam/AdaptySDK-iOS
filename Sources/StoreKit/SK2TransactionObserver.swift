//
//  SK2TransactionObserver.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

private let log = Log.sk2TransactionManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
enum SK2TransactionObserver {
    static func startObserving(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager) {
        Task {
            for await verificationResult in SK2Transaction.updates {
                switch verificationResult {
                case let .unverified(sk2Transaction, error):
                    log.error("Transaction \(sk2Transaction.unfIdentifier) (originalID: \(sk2Transaction.unfOriginalIdentifier),  productID: \(sk2Transaction.unfProductID)) is unverified. Error: \(error.localizedDescription)")
                    continue
                case let .verified(sk2Transaction):
                    log.debug("Transaction \(sk2Transaction.unfIdentifier) (originalID: \(sk2Transaction.unfOriginalIdentifier),  productID: \(sk2Transaction.unfProductID), revocationDate:\(sk2Transaction.revocationDate?.description ?? "nil"), expirationDate:\(sk2Transaction.expirationDate?.description ?? "nil") \((sk2Transaction.expirationDate.map { $0 < Date() } ?? false) ? "[expired]" : "") , isUpgraded:\(sk2Transaction.isUpgraded) ) ")

                    guard sk2Transaction.justPurchasedRenewed else { return }

                    Task.detached {
                        let purchasedTransaction = await productsManager.fillPurchasedTransaction(
                            variationId: nil,
                            persistentVariationId: nil,
                            sk2Transaction: sk2Transaction
                        )

                        _ = try? await purchaseValidator.validatePurchase(
                            profileId: nil,
                            transaction: purchasedTransaction,
                            reason: .observing
                        )
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
private extension SK2Transaction {
    var justPurchasedRenewed: Bool {
        if revocationDate != nil {
            return false
        } else if let expirationDate, expirationDate < Date() {
            return false
        } else if isUpgraded {
            return false
        }

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            if reason == .renewal { return false }
        }

        return true
    }
}
