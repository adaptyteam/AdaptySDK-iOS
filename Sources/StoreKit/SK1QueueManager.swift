//
//  SK1QueueManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

private let log = Log.Category(name: "SK1QueueManager")

actor SK1QueueManager: Sendable {
    private let purchaseValidator: PurchaseValidator
    private let productsManager: StoreKitProductsManager
    private let storage: VariationIdStorage

    private var makePurchasesCompletionHandlers = [String: [AdaptyResultCompletion<AdaptyPurchasedInfo>]]()
    private var makePurchasesProduct = [String: SK1Product]()

    private var variationsIds: [String: String]
    private var persistentVariationsIds: [String: String]

    fileprivate init(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager, storage: VariationIdStorage) {
        self.purchaseValidator = purchaseValidator
        self.productsManager = productsManager
        self.storage = storage

        self.variationsIds = storage.getVariationsIds() ?? [:]

        if let persistent = storage.getPersistentVariationsIds() {
            self.persistentVariationsIds = persistent
        } else {
            self.persistentVariationsIds = variationsIds
            storage.setPersistentVariationsIds(variationsIds)
        }
    }

    func makePurchase(
        profileId: String,
        product: AdaptyPaywallProduct
    ) async throws -> AdaptyPurchasedInfo {
        guard SKPaymentQueue.canMakePayments() else {
            throw AdaptyError.cantMakePayments()
        }

        guard let sk1Product = product.sk1Product else {
            throw AdaptyError.cantMakePayments()
        }

        let variationId = product.variationId

        let payment: SKPayment

        if let offerId = product.promotionalOfferId {
            let response = try await purchaseValidator.signSubscriptionOffer(
                profileId: profileId,
                vendorProductId: product.vendorProductId,
                offerId: offerId
            )

            payment = {
                let payment = SKMutablePayment(product: sk1Product)
                payment.applicationUsername = ""

                payment.paymentDiscount = SKPaymentDiscount(
                    identifier: offerId,
                    keyIdentifier: response.keyIdentifier,
                    nonce: response.nonce,
                    signature: response.signature,
                    timestamp: response.timestamp
                )
                return payment
            }()

        } else {
            payment = SKPayment(product: sk1Product)
        }

        return try await addPayment(
            payment,
            for: sk1Product,
            with: variationId
        )
    }

    func addPayment(
        _ payment: SKPayment,
        for underlying: SK1Product,
        with variationId: String? = nil
    ) async throws -> AdaptyPurchasedInfo {
        try await withCheckedThrowingContinuation { continuation in
            addPayment(payment, for: underlying, with: variationId) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func addPayment(
        _ payment: SKPayment,
        for underlying: SK1Product,
        with variationId: String? = nil,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPurchasedInfo>
    ) {
        let productId = payment.productIdentifier

        if let variationId {
            self.setVariationId(variationId, for: productId)
        }

        makePurchasesProduct[productId] = underlying

        if let handlers = self.makePurchasesCompletionHandlers[productId] {
            self.makePurchasesCompletionHandlers[productId] = handlers + [completion]
            return
        }

        self.makePurchasesCompletionHandlers[productId] = [completion]

        SKPaymentQueue.default().add(payment)

        Task {
            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .addPayment,
                params: [
                    "product_id": productId,
                ]
            ))
        }
    }

    private func setVariationId(_ variationId: String, for productId: String) {
        if variationId != variationsIds.updateValue(variationId, forKey: productId) {
            let params: EventParameters = [
                "variation_by_product": variationsIds,
            ]
            Task {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "didset_variations_ids",
                    params: params
                ))
            }
            storage.setVariationsIds(variationsIds)
        }

        if variationId != persistentVariationsIds.updateValue(variationId, forKey: productId) {
            let params: EventParameters = [
                "variation_by_product": variationsIds,
            ]
            Task {
                await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                    eventName: "didset_variations_ids_persistent",
                    params: params
                ))
            }
            storage.setPersistentVariationsIds(variationsIds)
        }
    }

    private func removeVariationId(for productId: String) {
        guard variationsIds.removeValue(forKey: productId) != nil else { return }
        let params: EventParameters = [
            "variation_by_product": variationsIds,
        ]
        Task {
            await Adapty.trackSystemEvent(AdaptyInternalEventParameters(
                eventName: "didset_variations_ids",
                params: params
            ))
        }
        storage.setVariationsIds(variationsIds)
    }

    fileprivate func updatedTransactions(_ transactions: [SKPaymentTransaction]) async {
        for sk1Transaction in transactions {
            let logParams = sk1Transaction.logParams

            await Adapty.trackSystemEvent(AdaptyAppleEventQueueHandlerParameters(
                eventName: "updated_transaction",
                params: logParams,
                error: sk1Transaction.error.map { "\($0.localizedDescription). Detail: \($0)" }
            ))

            switch sk1Transaction.transactionState {
            case .purchased:
                guard let id = sk1Transaction.transactionIdentifier else {
                    log.error("received purchased transaction without identifier")
                    return
                }

                await receivedPurchasedTransaction(SK1TransactionWithIdentifier(sk1Transaction, id: id))
            case .failed:
                SKPaymentQueue.default().finishTransaction(sk1Transaction)
                await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: logParams
                ))
                log.verbose("finish failed transaction \(sk1Transaction)")
                receivedFailedTransaction(sk1Transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(sk1Transaction)
                await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: logParams
                ))
                log.verbose("finish restored transaction \(sk1Transaction)")
            default:
                break
            }
        }
    }

    private func receivedPurchasedTransaction(_ sk1Transaction: SK1TransactionWithIdentifier) async {
        let productId = sk1Transaction.unfProductID
        let variationId = variationsIds[productId]
        let persistentVariationId = persistentVariationsIds[productId]

        let purchasedTransaction: PurchasedTransaction =
            if let sk1Product = makePurchasesProduct[productId] {
                PurchasedTransaction(
                    sk1Product: sk1Product,
                    variationId: variationId,
                    persistentVariationId: persistentVariationId,
                    sk1Transaction: sk1Transaction
                )
            } else {
                await productsManager.fillPurchasedTransaction(
                    variationId: variationId,
                    persistentVariationId: persistentVariationId,
                    sk1Transaction: sk1Transaction
                )
            }

        let result: AdaptyResult<AdaptyPurchasedInfo>
        do {
            let response = try await purchaseValidator.validatePurchase(
                profileId: nil,
                transaction: purchasedTransaction,
                reason: .purchasing
            )

            removeVariationId(for: productId)
            makePurchasesProduct.removeValue(forKey: productId)

            SKPaymentQueue.default().finishTransaction(sk1Transaction.underlay)

            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .finishTransaction,
                params: sk1Transaction.logParams
            ))

            log.info("finish purchased transaction \(sk1Transaction.underlay)")

            result = .success(AdaptySK1PurchasedInfo(profile: response.value, sk1Transaction: sk1Transaction))

        } catch {
            result = .failure(error.asAdaptyError ?? AdaptyError.validatePurchaseFailed(unknownError: error))
        }

        callMakePurchasesCompletionHandlers(productId, result)
    }

    private func receivedFailedTransaction(_ sk1Transaction: SK1Transaction) {
        let productId = sk1Transaction.unfProductID
        removeVariationId(for: productId)
        makePurchasesProduct.removeValue(forKey: productId)
        let error = StoreKitManagerError.productPurchaseFailed(sk1Transaction.error).asAdaptyError
        callMakePurchasesCompletionHandlers(productId, .failure(error))
    }

    private func callMakePurchasesCompletionHandlers(
        _ productId: String,
        _ result: AdaptyResult<AdaptyPurchasedInfo>
    ) {
        switch result {
        case let .failure(error):
            log.error("Failed to purchase product: \(productId) \(error.localizedDescription)")
        case .success:
            log.info("Successfully purchased product: \(productId).")
        }

        guard let handlers = makePurchasesCompletionHandlers.removeValue(forKey: productId) else {
            log.error("Not found makePurchasesCompletionHandlers for \(productId)")
            return
        }

        for completion in handlers {
            completion(result)
        }
    }
}

