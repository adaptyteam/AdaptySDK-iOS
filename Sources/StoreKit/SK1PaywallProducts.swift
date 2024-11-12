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
    ) async throws -> [AdaptyPaywallProductWithoutDeterminingOffer] {
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
                variationId: paywall.variationId,
                paywallABTestName: paywall.abTestName,
                paywallName: paywall.name
            )
        }
    }

    func getSK1PaywallProduct(
        vendorProductId: String,
        adaptyProductId: String,
        offerTypeWithIdentifier: AdaptySubscriptionOffer.OfferTypeWithIdentifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        productsManager: SK1ProductsManager
    ) async throws -> AdaptySK1PaywallProduct {
        let sk1Product = try await productsManager.fetchSK1Product(id: vendorProductId, fetchPolicy: .returnCacheDataElseLoad)

        let subscriptionOffer: AdaptySubscriptionOffer? =
            if let offerTypeWithIdentifier {
                if let offer = sk1Product.subscriptionOffer(by: offerTypeWithIdentifier) {
                    offer
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit1 product dont have offer id: `\(offerTypeWithIdentifier.identifier ?? "nil")` with type:\(offerTypeWithIdentifier.asOfferType.rawValue) ").asAdaptyError
                }
            } else {
                nil
            }

        return AdaptySK1PaywallProduct(
            skProduct: sk1Product,
            adaptyProductId: adaptyProductId,
            subscriptionOffer: subscriptionOffer,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName
        )
    }

    func getSK1PaywallProducts(
        paywall: AdaptyPaywall,
        productsManager: SK1ProductsManager
    ) async throws -> [AdaptyPaywallProduct] {
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

        if !vendorProductIds.isEmpty {
            let states = try await getBackendProductStates(vendorProductIds: vendorProductIds)
            products = try products.map {
                guard !$0.determinedOffer else { return $0 }
                guard let introductoryOffer = $0.product.subscriptionOffer(by: .introductory) else {
                    return (product: $0.product, reference: $0.reference, offer: nil, determinedOffer: true)
                }

                let vendorId = $0.product.productIdentifier
                guard let state = states.first(where: { $0.vendorId == vendorId }) else {
                    throw StoreKitManagerError.unknownIntroEligibility().asAdaptyError
                }

                let offer: AdaptySubscriptionOffer? =
                    if case .eligible = state.introductoryOfferEligibility {
                        introductoryOffer
                    } else {
                        nil
                    }

                return (product: $0.product, reference: $0.reference, offer: offer, determinedOffer: true)
            }
        }

        return products.map {
            AdaptySK1PaywallProduct(
                skProduct: $0.product,
                adaptyProductId: $0.reference.adaptyProductId,
                subscriptionOffer: $0.offer,
                variationId: paywall.variationId,
                paywallABTestName: paywall.abTestName,
                paywallName: paywall.name
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

    private func getBackendProductStates(vendorProductIds: [String]) async throws -> [BackendProductState] {
        let profileId = try await createdProfileManager.profileId

        if !profileStorage.syncedTransactions {
            try await syncTransactions(for: profileId)
        }

        let response: VH<[BackendProductState]>?
        let responseError: Error?
        let responseHash = try profileManager(with: profileId)?.backendProductStatesStorage.productsHash
        do {
            response = try await httpSession.fetchProductStates(
                profileId: profileId,
                responseHash: responseHash
            ).flatValue()
            responseError = nil
        } catch {
            response = nil
            responseError = error
        }

        guard let manager = try profileManager(with: profileId) else {
            throw AdaptyError.profileWasChanged()
        }

        manager.backendProductStatesStorage.setBackendProductStates(response)

        let value = manager.backendProductStatesStorage.getBackendProductStates(byIds: vendorProductIds)

        if value.isEmpty, let error = responseError {
            throw error.asAdaptyError ?? AdaptyError.fetchProductStatesFailed(unknownError: error)
        } else {
            return value
        }
    }
}
