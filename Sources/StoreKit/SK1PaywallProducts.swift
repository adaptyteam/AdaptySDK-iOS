//
//  SK1PaywallProducts.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

private let log = Log.sk1ProductManager

extension Adapty {
    func getSK1PaywallProducts(
        paywall: AdaptyPaywall,
        productsManager: SK1ProductsManager,
        determineOffer: Bool
    ) async throws -> [AdaptyPaywallProduct] {
        typealias ProductTuple = (
            product: SK1Product,
            reference: AdaptyPaywall.ProductReference,
            offer: AdaptySubscriptionOffer.Available
        )

        func promotionalOffer(_ promotionalOfferId: String?, _ sk1Product: SK1Product) -> AdaptySubscriptionOffer? {
            guard let promotionalOfferId else { return nil }
            guard let offer = sk1Product.promotionalOffer(byIdentifier: promotionalOfferId) else {
                log.warn("no promotional offer found with id:\(promotionalOfferId) in productId:\(sk1Product.productIdentifier)")
                return nil
            }
            return offer
        }

        let sk1Products = try await productsManager.fetchSK1ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )

        var products: [ProductTuple] = sk1Products.compactMap { sk1Product in
            let vendorId = sk1Product.productIdentifier
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            let offer: AdaptySubscriptionOffer.Available =
                if let promotionalOffer = promotionalOffer(reference.promotionalOfferId, sk1Product) {
                    .available(promotionalOffer)
                } else if sk1Product.introductoryOfferNotApplicable {
                    .unavailable
                } else {
                    .notDetermined
                }

            return (product: sk1Product, reference: reference, offer: offer)
        }

        let vendorProductIds: [String] = products.compactMap {
            guard case .notDetermined = $0.offer else { return nil }
            return $0.product.productIdentifier
        }

        if determineOffer, !vendorProductIds.isEmpty {
            let states = try await getBackendProductStates(vendorProductIds: vendorProductIds)
            products = try products.map {
                guard case .notDetermined = $0.offer else { return $0 }
                guard let introductoryOffer = $0.product.introductoryOffer else {
                    return (product: $0.product, reference: $0.reference, offer: .unavailable)
                }

                let vendorId = $0.product.productIdentifier
                guard let state = states.first(where: { $0.vendorId == vendorId }) else {
                    throw StoreKitManagerError.unknownIntroEligibility().asAdaptyError
                }

                let offer: AdaptySubscriptionOffer.Available =
                    if case .eligible = state.introductoryOfferEligibility {
                        .available(introductoryOffer)
                    } else {
                        .unavailable
                    }

                return (product: $0.product, reference: $0.reference, offer: offer)
            }
        }

        return products.map {
            AdaptySK1PaywallProduct(
                sk1Product: $0.product,
                adaptyProductId: $0.reference.adaptyProductId,
                subscriptionOffer: $0.offer,
                variationId: paywall.variationId,
                paywallABTestName: paywall.abTestName,
                paywallName: paywall.name
            )
        }
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
