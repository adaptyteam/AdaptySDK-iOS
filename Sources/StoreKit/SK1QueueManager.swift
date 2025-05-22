//
//  SK1QueueManager.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

private let log = Log.sk1QueueManager

actor SK1QueueManager: Sendable {
    private let purchaseValidator: PurchaseValidator
    private let productsManager: StoreKitProductsManager
    private let storage: VariationIdStorage

    private var makePurchasesCompletionHandlers = [String: [AdaptyResultCompletion<AdaptyPurchaseResult>]]()
    private var makePurchasesProduct = [String: SK1Product]()

    fileprivate init(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager, storage: VariationIdStorage) {
        self.purchaseValidator = purchaseValidator
        self.productsManager = productsManager
        self.storage = storage
    }

    func makePurchase(
        profileId: String,
        product: AdaptyPaywallProduct
    ) async throws -> AdaptyPurchaseResult {
        guard SKPaymentQueue.canMakePayments() else {
            throw AdaptyError.cantMakePayments()
        }

        guard let sk1Product = product.sk1Product else {
            throw AdaptyError.cantMakePayments()
        }

        let variationId = product.variationId

        let payment: SKPayment

        switch product.subscriptionOffer {
        case .none:
            payment = SKPayment(product: sk1Product)
        case let .some(offer):
            switch offer.offerIdentifier {
            case .introductory:
                payment = SKPayment(product: sk1Product)
            case .winBack:
                throw StoreKitManagerError.invalidOffer("StoreKit1 Does not support winBackOffer purchase").asAdaptyError
            case let .promotional(offerId):

                let response = try await purchaseValidator.signSubscriptionOffer(
                    profileId: profileId,
                    vendorProductId: product.vendorProductId,
                    offerId: offerId
                )

                payment = {
                    let payment = SKMutablePayment(product: sk1Product)
                    payment.applicationUsername = ""
                    payment.paymentDiscount = SK1PaymentDiscount(
                        offerId: offerId,
                        signature: response
                    )

                    return payment
                }()
            }
        }

        return try await addPayment(
            payment,
            for: sk1Product,
            with: variationId
        )
    }

    func makePurchase(
        product: AdaptyDeferredProduct
    ) async throws -> AdaptyPurchaseResult {
        try await addPayment(product.payment, for: product.skProduct)
    }

    @inlinable
    func addPayment(
        _ payment: SKPayment,
        for underlying: SK1Product,
        with variationId: String? = nil
    ) async throws -> AdaptyPurchaseResult {
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
        _ completion: @escaping AdaptyResultCompletion<AdaptyPurchaseResult>
    ) {
        let productId = payment.productIdentifier

        makePurchasesProduct[productId] = underlying

        if let handlers = makePurchasesCompletionHandlers[productId] {
            makePurchasesCompletionHandlers[productId] = handlers + [completion]
            return
        }

        makePurchasesCompletionHandlers[productId] = [completion]

        Task {
            await storage.setPaywallVariationIds(variationId, for: productId)

            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .addPayment,
                params: [
                    "product_id": productId,
                ]
            ))

            SKPaymentQueue.default().add(payment)
        }
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

        let (paywallVariationId, persistentPaywallVariationId, persistentOnboardingVariationId) = await storage.getVariationIds(for: productId)

        let purchasedTransaction: PurchasedTransaction =
            if let sk1Product = makePurchasesProduct[productId] {
                PurchasedTransaction(
                    sk1Product: sk1Product,
                    paywallVariationId: paywallVariationId,
                    persistentPaywallVariationId: persistentPaywallVariationId,
                    persistentOnboardingVariationId: persistentOnboardingVariationId,
                    sk1Transaction: sk1Transaction
                )
            } else {
                await productsManager.fillPurchasedTransaction(
                    paywallVariationId: paywallVariationId,
                    persistentPaywallVariationId: persistentPaywallVariationId,
                    persistentOnboardingVariationId: persistentOnboardingVariationId,
                    sk1Transaction: sk1Transaction
                )
            }

        let result: AdaptyResult<AdaptyPurchaseResult>
        do {
            let response = try await purchaseValidator.validatePurchase(
                profileId: nil,
                transaction: purchasedTransaction,
                reason: .purchasing
            )

            storage.removePaywallVariationIds(for: productId)
            makePurchasesProduct.removeValue(forKey: productId)

            SKPaymentQueue.default().finishTransaction(sk1Transaction.underlay)

            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .finishTransaction,
                params: sk1Transaction.logParams
            ))

            log.info("finish purchased transaction \(sk1Transaction.underlay)")

            result = .success(.success(profile: response.value, transaction: sk1Transaction))

        } catch {
            result = .failure(error.asAdaptyError ?? AdaptyError.validatePurchaseFailed(unknownError: error))
        }

        callMakePurchasesCompletionHandlers(productId, result)
    }

    private func receivedFailedTransaction(_ sk1Transaction: SK1Transaction) {
        let productId = sk1Transaction.unfProductID
        storage.removePaywallVariationIds(for: productId)
        makePurchasesProduct.removeValue(forKey: productId)

        let result: AdaptyResult<AdaptyPurchaseResult>
        if (sk1Transaction.error as? SKError)?.isPurchaseCancelled ?? false {
            result = .success(.userCancelled)
        } else {
            let error = StoreKitManagerError.productPurchaseFailed(sk1Transaction.error).asAdaptyError
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
