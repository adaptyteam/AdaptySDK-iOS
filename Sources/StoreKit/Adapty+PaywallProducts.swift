//
//  Adapty+PaywallProducts.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

extension Adapty {
    // This method is intended to be used by cross-platform SDKs, we do not expect you to use it directly.
    //    package nonisolated static func getPaywallProduct(
    //        vendorProductId: String,
    //        adaptyProductId: String,
    //        promotionalOfferId: String?,
    //        winBackOfferId: String?,
    //        variationId: String,
    //        paywallABTestName: String,
    //        paywallName: String
    //    ) async throws -> AdaptyPaywallProduct {
    //        let product = try await activatedSDK.productsManager.fetchProduct(
    //            id: vendorProductId,
    //            fetchPolicy: .returnCacheDataElseLoad
    //        )
    //
    //        return AdaptyPaywallProduct(
    //            adaptyProductId: adaptyProductId,
    //            underlying: product,
    //            promotionalOfferId: promotionalOfferId,
    //            winBackOfferId: winBackOfferId,
    //            variationId: variationId,
    //            paywallABTestName: paywallABTestName,
    //            paywallName: paywallName
    //        )
    //    }

    /// Once you have a ``AdaptyPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``AdaptyPaywall`` for which you want to get a products
    /// - Returns: A result containing the ``AdaptyPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    /// - Throws: An ``AdaptyError`` object
    public nonisolated static func getPaywallProducts(paywall: AdaptyPaywall, determineOffer: Bool = true) async throws -> [AdaptyPaywallProduct] {
        try await withActivatedSDK(
            methodName: .getPaywallProducts,
            logParams: [
                "placement_id": paywall.placementId,
                "determine_offer": determineOffer,
            ]
        ) { sdk in
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                if let manager = sdk.productsManager as? SK2ProductsManager {
                    return try await sdk.getPaywallSK2Products(
                        paywall: paywall,
                        productsManager: manager,
                        determineOffer: determineOffer
                    )
                }
            } else {
                if let manager = sdk.productsManager as? SK1ProductsManager {
                    return try await sdk.getPaywallSK1Products(
                        paywall: paywall,
                        productsManager: manager,
                        determineOffer: determineOffer
                    )
                }
            }
            return []
        }
    }

    private func getPaywallSK1Products(
        paywall: AdaptyPaywall,
        productsManager: SK1ProductsManager,
        determineOffer: Bool
    ) async throws -> [AdaptyPaywallProduct] {
        let sk1Products = try await productsManager.fetchProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )

        typealias ProductTuple = (
            product: SK1Product,
            reference: AdaptyPaywall.ProductReference,
            offer: AdaptySubscriptionOffer.Available
        )

        var products: [ProductTuple] = sk1Products.compactMap { sk1Product in
            let vendorId = sk1Product.productIdentifier
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            let offer: AdaptySubscriptionOffer.Available =
                if let promotionalOffer = sk1Product.promotionalOffer(byIdentifier: reference.promotionalOfferId) {
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
            AdaptyPaywallProduct(
                adaptyProductId: $0.reference.adaptyProductId,
                underlying: AdaptySK1Product(skProduct: $0.product),
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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    private func getPaywallSK2Products(
        paywall: AdaptyPaywall,
        productsManager: SK2ProductsManager,
        determineOffer: Bool
    ) async throws -> [AdaptyPaywallProduct] {
        let sk2Products = try await productsManager.fetchProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )

        typealias ProductTuple = (
            product: SK2Product,
            reference: AdaptyPaywall.ProductReference,
            offer: AdaptySubscriptionOffer.Available
        )

        var products: [ProductTuple] = sk2Products.compactMap { sk2Product in
            let vendorId = sk2Product.id
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            let offer: AdaptySubscriptionOffer.Available =
                if sk2Product.unfWinBackOffer(byId: reference.winBackOfferId) != nil {
                    .notDetermined
                } else if let promotionalOffer = sk2Product.promotionalOffer(byIdentifier: reference.promotionalOfferId) {
                    .available(promotionalOffer)
                } else if sk2Product.introductoryOfferNotApplicable {
                    .unavailable
                } else {
                    .notDetermined
                }

            return (product: sk2Product, reference: reference, offer: offer)
        }

        if determineOffer {
            var newProducts = [ProductTuple]()
            newProducts.reserveCapacity(products.count)

            for product in products {
                let tuple = await {
                    guard case .notDetermined = $0.offer else { return $0 }
                    guard let subscription = $0.product.subscription
                    else {
                        return (product: $0.product, reference: $0.reference, offer: .unavailable)
                    }

                    guard let introductoryOffer = $0.product.introductoryOffer
                    else {
                        return (product: $0.product, reference: $0.reference, offer: .unavailable)
                    }

                    let offer: AdaptySubscriptionOffer.Available =
                        if await subscription.isEligibleForIntroOffer {
                            .available(introductoryOffer)
                        } else {
                            .unavailable
                        }

                    return (product: $0.product, reference: $0.reference, offer: offer)
                }(product)

                newProducts.append(tuple)
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

    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifier: String) async throws -> [String] {
        let statuses = try await SK2Product.SubscriptionInfo.status(for: subscriptionGroupIdentifier)

        let status = statuses.first {
            guard case let .verified(transaction) = $0.transaction else { return false }
            guard transaction.ownershipType == .purchased else { return false }
            return true
        }

        guard case let .verified(renewalInfo) = status?.renewalInfo else { return [] }
        return renewalInfo.eligibleWinBackOfferIDs
    }
}
