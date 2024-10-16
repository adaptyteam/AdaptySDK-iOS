//
//  Adapty+IntroductoryOfferEligibility.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

extension Adapty {
    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - products: the ``AdaptyPaywallProduct`` array, for which information will be retrieved
    ///
    ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    ///  - Throws: An ``AdaptyError`` object.
    public nonisolated static func getProductsIntroductoryOfferEligibility(products: [AdaptyPaywallProduct]) async throws -> [String: AdaptyEligibility] {
        try await getProductsIntroductoryOfferEligibility(products: products.map { $0.underlying })
    }

    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - products: the ``AdaptyProduct`` array, for which information will be retrieved
    ///
    ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    ///  - Throws: An ``AdaptyError`` object.
    public nonisolated static func getProductsIntroductoryOfferEligibility(products: [any AdaptyProduct]) async throws -> [String: AdaptyEligibility] {
        try await withActivatedSDK(
            methodName: .getProductsIntroductoryOfferEligibility,
            logParams: ["products": products.map { $0.vendorProductId }]
        ) { sdk in
            try await sdk.getProductsIntroductoryOfferEligibility(products: products)
        }
    }

    /// Once you have an ``AdaptyPaywallProduct`` array, fetch introductory offers information for this products.
    ///
    /// Read more on the [Adapty Documentation](https://docs.adapty.io/docs/displaying-products#products-fetch-policy-and-intro-offer-eligibility-not-applicable-for-android)
    ///
    /// - Parameters:
    ///   - vendorProductIds: The products ids `String` array, for which information will be retrieved
    ///  - Returns: A dictionary where Key is vendorProductId and Value is corresponding ``AdaptyEligibility``.
    ///  - Throws: An ``AdaptyError`` object.
    public nonisolated static func getProductsIntroductoryOfferEligibility(vendorProductIds: [String]) async throws -> [String: AdaptyEligibility] {
        try await withActivatedSDK(
            methodName: .getProductsIntroductoryOfferEligibilityByStrings,
            logParams: ["products": vendorProductIds]
        ) { sdk in

            try await sdk.getProductsIntroductoryOfferEligibility(
                products: sdk.productsManager.fetchProductsInSameOrder(
                    ids: vendorProductIds,
                    fetchPolicy: .returnCacheDataElseLoad
                )
            )
        }
    }

    private func getProductsIntroductoryOfferEligibility(products: [any AdaptyProduct]) async throws -> [String: AdaptyEligibility] {
        let sk1Products = [String: AdaptyEligibility?](
            products
                .compactMap { $0.sk1Product }
                .map { ($0.productIdentifier, $0.introductoryOfferEligibility) },
            uniquingKeysWith: { $1 }
        )

        var result = sk1Products.compactMapValues { $0 }

        let vendorProductIds = sk1Products.filter { $0.value == nil }.map { $0.key }
        if !vendorProductIds.isEmpty {
            for state in try await getBackendProductStates(vendorProductIds: vendorProductIds) {
                result[state.vendorId] = state.introductoryOfferEligibility
            }
        }

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            for sk2Product in products.compactMap({ $0.sk2Product }) {
                result[sk2Product.id] = await sk2Product.introductoryOfferEligibility
            }
        }

        return result
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
