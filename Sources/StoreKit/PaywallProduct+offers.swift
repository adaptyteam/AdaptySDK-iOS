//
//  PaywallProducts+offers.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation
import StoreKit

private let log = Log.productManager

extension Adapty {
    func getPaywallProductsWithoutOffers(
        paywall: AdaptyPaywall,
        productsManager: ProductsManager
    ) async throws(AdaptyError) -> [AdaptyPaywallProductWithoutDeterminingOffer] {
        try await productsManager.fetchProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )
        .compactMap { product in
            let vendorId = product.id
            guard let reference = paywall.products.first(where: { $0.productInfo.vendorId == vendorId }) else {
                return nil
            }

            return PaywallProductWithoutDeterminingOffer(
                skProduct: product,
                adaptyProductId: reference.adaptyProductId,
                productInfo: reference.productInfo,
                paywallProductIndex: reference.paywallProductIndex,
                variationId: paywall.variationId,
                paywallABTestName: paywall.placement.abTestName,
                paywallName: paywall.name,
                webPaywallBaseUrl: paywall.webPaywallBaseUrl
            )
        }
    }

    func getPaywallProduct(
        adaptyProductId: String,
        productInfo: BackendProductInfo,
        paywallProductIndex: Int,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        webPaywallBaseUrl: URL?,
        productsManager: ProductsManager
    ) async throws(AdaptyError) -> AdaptyPaywallProduct {
        let product = try await productsManager.fetchProduct(id: productInfo.vendorId, fetchPolicy: .returnCacheDataElseLoad)

        let subscriptionOffer: AdaptySubscriptionOffer? =
            if let subscriptionOfferIdentifier {
                if let offer = product.adaptySubscriptionOffer(by: subscriptionOfferIdentifier) {
                    offer
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit product don't have offer id: `\(subscriptionOfferIdentifier.offerId ?? "nil")` with type:\(subscriptionOfferIdentifier.offerType.rawValue) ").asAdaptyError
                }
            } else {
                nil
            }

        return PaywallProduct(
            skProduct: product,
            adaptyProductId: adaptyProductId,
            productInfo: productInfo,
            paywallProductIndex: paywallProductIndex,
            subscriptionOffer: subscriptionOffer,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName,
            webPaywallBaseUrl: webPaywallBaseUrl
        )
    }

    func getPaywallProducts(
        paywall: AdaptyPaywall,
        productsManager: ProductsManager
    ) async throws(AdaptyError) -> [AdaptyPaywallProduct] {
        let products: [ProductTuple] = try await productsManager.fetchProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )
        .compactMap { product in
            let vendorId = product.id
            guard let reference = paywall.products.first(where: { $0.productInfo.vendorId == vendorId }) else {
                return nil
            }

            let ((offer, determinedOffer), subscriptionGroupId): ((AdaptySubscriptionOffer?, Bool), String?) =
                if let subscriptionGroupId = product.subscription?.subscriptionGroupID,
                winBackOfferExist(with: reference.winBackOfferId, from: product) {
                    ((nil, false), subscriptionGroupId)
                } else {
                    (subscriptionOfferAvailable(reference, product), nil)
                }
            return (product, reference, offer, determinedOffer, subscriptionGroupId)
        }

        let eligibleWinBackOfferIds = try await eligibleWinBackOfferIds(for: Set(products.compactMap(\.subscriptionGroupId)))

        var newProducts = [(product: StoreKit.Product, reference: AdaptyPaywall.ProductReference, offer: AdaptySubscriptionOffer?)]()
        newProducts.reserveCapacity(products.count)
        for product in products {
            await newProducts.append(determineOfferFor(product, with: eligibleWinBackOfferIds))
        }

        return newProducts.map {
            PaywallProduct(
                skProduct: $0.product,
                adaptyProductId: $0.reference.adaptyProductId,
                productInfo: $0.reference.productInfo,
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
        product: StoreKit.Product,
        reference: AdaptyPaywall.ProductReference,
        offer: AdaptySubscriptionOffer?,
        determinedOffer: Bool,
        subscriptionGroupId: String?
    )

    private func subscriptionOfferAvailable(
        _ reference: AdaptyPaywall.ProductReference,
        _ product: StoreKit.Product
    ) -> (offer: AdaptySubscriptionOffer?, determinedOffer: Bool) {
        if let promotionalOffer = promotionalOffer(with: reference.promotionalOfferId, from: product) {
            (promotionalOffer, true)
        } else if product.introductoryOfferNotApplicable {
            (nil, true)
        } else {
            (nil, false)
        }
    }

    private func determineOfferFor(
        _ tuple: ProductTuple,
        with eligibleWinBackOfferIds: [String: [String]]
    ) async -> (product: StoreKit.Product, reference: AdaptyPaywall.ProductReference, offer: AdaptySubscriptionOffer?) {
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
              let introductoryOffer = tuple.product.adaptySubscriptionOffer(by: .introductory)
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

    private func winBackOffer(with offerId: String?, from product: StoreKit.Product) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = product.adaptySubscriptionOffer(by: .winBack(offerId)) else {
            log.warn("no win back offer found with id:\(offerId) in productId:\(product.id)")
            return nil
        }
        return offer
    }

    private func winBackOfferExist(with offerId: String?, from product: StoreKit.Product) -> Bool {
        guard let offerId else { return false }
        guard product.subscriptionOffer(by: .winBack(offerId)) != nil else {
            log.warn("no win back offer found with id:\(offerId) in productId:\(product.id)")
            return false
        }
        return true
    }

    private func promotionalOffer(with offerId: String?, from product: StoreKit.Product) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = product.adaptySubscriptionOffer(by: .promotional(offerId)) else {
            log.warn("no promotional offer found with id:\(offerId) in productId:\(product.id)")
            return nil
        }
        return offer
    }

    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifiers: Set<String>) async throws(AdaptyError) -> [String: [String]] {
        var result = [String: [String]]()
        result.reserveCapacity(subscriptionGroupIdentifiers.count)
        for subscriptionGroupIdentifier in subscriptionGroupIdentifiers {
            result[subscriptionGroupIdentifier] = try await eligibleWinBackOfferIds(for: subscriptionGroupIdentifier)
        }
        return result
    }

    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifier: String) async throws(AdaptyError) -> [String] {
        guard #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) else { return [] }
        let statuses: [StoreKit.Product.SubscriptionInfo.Status]
        let stamp = Log.stamp

        do {
            Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
                methodName: .subscriptionInfoStatus,
                stamp: stamp,
                params: [
                    "subscription_group_id": subscriptionGroupIdentifier,
                ]
            ))

            statuses = try await StoreKit.Product.SubscriptionInfo.status(for: subscriptionGroupIdentifier)

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
    }
}
