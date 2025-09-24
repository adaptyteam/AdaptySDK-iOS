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
    let paywall: AdaptyPaywall
    let events: AdaptyEventsHandler
    let observerModeResolver: AdaptyObserverModeResolver?

    package init(
        logId: String,
        paywall: AdaptyPaywall,
        events: AdaptyEventsHandler,
        observerModeResolver: AdaptyObserverModeResolver?
    ) {
        self.logId = logId
        self.paywall = paywall
        self.events = events
        self.observerModeResolver = observerModeResolver
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

    func reportDidSelectProduct(_ product: ProductResolver) {
        guard let adaptyProduct = product as? AdaptyPaywallProductWithoutDeterminingOffer else {
            Log.ui.verbose("#\(logId)# makePurchase error: product is not AdaptyPaywallProductWithoutDeterminingOffer")
            return
        }

        events.event_didSelectProduct(adaptyProduct)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool {
        events.event_didFailLoadingProducts(with: error.asAdaptyError)
    }

    package func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async {
        await Adapty.logShowPaywall(paywall, viewConfiguration: viewConfiguration)
    }

    package func getProducts(
        determineOffers: Bool
    ) async throws -> [ProductResolver] {
        let paywallProducts: [ProductResolver]
        let productsResult = try await getProductsInternal(
            determineOffers: determineOffers
        )

        Log.ui.verbose("#\(logId)# loadProducts determineOffers: \(determineOffers) success")
        let failedIds = productsResult.1
        if !failedIds.isEmpty {
            Log.ui.warn("#\(logId)# loadProducts determineOffers: \(determineOffers) partial!")
            events.event_didPartiallyLoadProducts(failedProductIds: failedIds)
        }

        return productsResult.0
    }

    private func getProductsInternal(
        determineOffers: Bool
    ) async throws -> ([ProductResolver], [String]) {
        let wrappedProducts: [AdaptyPaywallProductWrapper]
        let failedProductIds: [String]

        if determineOffers {
            let products = try await Adapty.getPaywallProducts(paywall: paywall)
            wrappedProducts = products.map {
                AdaptyPaywallProductWrapper.full($0)
            }
            failedProductIds = paywall.absentVendorProductIds(in: products)

        } else {
            let products = try await Adapty.getPaywallProductsWithoutDeterminingOffer(paywall: paywall)
            wrappedProducts = products.map {
                AdaptyPaywallProductWrapper.withoutOffer($0)
            }
            failedProductIds = paywall.absentVendorProductIds(in: products)
        }

        return (wrappedProducts, failedProductIds)
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {
        guard let adaptyProduct = product as? AdaptyPaywallProduct else {
            Log.ui.verbose("#\(logId)# makePurchase error: product is not AdaptyPaywallProduct")
            return
        }
        
        if let observerModeResolver {
            observerModeResolver.observerMode(
                didInitiatePurchase: adaptyProduct,
                onStartPurchase: onStart,
                onFinishPurchase: onFinish
            )
        } else {
            Task { @MainActor in
                onStart()
                await makePurchaseWithAdapty(product: adaptyProduct)
                onFinish()
            }
        }
    }

    private func makePurchaseWithAdapty(product: AdaptyPaywallProduct) async {
        events.event_didStartPurchase(product: product)

        do {
            let purchaseResult = try await Adapty.makePurchase(product: product)

            events.event_didFinishPurchase(
                product: product,
                purchaseResult: purchaseResult
            )
        } catch {
            let adaptyError = error.asAdaptyError

            if adaptyError.adaptyErrorCode == .paymentCancelled {
                events.event_didFinishPurchase(
                    product: product,
                    purchaseResult: .userCancelled
                )
            } else {
                events.event_didFailPurchase(
                    product: product,
                    error: adaptyError
                )
            }
        }
    }

    func openWebPaywall(for product: ProductResolver) async {
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
    
    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
        events.event_didFailRendering(with: error)
    }
}

private extension AdaptyPaywall {
    func absentVendorProductIds(
        in responseProducts: [AdaptyProduct]
    ) -> [String] {
        vendorProductIds.filter { vendorProductId in
            !responseProducts.contains(
                where: {
                    $0.vendorProductId == vendorProductId
                }
            )
        }
    }
}
