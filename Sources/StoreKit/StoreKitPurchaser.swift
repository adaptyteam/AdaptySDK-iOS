//
//  StoreKitPurchaser.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2024
//

import StoreKit

private let log = Log.transactionManager

actor StoreKitPurchaser {
    private let transactionSynchronizer: StoreKitTransactionSynchronizer
    private let subscriptionOfferSigner: StoreKitSubscriptionOfferSigner
    private let storage: PurchasePayloadStorage
    private let productManager: ProductsManager
    private let promotedPurchaseIntentObserver: PromotedPurchaseIntentObserver

    private init(
        transactionSynchronizer: StoreKitTransactionSynchronizer,
        subscriptionOfferSigner: StoreKitSubscriptionOfferSigner,
        storage: PurchasePayloadStorage,
        productManager: ProductsManager,
        promotedPurchaseIntentObserver: PromotedPurchaseIntentObserver
    ) {
        self.transactionSynchronizer = transactionSynchronizer
        self.subscriptionOfferSigner = subscriptionOfferSigner
        self.storage = storage
        self.productManager = productManager
        self.promotedPurchaseIntentObserver = promotedPurchaseIntentObserver
    }

    @AdaptyActor
    private static var isObservingStarted = false

    @AdaptyActor
    static func startObserving(
        transactionSynchronizer: StoreKitTransactionSynchronizer,
        subscriptionOfferSigner: StoreKitSubscriptionOfferSigner,
        productsManager: ProductsManager,
        storage: PurchasePayloadStorage
    ) -> StoreKitPurchaser? {
        Task {
            for await signedTransaction in StoreKit.Transaction.updates {
                switch signedTransaction {
                case let .unverified(transaction, error):
                    log.error("Transaction \(transaction.id) (originalId: \(transaction.originalID),  productId: \(transaction.productID)) is unverified. Error: \(error.localizedDescription)")
                    await transaction.finish()
                    log.warn("Finish unverified updated transaction: \(transaction) for product: \(transaction.productID) error: \(error.localizedDescription)")

                    await storage.removePurchasePayload(forTransaction: transaction)
                    await storage.removeUnfinishedTransaction(transaction.id)
                    Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                        methodName: .finishTransaction,
                        params: transaction.logParams(other: ["unverified": error.localizedDescription])
                    ))
                case let .verified(transaction):
                    log.debug("Transaction \(transaction.id) (originalId: \(transaction.originalID),  productId: \(transaction.productID), revocationDate:\(transaction.revocationDate?.description, default: "nil"), expirationDate:\(transaction.expirationDate?.description, default: "nil") \((transaction.expirationDate.map { $0 < Date() } ?? false) ? "[expired]" : "") , isUpgraded:\(transaction.isUpgraded) ) ")

                    Task.detached {
                        if await AdaptyConfiguration.transactionFinishBehavior == .manual {
                            await storage.addUnfinishedTransaction(transaction.id)
                        }

                        await Adapty.callDelegate { $0.onUnfinishedTransaction(AdaptyUnfinishedTransaction(signedTransaction: signedTransaction)) }

                        guard !transaction.isXcodeEnvironment else {
                            log.verbose("Skip sending to backend for Xcode environment transaction \(transaction.id)")
                            _ = await transactionSynchronizer.recalculateOfflineAccessLevels()
                            await transactionSynchronizer.attemptToFinish(transaction: transaction, logSource: "updated")
                            return
                        }

                        do {
                            let product = try? await productsManager.fetchProduct(
                                id: transaction.productID,
                                fetchPolicy: .returnCacheDataElseLoad
                            )

                            try await transactionSynchronizer.report(
                                .init(product, transaction),
                                payload: storage.purchasePayload(
                                    byTransaction: transaction,
                                    orCreateFor: ProfileStorage.userId
                                ),
                                reason: .observing
                            )

                            await transactionSynchronizer.attemptToFinish(transaction: transaction, logSource: "updated")
                        } catch {
                            _ = await transactionSynchronizer.recalculateOfflineAccessLevels()
                            log.error("Failed to validate transaction: \(transaction) for product: \(transaction.productID)")
                        }
                    }
                }
            }
        }
        isObservingStarted = true
        let promotedPurchaseIntentObserver = PromotedPurchaseIntentObserver()

        return StoreKitPurchaser(
            transactionSynchronizer: transactionSynchronizer,
            subscriptionOfferSigner: subscriptionOfferSigner,
            storage: storage,
            productManager: productsManager,
            promotedPurchaseIntentObserver: promotedPurchaseIntentObserver
        )
    }

    func createOptions(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        skProduct: StoreKit.Product,
        billingPlan: AdaptySubscriptionBillingPlan?,
        offerIdentifier: AdaptySubscriptionOffer.Identifier?,
        skOffer:  Product.SubscriptionOffer? = nil
    ) async throws(AdaptyError) -> Set<Product.PurchaseOption> {
        var options = Set<Product.PurchaseOption>()

        // options.insert(.simulatesAskToBuyInSandbox(true))

        if let uuid = appAccountToken {
            options.insert(.appAccountToken(uuid))
        }

        if let billingPlan, billingPlan != .upFront {
            #if compiler(>=6.3.2)
            if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)  {
                options.insert(.billingPlanType(billingPlan.asSKBillingPlanType))
            } else {
                throw  StoreKitManagerError.billingPlanUnavailable("Invalid iOS version, can't use billingPlan:\(billingPlan.rawValue) for productId: \(skProduct.id)").asAdaptyError
            }
            #else
            throw StoreKitManagerError.billingPlanUnavailable("The StoreKit SDK does not support billingPlan:\(billingPlan.rawValue) for productId: \(skProduct.id)").asAdaptyError
            #endif
        }

        if let offerIdentifier {
            switch offerIdentifier.offerType {
            case .promotional:

                guard let offerId = offerIdentifier.offerId else {
                    throw StoreKitManagerError.invalidOffer("Promotional offer without id for productId: \(skProduct.id)").asAdaptyError
                }

                let response = try await subscriptionOfferSigner.sign(
                    offerId: offerId,
                    subscriptionVendorId: skProduct.id,
                    for: userId,
                    with: appAccountToken
                )

                options.insert(.promotionalOffer(
                        offerID: offerId,
                        keyID: response.keyIdentifier,
                        nonce: response.nonce,
                        signature: response.signature,
                        timestamp: response.timestamp
                ))
            case .winBack:

                guard let offerId = offerIdentifier.offerId else {
                    throw StoreKitManagerError.invalidOffer("WinBack offer without id for productId: \(skProduct.id)").asAdaptyError
                }

                guard #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) else {
                    throw StoreKitManagerError.invalidOffer("Winback offer unsuported on this OS version for productId: \(skProduct.id)").asAdaptyError
                }

                let billingPlan = billingPlan ?? .upFront

                let winBackOffer: Product.SubscriptionOffer

                if let skOffer, skOffer.type == .winBack {
                    winBackOffer = skOffer
                } else {
                    guard let skOffer = skProduct.subscription?.offer(by: .winBack(offerId), for: billingPlan) else {
                        throw StoreKitManagerError.invalidOffer("StoreKit not found winback offer id: \(offerId) for productId: \(skProduct.id) in billing plan: \(billingPlan)").asAdaptyError
                    }
                    winBackOffer = skOffer
                }

                options.insert(.winBackOffer(winBackOffer))
            default:
                break
            }
        }

        return options
    }

    func makePurchase(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        product: AdaptyPaywallProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        let options = try await createOptions(
            userId: userId,
            appAccountToken: appAccountToken,
            skProduct: product.skProduct,
            billingPlan: product.subscriptionPricingTerms?.billingPlan,
            offerIdentifier: product.subscriptionOffer?.offerIdentifier
        )

        await productManager.storeProductInfo(productInfo: [product.productInfo])
        await storage.setPaywallVariationId(product.variationId, productId: product.vendorProductId, userId: userId)

        let payload = await PurchasePayload(
            userId: userId,
            paywallVariationId: product.variationId,
            persistentPaywallVariationId: product.variationId,
            persistentOnboardingVariationId: storage.onboardingVariationId()
        )
        return try await makePurchase(
            product.skProduct,
            options,
            payload,
            reason: .purchasing
        )
    }

    func makePurchase(
        userId: AdaptyUserId,
        appAccountToken: UUID?,
        product: AdaptyPromotedProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {

        if let billingPlan = product.subscriptionPricingTerms?.billingPlan {
            guard billingPlan == .upFront else {
                throw StoreKitManagerError.billingPlanUnavailable("Unsupported billingPlan: \(billingPlan) for AdaptyPromotedProduct with vendorProductId:: \(product.vendorProductId)").asAdaptyError
            }
        }

        let options = try await createOptions(
            userId: userId,
            appAccountToken: appAccountToken,
            skProduct: product.skProduct,
            billingPlan: product.subscriptionPricingTerms?.billingPlan,
            offerIdentifier: product.subscriptionOffer?.offerIdentifier,
            skOffer:  product.skOffer
        )

        let payload = await PurchasePayload(
            userId: userId,
            persistentOnboardingVariationId: storage.onboardingVariationId()
        )

        return try await makePurchase(
            product.skProduct,
            options,
            payload,
            reason: .promotedPurchase
        )
    }

    private func makePurchase(
        _ product: StoreKit.Product,
        _ options: Set<Product.PurchaseOption>,
        _ payload: PurchasePayload,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        let stamp = Log.stamp

        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .productPurchase,
            stamp: stamp,
            params: [
                "product_id": product.id,
            ]
        ))

        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await product.unfPurchase(options: options)
        } catch {
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                error: error.localizedDescription
            ))
            log.error("Failed to purchase product: \(product.id) \(error.localizedDescription)")
            throw StoreKitManagerError.productPurchaseFailed(error).asAdaptyError
        }

        let signedTransaction: VerificationResult<StoreKit.Transaction>
        switch purchaseResult {
        case let .success(verificationResult):
            switch verificationResult {
            case let .verified(transaction):
                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .productPurchase,
                    stamp: stamp,
                    params: [
                        "verified": true,
                    ]
                ))
                await storage.setPurchasePayload(payload, forTransaction: transaction)
                signedTransaction = verificationResult
            case let .unverified(transaction, error):
                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .productPurchase,
                    stamp: stamp,
                    error: error.localizedDescription
                ))

                await transaction.finish()

                log.error("Finish unverified purchase transaction: \(transaction) of product: \(transaction.productID) error: \(error.localizedDescription)")
                await storage.removePurchasePayload(forTransaction: transaction)
                await storage.removeUnfinishedTransaction(transaction.id)
                Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: transaction.logParams(other: ["unverified": error.localizedDescription])
                ))
                throw StoreKitManagerError.transactionUnverified(error).asAdaptyError
            }
        case .pending:
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "pending": true,
                ]
            ))
            log.info("Pending purchase product: \(product.id)")
            return .pending
        case .userCancelled:
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "cancelled": true,
                ]
            ))
            log.info("User cancelled purchase product: \(product.id)")
            return .userCancelled
        @unknown default:
            Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "unknown": true,
                ]
            ))
            log.error("Unknown purchase result of product: \(product.id)")
            throw StoreKitManagerError.productPurchaseFailed(nil).asAdaptyError
        }

        let transaction = signedTransaction.unsafePayloadValue

        if await AdaptyConfiguration.transactionFinishBehavior == .manual {
            await storage.addUnfinishedTransaction(transaction.id)
        }

        await Adapty.callDelegate { $0.onUnfinishedTransaction(AdaptyUnfinishedTransaction(signedTransaction: signedTransaction)) }

        guard !transaction.isXcodeEnvironment else {
            log.verbose("Skip validation on backend for Xcode environment transaction \(transaction.id)")
            await transactionSynchronizer.attemptToFinish(transaction: transaction, logSource: "purchased")
            let profile = await transactionSynchronizer.recalculateOfflineAccessLevels()
            return .success(profile: profile, transaction: signedTransaction)
        }

        do {
            let profile = try await transactionSynchronizer.validate(
                .init(product, transaction),
                payload: payload,
                reason: reason
            )
            await transactionSynchronizer.attemptToFinish(transaction: transaction, logSource: "purchased")
            return .success(profile: profile, transaction: signedTransaction)
        } catch {
            log.error("Failed to validate transaction: \(transaction) for product: \(product.id)")
            let profile = await transactionSynchronizer.recalculateOfflineAccessLevels()
            return .success(profile: profile, transaction: signedTransaction)
        }
    }
}
