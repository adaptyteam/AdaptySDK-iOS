//
//  SK@PaywallProducts.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

private let log = Log.sk2ProductManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension Adapty {
    func getSK2PaywallProductsWithoutOffers(
        paywall: AdaptyPaywall,
        productsManager: SK2ProductsManager
    ) async throws -> [AdaptyPaywallProductWithoutDeterminingOffer] {
        try await productsManager.fetchSK2ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )
        .compactMap { sk2Product in
            let vendorId = sk2Product.id
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            return AdaptySK2PaywallProductWithoutDeterminingOffer(
                skProduct: sk2Product,
                adaptyProductId: reference.adaptyProductId,
                paywallProductIndex: reference.paywallProductIndex,
                variationId: paywall.variationId,
                paywallABTestName: paywall.placement.abTestName,
                paywallName: paywall.name,
                webPaywallBaseUrl: paywall.webPaywallBaseUrl
            )
        }
    }

    func getSK2PaywallProduct(
        vendorProductId: String,
        adaptyProductId: String,
        paywallProductIndex: Int,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        webPaywallBaseUrl: URL?,
        productsManager: SK2ProductsManager
    ) async throws -> AdaptySK2PaywallProduct {
        let sk2Product = try await productsManager.fetchSK2Product(id: vendorProductId, fetchPolicy: .returnCacheDataElseLoad)

        let subscriptionOffer: AdaptySubscriptionOffer? =
            if let subscriptionOfferIdentifier {
                if let offer = sk2Product.subscriptionOffer(by: subscriptionOfferIdentifier) {
                    offer
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit2 product don't have offer id: `\(subscriptionOfferIdentifier.identifier ?? "nil")` with type:\(subscriptionOfferIdentifier.asOfferType.rawValue) ").asAdaptyError
                }
            } else {
                nil
            }

        return AdaptySK2PaywallProduct(
            skProduct: sk2Product,
            adaptyProductId: adaptyProductId,
            paywallProductIndex: paywallProductIndex,
            subscriptionOffer: subscriptionOffer,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName,
            webPaywallBaseUrl: webPaywallBaseUrl
        )
    }

    func getSK2PaywallProducts(
        paywall: AdaptyPaywall,
        productsManager: SK2ProductsManager
    ) async throws -> [AdaptyPaywallProduct] {
        let products: [ProductTuple] = try await productsManager.fetchSK2ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )
        .compactMap { sk2Product in
            let vendorId = sk2Product.id
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            let ((offer, determinedOffer), subscriptionGroupId): ((AdaptySubscriptionOffer?, Bool), String?) =
                if let subscriptionGroupId = sk2Product.subscription?.subscriptionGroupID,
                winBackOfferExist(with: reference.winBackOfferId, from: sk2Product) {
                    ((nil, false), subscriptionGroupId)
                } else {
                    (subscriptionOfferAvailable(reference, sk2Product), nil)
                }
            return (sk2Product, reference, offer, determinedOffer, subscriptionGroupId)
        }

        let eligibleWinBackOfferIds = try await eligibleWinBackOfferIds(for: Set(products.compactMap { $0.subscriptionGroupId }))

        var newProducts = [(product: SK2Product, reference: AdaptyPaywall.ProductReference, offer: AdaptySubscriptionOffer?)]()
        newProducts.reserveCapacity(products.count)
        for product in products {
            await newProducts.append(determineOfferFor(product, with: eligibleWinBackOfferIds))
        }

        return newProducts.map {
            AdaptySK2PaywallProduct(
                skProduct: $0.product,
                adaptyProductId: $0.reference.adaptyProductId,
                paywallProductIndex: $0.reference.paywallProductIndex,
                subscriptionOffer: $0.offer,
                variationId: paywall.variationId,
                paywallABTestName: paywall.placement.abTestName,
                paywallName: paywall.name,
                webPaywallBaseUrl: paywall.webPaywallBaseUrl
            )
        }
    }

    private typealias ProductTuple = (
        product: SK2Product,
        reference: AdaptyPaywall.ProductReference,
        offer: AdaptySubscriptionOffer?,
        determinedOffer: Bool,
        subscriptionGroupId: String?
    )

    private func subscriptionOfferAvailable(
        _ reference: AdaptyPaywall.ProductReference,
        _ sk2Product: SK2Product
    ) -> (offer: AdaptySubscriptionOffer?, determinedOffer: Bool) {
        if let promotionalOffer = promotionalOffer(with: reference.promotionalOfferId, from: sk2Product) {
            (promotionalOffer, true)
        } else if sk2Product.introductoryOfferNotApplicable {
            (nil, true)
        } else {
            (nil, false)
        }
    }

    private func determineOfferFor(
        _ tuple: ProductTuple,
        with eligibleWinBackOfferIds: [String: [String]]
    ) async -> (product: SK2Product, reference: AdaptyPaywall.ProductReference, offer: AdaptySubscriptionOffer?) {
        guard !tuple.determinedOffer else { return (tuple.product, tuple.reference, tuple.offer) }

        if let subscriptionGroupId = tuple.subscriptionGroupId,
           let winBackOfferId = tuple.reference.winBackOfferId
        {
            if eligibleWinBackOfferIds[subscriptionGroupId]?.contains(winBackOfferId) ?? false,
               let winBackOffer = winBackOffer(with: winBackOfferId, from: tuple.product)
            {
                return (tuple.product, tuple.reference, winBackOffer)
            }

            let offerAvailable = subscriptionOfferAvailable(tuple.reference, tuple.product)

            if offerAvailable.determinedOffer {
                return (tuple.product, tuple.reference, offerAvailable.offer)
            }
        }

        guard let subscription = tuple.product.subscription,
              let introductoryOffer = tuple.product.subscriptionOffer(by: .introductory)
        else {
            return (tuple.product, tuple.reference, nil)
        }

        let stamp = Log.stamp
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .isEligibleForIntroOffer,
            stamp: stamp,
            params: [
                "product_id": tuple.product.id,
            ]
        ))

        let eligible = await subscription.isEligibleForIntroOffer

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
            methodName: .isEligibleForIntroOffer,
            stamp: stamp,
            params: [
                "is_eligible": eligible,
            ]
        ))

        return (tuple.product, tuple.reference, eligible ? introductoryOffer : nil)
    }

    private func winBackOffer(with offerId: String?, from sk2Product: SK2Product) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = sk2Product.subscriptionOffer(by: .winBack(offerId)) else {
            log.warn("no win back offer found with id:\(offerId) in productId:\(sk2Product.id)")
            return nil
        }
        return offer
    }

    private func winBackOfferExist(with offerId: String?, from sk2Product: SK2Product) -> Bool {
        guard let offerId else { return false }
        guard sk2Product.unfWinBackOffer(byId: offerId) != nil else {
            log.warn("no win back offer found with id:\(offerId) in productId:\(sk2Product.id)")
            return false
        }
        return true
    }

    private func promotionalOffer(with offerId: String?, from sk2Product: SK2Product) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = sk2Product.subscriptionOffer(by: .promotional(offerId)) else {
            log.warn("no promotional offer found with id:\(offerId) in productId:\(sk2Product.id)")
            return nil
        }
        return offer
    }

    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifiers: Set<String>) async throws -> [String: [String]] {
        var result = [String: [String]]()
        result.reserveCapacity(subscriptionGroupIdentifiers.count)
        for subscriptionGroupIdentifier in subscriptionGroupIdentifiers {
            result[subscriptionGroupIdentifier] = try await eligibleWinBackOfferIds(for: subscriptionGroupIdentifier)
        }
        return result
    }

    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifier: String) async throws -> [String] {
        #if compiler(<6.0)
            return []
        #else
            guard #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) else { return [] }
            let statuses: [SK2Product.SubscriptionInfo.Status]
            let stamp = Log.stamp

            do {
                Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                    methodName: .subscriptionInfoStatus,
                    stamp: stamp,
                    params: [
                        "subscription_group_id": subscriptionGroupIdentifier,
                    ]
                ))

                statuses = try await SK2Product.SubscriptionInfo.status(for: subscriptionGroupIdentifier)

                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .subscriptionInfoStatus,
                    stamp: stamp
                ))

            } catch {
                log.error(" Error on get SubscriptionInfo.status: \(error.localizedDescription)")
                Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
                    methodName: .subscriptionInfoStatus,
                    stamp: stamp,
                    error: error.localizedDescription
                ))

                throw StoreKitManagerError.getSubscriptionInfoStatusFailed(error).asAdaptyError
            }

            let status = statuses.first {
                guard case let .verified(transaction) = $0.transaction else { return false }
                guard transaction.ownershipType == .purchased else { return false }
                return true
            }

            guard case let .verified(renewalInfo) = status?.renewalInfo else { return [] }
            return renewalInfo.eligibleWinBackOfferIDs
        #endif
    }
}