extension SK1QueueManager {
    @AdaptyActor
    private static var observer: SK1PaymentTransactionObserver?

    @AdaptyActor
    static func startObserving(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager, storage: VariationIdStorage) -> SK1QueueManager? {
        guard observer == nil else { return nil }

        let manager = SK1QueueManager(
            purchaseValidator: purchaseValidator,
            productsManager: productsManager,
            storage: storage
        )

        let observer = SK1PaymentTransactionObserver(manager)
        self.observer = observer
        SKPaymentQueue.default().add(observer)
        return manager
    }

    private final class SK1PaymentTransactionObserver: NSObject, SKPaymentTransactionObserver, @unchecked Sendable {
        private let wrapped: SK1QueueManager

        init(_ wrapped: SK1QueueManager) {
            self.wrapped = wrapped
            super.init()
        }

        func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            Task {
                await wrapped.updatedTransactions(transactions)
            }
        }

        #if !os(watchOS)
//            func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for underlying: SKProduct) -> Bool {
//                guard let delegate = Adapty.delegate else { return true }
//
//                let deferredProduct = AdaptySK1Product(sk1Product: underlying, payment: payment)
//                return delegate.shouldAddStorePayment(for: deferredProduct, defermentCompletion: { [weak self] completion in
//                    self?.makePurchase(payment: payment, underlying: deferredProduct) { result in
//                        completion?(result)
//                    }
//                })
//            }
        #endif
    }
}
