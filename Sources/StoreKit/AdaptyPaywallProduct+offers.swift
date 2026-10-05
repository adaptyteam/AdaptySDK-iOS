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

        var eligibleIntroductory = [String: Bool]()
        var eligibleWinBackIds = [String: [String]]()

        var newProducts = [(
            product: StoreKit.Product,
            subscriptionPricingTerms: AdaptySubscriptionPricingTerms?,
            paywall: AdaptyFlowPaywall,
            reference: AdaptyFlowPaywall.ProductReference,
            offer: AdaptySubscriptionOffer?
        )]()
        newProducts.reserveCapacity(paywalls.reduce(into: 0) { $0 += $1.products.count })

        for paywall in paywalls {
            for reference in paywall.products {
                guard let skProduct = skProductsById[reference.productInfo.vendorId] else {
                    continue
                }
                guard let subscription = skProduct.subscription else {
                    newProducts.append((skProduct, nil, paywall, reference, nil))
                    continue
                }

                let selectedPricingTerm = reference.pricingTerms.first { subscription.availableBillingPlan(for: $0.billingPlan) } ?? .default
                var selectedOffer: AdaptySubscriptionOffer? = nil

                // 1. try select winBack offer
                if selectedOffer == nil, let offerId = selectedPricingTerm.winBackOfferId {
                    if let winBackOffer = skProduct.adaptySubscriptionOffer(by: .winBack(offerId), for: selectedPricingTerm.billingPlan) {
                        let groupId = subscription.subscriptionGroupID
                        if eligibleWinBackIds[groupId] == nil {
                            eligibleWinBackIds[groupId] = try await eligibleWinBackOfferIds(for: groupId)
                        }
                        if eligibleWinBackIds[groupId]?.contains(offerId) == true {
                            selectedOffer = winBackOffer
                        }

                    } else {
                        log.warn("no win back offer found with id:\(offerId) in productId:\(skProduct.id)")
                    }
                }

                // 2. try select promotional offer
                if selectedOffer == nil, let offerId = selectedPricingTerm.promotionalOfferId {
                    selectedOffer = skProduct.adaptySubscriptionOffer(by: .promotional(offerId), for: selectedPricingTerm.billingPlan)
                    if selectedOffer == nil { log.warn("no promotional offer found with id:\(offerId) in productId:\(skProduct.id)") }
                }

                // 3. try select introductory offer
                if selectedOffer == nil {
                    if let introductoryOffer = skProduct.adaptySubscriptionOffer(by: .introductory, for: selectedPricingTerm.billingPlan) {
                        let groupId = subscription.subscriptionGroupID
                        switch eligibleIntroductory[groupId] {
                        case .none:
                            if await eligibleIntroductoryOffer(for: groupId) {
                                selectedOffer = introductoryOffer
                                eligibleIntroductory[groupId] = true
                            } else {
                                eligibleIntroductory[groupId] = false
                            }
                        case .some(true):
                            selectedOffer = introductoryOffer
                        case .some(false):
                            break
                        }
                    }
                }

                newProducts.append((
                    skProduct,
                    skProduct.subscriptionPricingTerms(for: selectedPricingTerm.billingPlan),
                    paywall,
                    reference,
                    selectedOffer
                ))
            }
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
                if let offer = skProduct.adaptySubscriptionOffer(by: subscriptionOfferIdentifier, for: pricingTerms.billingPlan) {
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

    private func eligibleIntroductoryOffer(for subscriptionGroupIdentifier: String) async -> Bool {

        let stamp = Log.stamp
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .isEligibleForIntroOffer,
            stamp: stamp,
            params: [
                "subscription_group_id": subscriptionGroupIdentifier
            ]
        ))

        let eligible = await Product.SubscriptionInfo.isEligibleForIntroOffer(for: subscriptionGroupIdentifier)

        Adapty.trackSystemEvent(AdaptyAppleResponseParameters(
            methodName: .isEligibleForIntroOffer,
            stamp: stamp,
            params: [
                "is_eligible": eligible,
            ]
        ))

        return eligible
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
