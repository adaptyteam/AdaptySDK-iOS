//
//  AdaptyPaywallProduct+offers.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation
import StoreKit

private let log = Log.productManager

extension Adapty {
    func getPaywallProducts(
        paywalls: [AdaptyFlowPaywall],
        productsManager: ProductsManager
    ) async throws(AdaptyError) -> [AdaptyPaywallProduct] {
        let skProducts = try await productsManager.fetchProducts(
            ids: Set(paywalls.flatMap(\.vendorProductIds)),
            fetchPolicy: .returnCacheDataElseLoad
        )

        let skProductsById = [String: StoreKit.Product](
            uniqueKeysWithValues: skProducts.map { ($0.id, $0) }
        )

        var products = [ProductTuple]()
        products.reserveCapacity(paywalls.reduce(into: 0) { $0 += $1.products.count })

        for paywall in paywalls {
            for reference in paywall.products {
                guard let skProduct = skProductsById[reference.productInfo.vendorId] else {
                    continue
                }

                guard let subscription = skProduct.subscription else {
                    products.append((skProduct, nil, paywall, reference, nil, nil, true, nil))
                    continue
                }

                let pricingTerms = reference.firstAvailablePricingTerms(isAvailable: subscription.availableBillingPlan)
              
                let billingPlan = pricingTerms.billingPlan
                let subscriptionPricingTerms = skProduct.subscriptionPricingTerms(for: billingPlan)

                let ((offer, determinedOffer), subscriptionGroupId): ((AdaptySubscriptionOffer?, Bool), String?) =
                    if winBackOfferExist(with: pricingTerms.winBackOfferId, from: skProduct, billingPlan: billingPlan) {
                        ((nil, false), subscription.subscriptionGroupID)
                    } else {
                        (subscriptionOfferAvailable(pricingTerms, skProduct), nil)
                    }
                products.append((skProduct, subscriptionPricingTerms, paywall, reference, pricingTerms, offer, determinedOffer, subscriptionGroupId))
            }
        }

        let eligibleWinBackOfferIds = try await eligibleWinBackOfferIds(for: Set(products.compactMap(\.subscriptionGroupId)))

        var newProducts = [(
            product: StoreKit.Product,
            subscriptionPricingTerms: AdaptySubscriptionPricingTerms?,
            paywall: AdaptyFlowPaywall,
            reference: AdaptyFlowPaywall.ProductReference,
            offer: AdaptySubscriptionOffer?
        )]()

        newProducts.reserveCapacity(products.count)
        for product in products {
            await newProducts.append(determineOfferFor(product, with: eligibleWinBackOfferIds))
        }

        return newProducts.map {
            AdaptyPaywallProduct(
                skProduct: $0.product,
                subscriptionPricingTerms: $0.subscriptionPricingTerms,
                flowProductId: $0.reference.flowProductId,
                adaptyProductId: $0.reference.adaptyProductId,
                productInfo: $0.reference.productInfo,
                paywallProductIndex: $0.reference.paywallProductIndex,
                subscriptionOffer: $0.offer,
                variationId: $0.paywall.variationId,
                paywallABTestName: $0.paywall.placement.abTestName,
                paywallName: $0.paywall.name,
                webPaywallBaseUrl: $0.paywall.webPaywallBaseUrl
            )
        }
    }

    func restoreProduct(
        vendorProductId: String,
        billingPlan: AdaptySubscriptionBillingPlan?,
        subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier?
    ) async throws(AdaptyError) -> (
        skProduct: StoreKit.Product,
        subscriptionPricingTerms:  AdaptySubscriptionPricingTerms?,
        subscriptionOffer: AdaptySubscriptionOffer?
    ) {
        let skProduct = try await productsManager.fetchProduct(id: vendorProductId, fetchPolicy: .returnCacheDataElseLoad)

        let subscriptionPricingTerms: AdaptySubscriptionPricingTerms?
        let subscriptionOffer: AdaptySubscriptionOffer?

        if skProduct.subscription != nil {
            let billingPlan = billingPlan ?? .upFront
            guard let pricingTerms = skProduct.subscriptionPricingTerms(for: billingPlan) else {
                throw StoreKitManagerError.billingPlanUnavailable("Cannot restore productId: \(skProduct.id) with billingPlan: \(billingPlan.rawValue)").asAdaptyError
            }
            subscriptionPricingTerms = pricingTerms

            subscriptionOffer = if let subscriptionOfferIdentifier {
                if let offer = skProduct.adaptySubscriptionOffer(by: subscriptionOfferIdentifier, billingPlan: pricingTerms.billingPlan) {
                    offer
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit product don't have offer id: `\(subscriptionOfferIdentifier.offerId, default: "nil")` with type:\(subscriptionOfferIdentifier.offerType.rawValue) ").asAdaptyError
                }
            } else {
                nil
            }
        } else {
            subscriptionPricingTerms = nil
            subscriptionOffer = nil
        }
        return (skProduct, subscriptionPricingTerms, subscriptionOffer)
    }

