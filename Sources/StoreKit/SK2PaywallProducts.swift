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
    func getSK2PaywallProducts(
        paywall: AdaptyPaywall,
        productsManager: SK2ProductsManager,
        determineOffer: Bool
    ) async throws -> [AdaptyPaywallProduct] {
        let sk2Products = try await productsManager.fetchProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )

        var products: [ProductTuple] = sk2Products.compactMap { productTuple(from: paywall, sk2Product: $0) }

        if determineOffer {
            let eligibleWinBackOfferIds = try await eligibleWinBackOfferIds(for: Set(products.compactMap { $0.subscriptionGroupId }))

            var newProducts = [ProductTuple]()
            newProducts.reserveCapacity(products.count)
            for product in products {
                await newProducts.append(determineOfferFor(product, with: eligibleWinBackOfferIds))
            }
            products = newProducts
        }

        return products.map {
            AdaptyPaywallProduct(
                adaptyProductId: $0.reference.adaptyProductId,
                underlying: AdaptySK2Product(skProduct: $0.product),
                subscriptionOffer: $0.offer,
                variationId: paywall.variationId,
                paywallABTestName: paywall.abTestName,
                paywallName: paywall.name
            )
        }
    }

    private typealias ProductTuple = (
        product: SK2Product,
        reference: AdaptyPaywall.ProductReference,
        offer: AdaptySubscriptionOffer.Available,
        subscriptionGroupId: String?
    )

    private func productTuple(from paywall: AdaptyPaywall, sk2Product: SK2Product) -> ProductTuple? {
        let vendorId = sk2Product.id
        guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
            return nil
        }

        let (offer, subscriptionGroupId): (AdaptySubscriptionOffer.Available, String?) =
            if let subscriptionGroupId = sk2Product.subscription?.subscriptionGroupID,
            winBackOfferExist(with: reference.winBackOfferId, from: sk2Product) {
                (.notDetermined, subscriptionGroupId)
            } else {
                (subscriptionOfferAvailable(reference, sk2Product), nil)
            }

        return (product: sk2Product, reference: reference, offer: offer, subscriptionGroupId: subscriptionGroupId)
    }

    private func determineOfferFor(_ tuple: ProductTuple, with eligibleWinBackOfferIds: [String: [String]]) async -> ProductTuple {
        var offer = tuple.offer
        guard case .notDetermined = offer else { return tuple }

        if let subscriptionGroupId = tuple.subscriptionGroupId,
           let winBackOfferId = tuple.reference.winBackOfferId {
            if eligibleWinBackOfferIds[subscriptionGroupId]?.contains(winBackOfferId) ?? false,
               let winBackOffer = winBackOffer(with: winBackOfferId, from: tuple.product) {
                return (product: tuple.product, reference: tuple.reference, offer: .available(winBackOffer), nil)
            }
            offer = subscriptionOfferAvailable(tuple.reference, tuple.product)

            guard case .notDetermined = offer else {
                return (product: tuple.product, reference: tuple.reference, offer: offer, nil)
            }
        }

        guard let subscription = tuple.product.subscription,
              let introductoryOffer = tuple.product.introductoryOffer
        else {
            return (product: tuple.product, reference: tuple.reference, offer: .unavailable, nil)
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

        offer =
            if eligible {
                .available(introductoryOffer)
            } else {
                .unavailable
            }

        return (product: tuple.product, reference: tuple.reference, offer: offer, nil)
    }

    private func winBackOffer(with offerId: String?, from sk2Product: SK2Product) -> AdaptySubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = sk2Product.winBackOffer(byIdentifier: offerId) else {
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
        guard let offer = sk2Product.promotionalOffer(byIdentifier: offerId) else {
            log.warn("no promotional offer found with id:\(offerId) in productId:\(sk2Product.id)")
            return nil
        }
        return offer
    }

    private func subscriptionOfferAvailable(_ reference: AdaptyPaywall.ProductReference, _ sk2Product: SK2Product) -> AdaptySubscriptionOffer.Available {
        if let promotionalOffer = promotionalOffer(with: reference.promotionalOfferId, from: sk2Product) {
            .available(promotionalOffer)
        } else if sk2Product.introductoryOfferNotApplicable {
            .unavailable
        } else {
            .notDetermined
        }
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
