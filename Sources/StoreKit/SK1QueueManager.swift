//
//  SK1QueueManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

private let log = Log.sk1QueueManager

actor SK1QueueManager: Sendable {
    private let transactionSynchronizer: StoreKitTransactionSynchronizer
    private let subscriptionOfferSigner: StoreKitSubscriptionOfferSigner
    private let productsManager: StoreKitProductsManager
    private let storage: PurchasePayloadStorage

    private var makePurchasesCompletionHandlers = [String: [AdaptyResultCompletion<AdaptyPurchaseResult>]]()
    private var makePurchasesProduct = [String: SK1Product]()

    fileprivate init(
        transactionSynchronizer: StoreKitTransactionSynchronizer,
        subscriptionOfferSigner: StoreKitSubscriptionOfferSigner,
        productsManager: StoreKitProductsManager,
        storage: PurchasePayloadStorage
    ) {
        self.transactionSynchronizer = transactionSynchronizer
        self.subscriptionOfferSigner = subscriptionOfferSigner
        self.productsManager = productsManager
        self.storage = storage
    }

    func makePurchase(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        product: AdaptyPaywallProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        guard SKPaymentQueue.canMakePayments(),
              let product = product as? AdaptySK1PaywallProduct
        else {
            throw .cantMakePayments()
        }

        let payment = SKMutablePayment(product: product.skProduct)
//        payment.simulatesAskToBuyInSandbox = true

        if let appAccountToken {
            payment.applicationUsername = appAccountToken.uuidString.lowercased()
        }

        if let offer = product.subscriptionOffer {
            switch offer.offerIdentifier {
            case .introductory:
                break
            case .winBack:
                throw StoreKitManagerError.invalidOffer("StoreKit1 Does not support winBackOffer purchase").asAdaptyError
            case let .promotional(offerId):
                let response = try await subscriptionOfferSigner.sign(
                    offerId: offerId,
                    subscriptionVendorId: product.vendorProductId,
                    for: userId
                )

                payment.paymentDiscount = SK1PaymentDiscount(
                    offerId: offerId,
                    signature: response
                )
            case .code:
                break
            }
        }

        await productsManager.storeProductInfo(productInfo: [product.productInfo])
        await storage.setPaywallVariationId(product.variationId, for: product.vendorProductId, userId: userId)
        return try await addPayment(payment, with: product.skProduct)
    }

    @inlinable
    func makePurchase(
        product: AdaptyDeferredProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        try await addPayment(product.payment, with: product.skProduct)
    }

    @inlinable
    func addPayment(
        _ payment: SKPayment,
        with sk1Product: SK1Product
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        try await withCheckedThrowingContinuation_ { continuation in
            addPayment(payment, with: sk1Product) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func addPayment(
        _ payment: SKPayment,
        with sk1Product: SK1Product,
        _ completion: @escaping AdaptyResultCompletion<AdaptyPurchaseResult>
    ) {
        let productId = payment.productIdentifier

        makePurchasesProduct[productId] = sk1Product

        if let handlers = makePurchasesCompletionHandlers[productId] {
            makePurchasesCompletionHandlers[productId] = handlers + [completion]
            return
        }

        makePurchasesCompletionHandlers[productId] = [completion]

        Task {
            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .addPayment,
                params: [
                    "product_id": productId,
                ]
            ))
        }

        SKPaymentQueue.default().add(payment)
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
                if let sk1Transaction = SK1TransactionWithIdentifier(sk1Transaction) {
                    await receivedPurchasedTransaction(sk1Transaction)
                } else {
                    await receivedFailedTransaction(sk1Transaction, error: StoreKitManagerError.unknownTransactionId().asAdaptyError)
                }

            case .failed:
                await receivedFailedTransaction(sk1Transaction, error: nil)

            case .restored:
                SKPaymentQueue.default().finishTransaction(sk1Transaction)
                await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: logParams
                ))
                log.verbose("finish restored transaction \(sk1Transaction)")

            case .deferred:
                log.error("received deferred transaction \(sk1Transaction)")

            default:
                log.warn("received unknown state (\(sk1Transaction.transactionState)) for transaction \(sk1Transaction)")
            }
        }
    }

    private func receivedPurchasedTransaction(_ sk1Transaction: SK1TransactionWithIdentifier) async {
        let productId = sk1Transaction.unfProductID
        let result: AdaptyResult<AdaptyPurchaseResult>

        var productOrNil: AdaptyProduct? = makePurchasesProduct[productId]?.asAdaptyProduct

        if productOrNil == nil {
            productOrNil = try? await productsManager.fetchProduct(
                id: sk1Transaction.unfProductID,
                fetchPolicy: .returnCacheDataElseLoad
            )
        }

        do {
            let profile = try await transactionSynchronizer.validate(
                .init(
                    product: productOrNil,
                    transaction: sk1Transaction
                ),
                payload: await storage.purchasePayload(
                    for: productId,
                    orCreateFor: ProfileStorage.userId
                )
            )

            await storage.removePurchasePayload(for: productId)
            makePurchasesProduct.removeValue(forKey: productId)
            SKPaymentQueue.default().finishTransaction(sk1Transaction.underlay)
            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .finishTransaction,
                params: sk1Transaction.logParams
            ))

            log.info("finish purchased transaction \(sk1Transaction)")

            result = .success(.success(profile: profile, transaction: sk1Transaction))
        } catch {
            result = .failure(error)
        }

        callMakePurchasesCompletionHandlers(productId, result)
    }

    private func receivedFailedTransaction(_ sk1Transaction: SK1Transaction, error: AdaptyError? = nil) async {
        let productId = sk1Transaction.unfProductID
        makePurchasesProduct.removeValue(forKey: productId)
        await storage.removePurchasePayload(for: productId)
        SKPaymentQueue.default().finishTransaction(sk1Transaction)
        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .finishTransaction,
            params: sk1Transaction.logParams
        ))

        let result: AdaptyResult<AdaptyPurchaseResult>
        if (sk1Transaction.error as? SKError)?.isPurchaseCancelled ?? false {
            log.verbose("finish canceled transaction \(sk1Transaction) ")
            result = .success(.userCancelled)
        } else {
            let error = error ?? StoreKitManagerError.productPurchaseFailed(sk1Transaction.error).asAdaptyError
            log.verbose("finish failed transaction \(sk1Transaction) error: \(error)")
            result = .failure(error)
        }
        callMakePurchasesCompletionHandlers(productId, result)
    }

    private func callMakePurchasesCompletionHandlers(
        _ productId: String,
        _ result: AdaptyResult<AdaptyPurchaseResult>
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

    fileprivate func shouldAddStorePaymentOccurred(
        product: SKProduct,
        hasDelegate: Bool,
        result: Bool
    ) async {
        log.verbose("paymentQueue shouldAddStorePayment: \(product.productIdentifier) -> \(result) (hasDelegate: \(hasDelegate))")

        let logParams: EventParameters = [
            "product_id": product.productIdentifier,
            "has_delegate": hasDelegate,
            "result": result,
        ]

        await Adapty.trackSystemEvent(
            AdaptyAppleEventQueueHandlerParameters(
                eventName: "store_payment",
                params: logParams,
                error: nil
            )
        )
    }
}