    private typealias ProductTuple = (
        product: StoreKit.Product,
        subscriptionPricingTerms: AdaptySubscriptionPricingTerms?,
        paywall: AdaptyFlowPaywall,
        reference: AdaptyFlowPaywall.ProductReference,
        pricingTerms: AdaptyFlowPaywall.ProducPricingTerms?,
        offer: AdaptySubscriptionOffer?,
        determinedOffer: Bool,
        subscriptionGroupId: String?
    )

    private func subscriptionOfferAvailable(
        _ pricingTerms: AdaptyFlowPaywall.ProducPricingTerms,
        _ product: StoreKit.Product
    ) -> (offer: AdaptySubscriptionOffer?, determinedOffer: Bool) {
        if let promotionalOffer = promotionalOffer(with: pricingTerms.promotionalOfferId, from: product, billingPlan: pricingTerms.billingPlan) {
            (promotionalOffer, true)
        } else if product.subscription?.offer(by: .introductory, for: pricingTerms.billingPlan) == nil {
            (nil, true)
        } else {
            (nil, false)
        }
    }

    private func determineOfferFor(
        _ tuple: ProductTuple,
        with eligibleWinBackOfferIds: [String: [String]]
    ) async -> (product: StoreKit.Product, subscriptionPricingTerms: AdaptySubscriptionPricingTerms?, paywall: AdaptyFlowPaywall, reference: AdaptyFlowPaywall.ProductReference, offer: AdaptySubscriptionOffer?) {
        guard !tuple.determinedOffer, let pricingTerms = tuple.pricingTerms else { return (tuple.product, tuple.subscriptionPricingTerms, tuple.paywall, tuple.reference, tuple.offer) }

        let billingPlan = pricingTerms.billingPlan

        if let subscriptionGroupId = tuple.subscriptionGroupId,
           let winBackOfferId = pricingTerms.winBackOfferId
        {
            if eligibleWinBackOfferIds[subscriptionGroupId]?.contains(winBackOfferId) ?? false,
               let winBackOffer = winBackOffer(with: winBackOfferId, from: tuple.product, billingPlan: billingPlan)
            {
                return (tuple.product, tuple.subscriptionPricingTerms, tuple.paywall, tuple.reference, winBackOffer)
            }

            let offerAvailable = subscriptionOfferAvailable(pricingTerms, tuple.product)

            if offerAvailable.determinedOffer {
                return (tuple.product, tuple.subscriptionPricingTerms, tuple.paywall, tuple.reference, offerAvailable.offer)
            }
        }

        guard let subscription = tuple.product.subscription,
              let introductoryOffer = tuple.product.adaptySubscriptionOffer(by: .introductory, billingPlan: billingPlan)
        else {
            return (tuple.product, tuple.subscriptionPricingTerms, tuple.paywall, tuple.reference, nil)
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

        return (tuple.product, tuple.subscriptionPricingTerms, tuple.paywall, tuple.reference, eligible ? introductoryOffer : nil)
    }

    private func winBackOffer(with offerId: String?, from product: StoreKit.Product, billingPlan: AdaptySubscriptionBillingPlan) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = product.adaptySubscriptionOffer(by: .winBack(offerId), billingPlan: billingPlan) else {
            log.warn("no win back offer found with id:\(offerId) in productId:\(product.id)")
            return nil
        }
        return offer
    }

    private func winBackOfferExist(with offerId: String?, from product: StoreKit.Product, billingPlan: AdaptySubscriptionBillingPlan) -> Bool {
        guard #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) else { return false }
        guard let offerId else { return false }
        guard product.subscription?.offer(by: .winBack(offerId), for: billingPlan) != nil else {
            log.warn("no win back offer found with id:\(offerId) in productId:\(product.id)")
            return false
        }
        return true
    }

    private func promotionalOffer(with offerId: String?, from product: StoreKit.Product, billingPlan: AdaptySubscriptionBillingPlan) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = product.adaptySubscriptionOffer(by: .promotional(offerId), billingPlan: billingPlan) else {
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

private extension AdaptyFlowPaywall.ProductReference {
    func firstAvailablePricingTerms(
        isAvailable: (AdaptySubscriptionBillingPlan) -> Bool
    ) -> AdaptyFlowPaywall.ProducPricingTerms {
        // The appended up-front plan is always available, so a match is guaranteed.
        (pricingTerms + [.default]).first {
            $0.billingPlan == .upFront || isAvailable($0.billingPlan)
        }!
    }

}
