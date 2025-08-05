//
//  SK1PaywallProducts.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

private let log = Log.sk1ProductManager

extension Adapty {
    func getSK1PaywallProductsWithoutOffers(
        paywall: AdaptyPaywall,
        productsManager: SK1ProductsManager
    ) async throws(AdaptyError) -> [AdaptyPaywallProductWithoutDeterminingOffer] {
        try await productsManager.fetchSK1ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )
        .compactMap { sk1Product in
            let vendorId = sk1Product.productIdentifier

            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            return AdaptySK1PaywallProductWithoutDeterminingOffer(
                skProduct: sk1Product,
                adaptyProductId: reference.adaptyProductId,
                paywallProductIndex: reference.paywallProductIndex,
                variationId: paywall.variationId,
                paywallABTestName: paywall.placement.abTestName,
                paywallName: paywall.name,
                webPaywallBaseUrl: paywall.webPaywallBaseUrl
            )
        }
    }

    func getSK1PaywallProduct(
        vendorProductId: String,
        adaptyProductId: String,
        paywallProductIndex: Int,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        productsManager: SK1ProductsManager,
        webPaywallBaseUrl: URL?
    ) async throws(AdaptyError) -> AdaptySK1PaywallProduct {
        let sk1Product = try await productsManager.fetchSK1Product(id: vendorProductId, fetchPolicy: .returnCacheDataElseLoad)

        let subscriptionOffer: AdaptySubscriptionOffer? =
            if let subscriptionOfferIdentifier {
                if let offer = sk1Product.subscriptionOffer(by: subscriptionOfferIdentifier) {
                    offer
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit1 product don't have offer id: `\(subscriptionOfferIdentifier.offerId ?? "nil")` with type:\(subscriptionOfferIdentifier.offerType.rawValue) ").asAdaptyError
                }
            } else {
                nil
            }

        return AdaptySK1PaywallProduct(
            skProduct: sk1Product,
            adaptyProductId: adaptyProductId,
            paywallProductIndex: paywallProductIndex,
            subscriptionOffer: subscriptionOffer,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName,
            webPaywallBaseUrl: webPaywallBaseUrl
        )
    }

    func getSK1PaywallProducts(
        paywall: AdaptyPaywall,
        productsManager: SK1ProductsManager
    ) async throws(AdaptyError) -> [AdaptyPaywallProduct] {
        typealias ProductTuple = (
            product: SK1Product,
            reference: AdaptyPaywall.ProductReference,
            offer: AdaptySubscriptionOffer?,
            determinedOffer: Bool
        )

        let sk1Products = try await productsManager.fetchSK1ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )

        var products: [ProductTuple] = sk1Products.compactMap { sk1Product in
            let vendorId = sk1Product.productIdentifier
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            let (offer, determinedOffer): (AdaptySubscriptionOffer?, Bool) =
                if let promotionalOffer = promotionalOffer(reference.promotionalOfferId, sk1Product) {
                    (promotionalOffer, true)
                } else if sk1Product.introductoryOfferNotApplicable {
                    (nil, true)
                } else {
                    (nil, false)
                }

            return (product: sk1Product, reference: reference, offer: offer, determinedOffer: determinedOffer)
        }

        let vendorProductIds: [String] = products.compactMap {
            guard !$0.determinedOffer else { return nil }
            return $0.product.productIdentifier
        }

        if vendorProductIds.isNotEmpty {
            let introductoryOfferEligibility = await getIntroductoryOfferEligibility(vendorProductIds: vendorProductIds)
            products = products.map {
                guard !$0.determinedOffer else { return $0 }
                return if let introductoryOffer = $0.product.subscriptionOffer(by: .introductory),
                          introductoryOfferEligibility.contains($0.product.productIdentifier)
                {
                    (product: $0.product, reference: $0.reference, offer: introductoryOffer, determinedOffer: true)
                } else {
                    (product: $0.product, reference: $0.reference, offer: nil, determinedOffer: true)
                }
            }
        }

        return products.map {
            AdaptySK1PaywallProduct(
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

    private func promotionalOffer(_ offerId: String?, _ sk1Product: SK1Product) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = sk1Product.subscriptionOffer(by: .promotional(offerId)) else {
            log.warn("no promotional offer found with id:\(offerId) in productId:\(sk1Product.productIdentifier)")
            return nil
        }
        return offer
    }

    private func getProfileState() -> (userId: AdaptyUserId, ineligibleProductIds: Set<String>)? {
        guard let manager = profileManager else { return nil }

        return (
            manager.userId,
            manager.backendIntroductoryOfferEligibilityStorage.getIneligibleProductIds()
        )
    }

    private func getIntroductoryOfferEligibility(vendorProductIds: [String]) async -> [String] {
        guard let (userId, ineligibleProductIds) = getProfileState() else { return [] }

        let vendorProductIds = vendorProductIds.filter { !ineligibleProductIds.contains($0) }
        guard vendorProductIds.isNotEmpty else { return [] }

        if !profileStorage.syncedTransactions {
            do {
                try await syncTransactions(for: userId)
            } catch {
                return []
            }
        }

        let lastResponse = try? profileManager(withProfileId: userId)?
            .backendIntroductoryOfferEligibilityStorage
            .getLastResponse()

        do {
            let response = try
                await httpSession.fetchIntroductoryOfferEligibility(
                    userId: userId,
                    responseHash: lastResponse?.hash
                ).flatValue()

            guard let response else { return lastResponse?.eligibleProductIds ?? [] }

            if let manager = try? profileManager(withProfileId: userId) {
                return manager.backendIntroductoryOfferEligibilityStorage.save(response)
            } else {
                return response.value.filter(\.value).map(\.vendorId)
            }

        } catch {
            return []
        }
    }
}
