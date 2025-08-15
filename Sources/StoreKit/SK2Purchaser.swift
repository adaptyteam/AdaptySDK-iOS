//
//  SK2Purchaser.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2024
//

import StoreKit

private let log = Log.sk2TransactionManager

actor SK2Purchaser {
    private let purchaseValidator: PurchaseValidator
    private let storage: VariationIdStorage

    private init(purchaseValidator: PurchaseValidator, storage: VariationIdStorage) {
        self.purchaseValidator = purchaseValidator
        self.storage = storage
    }

    @AdaptyActor
    private static var isObservingStarted = false

    @AdaptyActor
    static func startObserving(
        purchaseValidator: PurchaseValidator,
        productsManager: StoreKitProductsManager,
        storage: VariationIdStorage
    ) -> SK2Purchaser? {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *), !isObservingStarted else {
            return nil
        }

        Task {
            for await verificationResult in SK2Transaction.updates {
                switch verificationResult {
                case let .unverified(sk2Transaction, error):
                    log.error("Transaction \(sk2Transaction.unfIdentifier) (originalID: \(sk2Transaction.unfOriginalIdentifier),  productID: \(sk2Transaction.unfProductID)) is unverified. Error: \(error.localizedDescription)")
                    await sk2Transaction.finish()
                    continue
                case let .verified(sk2Transaction):
                    log.debug("Transaction \(sk2Transaction.unfIdentifier) (originalID: \(sk2Transaction.unfOriginalIdentifier),  productID: \(sk2Transaction.unfProductID), revocationDate:\(sk2Transaction.revocationDate?.description ?? "nil"), expirationDate:\(sk2Transaction.expirationDate?.description ?? "nil") \((sk2Transaction.expirationDate.map { $0 < Date() } ?? false) ? "[expired]" : "") , isUpgraded:\(sk2Transaction.isUpgraded) ) ")

                    Task.detached {
                        let (paywallVariationId, persistentPaywallVariationId) = await storage.getPaywallVariationIds(for: sk2Transaction.productID)

                        let purchasedTransaction = await productsManager.fillPurchasedTransaction(
                            paywallVariationId: paywallVariationId,
                            persistentPaywallVariationId: persistentPaywallVariationId,
                            persistentOnboardingVariationId: nil,
                            sk2Transaction: sk2Transaction
                        )

                        do {
                            _ = try await purchaseValidator.validatePurchase(
                                profileId: nil,
                                transaction: purchasedTransaction,
                                reason: .sk2Updates
                            )

                            await sk2Transaction.finish()

                            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                                methodName: .finishTransaction,
                                params: sk2Transaction.logParams
                            ))

                            log.info("Updated transaction: \(sk2Transaction) for product: \(sk2Transaction.productID)")
                        } catch {
                            log.error("Failed to validate transaction: \(sk2Transaction) for product: \(sk2Transaction.productID)")
                        }
                    }
                }
            }
        }

        isObservingStarted = true

        return SK2Purchaser(
            purchaseValidator: purchaseValidator,
            storage: storage
        )
    }

    func makePurchase(
        profileId: String,
        appAccountToken: UUID?,
        product: AdaptyPaywallProduct
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *),
              let sk2Product = product.sk2Product
        else {
            throw AdaptyError.cantMakePayments()
        }

        var options = Set<Product.PurchaseOption>()

        if let uuid = appAccountToken {
            options.insert(.appAccountToken(uuid))
        }
        
        switch product.subscriptionOffer {
        case .none:
            break
        case let .some(offer):
            switch offer.offerIdentifier {
            case .introductory:
                break

            case let .winBack(offerId):
                if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *),
                   let winBackOffer = sk2Product.unfWinBackOffer(byId: offerId)
                {
                    options.insert(.winBackOffer(winBackOffer))
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit2 Not found winBackOfferId:\(offerId) for productId: \(product.vendorProductId)").asAdaptyError
                }

            case let .promotional(offerId):
                let response = try await purchaseValidator.signSubscriptionOffer(
                    profileId: profileId,
                    vendorProductId: product.vendorProductId,
                    offerId: offerId
                )

                options.insert(
                    .promotionalOffer(
                        offerID: offerId,
                        keyID: response.keyIdentifier,
                        nonce: response.nonce,
                        signature: response.signature,
                        timestamp: response.timestamp
                    )
                )
            }
        }

        await storage.setPaywallVariationIds(product.variationId, for: sk2Product.id)
        let persistentOnboardingVariationId = await storage.getOnboardingVariationId()

        let result = try await makePurchase(sk2Product, options, product.variationId, persistentOnboardingVariationId)

        switch result {
        case .pending:
            break
        default:
            storage.removePaywallVariationIds(for: sk2Product.id)
        }

        return result
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private func makePurchase(
        _ sk2Product: SK2Product,
        _ options: Set<Product.PurchaseOption>,
        _ paywallVariationId: String?,
        _ persistentOnboardingVariationId: String?
    ) async throws(AdaptyError) -> AdaptyPurchaseResult {
        let stamp = Log.stamp

        await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .productPurchase,
            stamp: stamp,
            params: [
                "product_id": sk2Product.id,
            ]
        ))

        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await sk2Product.unfPurchase(options: options)
        } catch {
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                error: error.localizedDescription
            ))
            log.error("Failed to purchase product: \(sk2Product.id) \(error.localizedDescription)")
            throw StoreKitManagerError.productPurchaseFailed(error).asAdaptyError
        }

        let sk2SignedTransaction: SK2SignedTransaction
        switch purchaseResult {
        case let .success(verificationResult):
            switch verificationResult {
            case .verified:
                await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .productPurchase,
                    stamp: stamp,
                    params: [
                        "verified": true,
                    ]
                ))
                sk2SignedTransaction = verificationResult
            case let .unverified(transaction, error):
                await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .productPurchase,
                    stamp: stamp,
                    error: error.localizedDescription
                ))
                log.error("Unverified purchase transaction of product: \(sk2Product.id) \(error.localizedDescription)")
                await transaction.finish()
                throw StoreKitManagerError.transactionUnverified(error).asAdaptyError
            }
        case .pending:
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "pending": true,
                ]
            ))
            log.info("Pending purchase product: \(sk2Product.id)")
            return .pending
        case .userCancelled:
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "cancelled": true,
                ]
            ))
            log.info("User cancelled purchase product: \(sk2Product.id)")
            return .userCancelled
        @unknown default:
            await Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                methodName: .productPurchase,
                stamp: stamp,
                params: [
                    "unknown": true,
                ]
            ))
            log.error("Unknown purchase result of product: \(sk2Product.id)")
            throw StoreKitManagerError.productPurchaseFailed(nil).asAdaptyError
        }

        let sk2Transaction = sk2SignedTransaction.unsafePayloadValue

        let purchasedTransaction = PurchasedTransaction(
            sk2Product: sk2Product,
            paywallVariationId: paywallVariationId,
            persistentPaywallVariationId: paywallVariationId,
            persistentOnboardingVariationId: persistentOnboardingVariationId,
            sk2Transaction: sk2Transaction
        )

        do {
            let response = try await purchaseValidator.validatePurchase(
                profileId: nil,
                transaction: purchasedTransaction,
                reason: .purchasing
            )

            await sk2Transaction.finish()

            await Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .finishTransaction,
                params: sk2Transaction.logParams
            ))

            log.info("Successfully purchased product: \(sk2Product.id) with transaction: \(sk2Transaction)")
            return .success(profile: response.value, transaction: sk2SignedTransaction)
        } catch {
            log.error("Failed to validate transaction: \(sk2Transaction) for product: \(sk2Product.id)")
            throw StoreKitManagerError.transactionUnverified(error).asAdaptyError
        }
    }
}
