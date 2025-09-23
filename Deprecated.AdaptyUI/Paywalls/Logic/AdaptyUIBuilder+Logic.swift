//
//  AdaptyUIBuilder+Logic.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/22/25.
//

import Adapty
import AdaptyUIBuider
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUILogic: AdaptyUIBuilderLogic {
    let logId: String
    let events: AdaptyEventsHandler

    package init(
        logId: String,
        events: AdaptyEventsHandler
    ) {
        self.logId = logId
        self.events = events
    }

    func reportViewDidAppear() {
        events.event_viewDidAppear()
    }

    func reportViewDidDisappear() {
        events.event_viewDidDisappear()
    }

    func reportDidPerformAction(_ action: AdaptyUIBuilder.Action) {
        events.event_didPerformAction(action.adaptyUIAction)
    }

    func reportDidSelectProduct(_ product: AdaptyProductModel) {
        guard let adaptyProduct = product as? AdaptyPaywallProductWithoutDeterminingOffer else {
            Log.ui.verbose("#\(logId)# makePurchase error: product is not AdaptyPaywallProductWithoutDeterminingOffer")
            return
        }

        events.event_didSelectProduct(adaptyProduct)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool {
        events.event_didFailLoadingProducts(with: error.asAdaptyError)
    }

    func getPaywall(
        placementId: String,
        locale: String?
    ) async throws -> AdaptyPaywallModel {
        try await Adapty.getPaywall(placementId: placementId, locale: locale)
    }

    package func logShowPaywall(
        paywall: AdaptyPaywallModel,
        viewConfiguration: AdaptyUIConfiguration
    ) async throws {
        guard let paywall = paywall as? AdaptyPaywall else {
            throw AdaptyUIError.injectionConfiguration
        }
        await Adapty.logShowPaywall(paywall, viewConfiguration: viewConfiguration)
    }

    package func getProducts(
        paywall: AdaptyPaywallModel,
        determineOffers: Bool
    ) async throws -> [AdaptyProductModel] {
        guard let paywall = paywall as? AdaptyPaywall else {
            throw AdaptyUIError.injectionConfiguration
        }

        let paywallProducts: [AdaptyProductModel]
        let productsResult = try await getProductsInternal(
            paywall: paywall,
            determineOffers: determineOffers
        )

        Log.ui.verbose("#\(logId)# loadProducts determineOffers: \(determineOffers) success")

        if productsResult.count < paywall.vendorProductIds.count {
            let failedIds = paywall.vendorProductIds.filter { productId in
                !productsResult.contains(where: { $0.vendorProductId == productId })
            }

            Log.ui.warn("#\(logId)# loadProducts determineOffers: \(determineOffers) partial!")
            events.event_didPartiallyLoadProducts(failedProductIds: failedIds)
        }

        return productsResult
    }

    private func getProductsInternal(
        paywall: AdaptyPaywall,
        determineOffers: Bool
    ) async throws -> [AdaptyProductModel] {
        let wrappedProducts: [AdaptyPaywallProductWrapper]

        if determineOffers {
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            wrappedProducts = products.map {
                AdaptyPaywallProductWrapper.full($0)
            }
        } else {
            let products = try await Adapty.getPaywallProductsWithoutDeterminingOffer(paywall: paywall)
            wrappedProducts = products.map {
                AdaptyPaywallProductWrapper.withoutOffer($0)
            }
        }

        return wrappedProducts
    }

    package func getViewConfiguration(
        paywall: AdaptyPaywallModel
    ) async throws -> AdaptyUIConfiguration {
        guard let paywall = paywall as? AdaptyPaywall else {
            throw AdaptyUIError.injectionConfiguration
        }

        return try await Adapty.getViewConfiguration(paywall: paywall)
    }

    func makePurchase(product: AdaptyProductModel) async {
        guard let adaptyProduct = product as? AdaptyPaywallProduct else {
            Log.ui.verbose("#\(logId)# makePurchase error: product is not AdaptyPaywallProduct")
            return
        }

        events.event_didStartPurchase(product: adaptyProduct)

        do {
            let purchaseResult = try await Adapty.makePurchase(product: adaptyProduct)

            events.event_didFinishPurchase(
                product: adaptyProduct,
                purchaseResult: purchaseResult
            )
        } catch {
            let adaptyError = error.asAdaptyError

            if adaptyError.adaptyErrorCode == .paymentCancelled {
                events.event_didFinishPurchase(
                    product: adaptyProduct,
                    purchaseResult: .userCancelled
                )
            } else {
                events.event_didFailPurchase(
                    product: adaptyProduct,
                    error: adaptyError
                )
            }
        }
    }

    func openWebPaywall(for product: AdaptyProductModel) async {
        guard let adaptyProduct = product as? AdaptyPaywallProduct else {
            Log.ui.verbose("#\(logId)# openWebPaywall error: product is not AdaptyPaywallProduct")
            return
        }

        do {
            try await Adapty.openWebPaywall(for: adaptyProduct)

            events.event_didFinishWebPaymentNavigation(
                product: adaptyProduct,
                error: nil
            )
        } catch {
            events.event_didFinishWebPaymentNavigation(
                product: adaptyProduct,
                error: error
            )
        }
    }

    func restorePurchases() async {
        events.event_didStartRestore()

        do {
            let profile = try await Adapty.restorePurchases()
            events.event_didFinishRestore(with: profile)
        } catch {
            events.event_didFailRestore(with: error.asAdaptyError)
        }
    }

    func didPerformAction(_ action: AdaptyUIBuilder.Action) {
        events.event_didPerformAction(action.adaptyUIAction)
    }
}