extension SK1QueueManager {
    @AdaptyActor
    private static var observer: SK1PaymentTransactionObserver?

    @AdaptyActor
    static func startObserving(
        transactionSynchronizer: StoreKitTransactionSynchronizer,
        subscriptionOfferSigner: StoreKitSubscriptionOfferSigner,
        productsManager: StoreKitProductsManager,
        storage: PurchasePayloadStorage
    ) -> SK1QueueManager? {
        guard observer == nil else { return nil }

        let manager = SK1QueueManager(
            transactionSynchronizer: transactionSynchronizer,
            subscriptionOfferSigner: subscriptionOfferSigner,
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
        func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for sk1Product: SKProduct) -> Bool {
            guard let delegate = Adapty.delegate else {
                Task {
                    await wrapped.shouldAddStorePaymentOccurred(
                        product: sk1Product,
                        hasDelegate: false,
                        result: true
                    )
                }
                return true
            }

            let deferredProduct = AdaptyDeferredProduct(sk1Product: sk1Product, payment: payment)
            let result = delegate.shouldAddStorePayment(for: deferredProduct)

            Task {
                await wrapped.shouldAddStorePaymentOccurred(
                    product: sk1Product,
                    hasDelegate: true,
                    result: result
                )
            }

            return result
        }
        #endif
    }
}
