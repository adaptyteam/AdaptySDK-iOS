//
//  SK1TransactionObserver.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.10.2024
//

import StoreKit

private let log = Log.sk1QueueManager

actor SK1TransactionObserver: Sendable {
    private let purchaseValidator: PurchaseValidator
    private let productsManager: StoreKitProductsManager

    fileprivate init(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager) {
        self.purchaseValidator = purchaseValidator
        self.productsManager = productsManager
    }

    fileprivate func updatedTransactions(_ transactions: [SKPaymentTransaction]) async {
        for sk1Transaction in transactions {
            let logParams = sk1Transaction.logParams

            await Adapty.trackSystemEvent(AdaptyAppleEventQueueHandlerParameters(
                eventName: "updated_transaction",
                params: logParams,
                error: sk1Transaction.error.map { "\($0.localizedDescription). Detail: \($0)" }
            ))

            guard sk1Transaction.transactionState == .purchased else { continue }
            guard let id = sk1Transaction.transactionIdentifier else {
                log.error("received purchased transaction without identifier")
                continue
            }

            let sk1Transaction = SK1TransactionWithIdentifier(sk1Transaction, id: id)

            Task.detached {
                let transaction = await self.productsManager.fillPurchasedTransaction(
                    paywallVariationId: nil,
                    persistentPaywallVariationId: nil,
                    persistentOnboardingVariationId: nil,
                    sk1Transaction: sk1Transaction
                )

                _ = try await self.purchaseValidator.validatePurchase(
                    profileId: nil,
                    transaction: transaction,
                    reason: .observing
                )
            }
        }
    }
}

extension SK1TransactionObserver {
    @AdaptyActor
    private static var observer: ObserverWrapper?

    @AdaptyActor
    static func startObserving(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager) {
        guard observer == nil else { return }

        let observer = ObserverWrapper(SK1TransactionObserver(
            purchaseValidator: purchaseValidator,
            productsManager: productsManager
        ))

        self.observer = observer

        SKPaymentQueue.default().add(observer)
    }

    private final class ObserverWrapper: NSObject, SKPaymentTransactionObserver, @unchecked Sendable {
        private let wrapped: SK1TransactionObserver

        init(_ wrapped: SK1TransactionObserver) {
            self.wrapped = wrapped
            super.init()
        }

        func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            Task {
                await wrapped.updatedTransactions(transactions)
            }
        }
    }
}
