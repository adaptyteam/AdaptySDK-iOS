//
//  AdaptyUIBuilder+Logic.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/22/25.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import Foundation

struct AdaptyUILogic: AdaptyUIBuilderLogic {
    let logId: String
    let flow: AdaptyFlow
    let viewConfigurationId: String
    let events: AdaptyEventsHandler
    let observerModeResolver: AdaptyObserverModeResolver?

    package init(
        logId: String,
        flow: AdaptyFlow,
        viewConfigurationId: String,
        events: AdaptyEventsHandler,
        observerModeResolver: AdaptyObserverModeResolver?
    ) {
        self.logId = logId
        self.flow = flow
        self.viewConfigurationId = viewConfigurationId
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

    func reportDidSelectProduct(_ product: ProductResolver, automatic: Bool) {
        guard let product = product as? AdaptyPaywallProduct else {
            Log.ui.error("#\(logId)# reportDidSelectProduct error: product is not AdaptyPaywallProduc")
            return
        }

        events.event_didSelectProduct(product, automatic: automatic)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool {
        events.event_didFailLoadingProducts(with: error.asAdaptyError)
    }

    package func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async {
        try? await Adapty.logFlowAnalyticsViaAdaptyUI(
            variationId: flow.variationId,
            viewConfigurationId: viewConfiguration.id,
            params: AdaptyUIFlowScreenShowedParameters( // TODO: log show screen
                screenInstanceId: "unknown_screen",
                screenOrder: 0,
                isLatestScreen: false
            )
        )
    }

    package func getProducts() async throws -> [ProductResolver] {
        let productsResult = try await getProductsInternal()

        Log.ui.verbose("#\(logId)# loadProducts success")
        let failedIds = productsResult.1
        if !failedIds.isEmpty {
            Log.ui.warn("#\(logId)# loadProducts partial!")
            events.event_didPartiallyLoadProducts(failedProductIds: failedIds)
        }

        return productsResult.0
    }

    private func getProductsInternal() async throws -> ([ProductResolver], [String]) {
        let products = try await Adapty.getPaywallProducts(flow: flow)
        let returnedIds = Set(products.map(\.vendorProductId))
        let failedProductIds = flow.vendorProductIds.filter { !returnedIds.contains($0) }
        return (products, failedProductIds)
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping () -> Void
    ) {
        guard let adaptyProduct = product as? AdaptyPaywallProduct
        else {
            Log.ui.error("#\(logId)# makePurchase error: product is not AdaptyPaywallProduct")
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

    func openWebPaywall(for product: ProductResolver, in openIn: VC.Action.WebOpenInParameter) async {
        guard let adaptyProduct = product as? AdaptyPaywallProduct
        else {
            Log.ui.error("#\(logId)# makePurchase error: product is not AdaptyPaywallProduct")
            return
        }

        do {
            try await Adapty.openWebPaywall(
                for: adaptyProduct,
                in: openIn.toURLOpenMode
            )

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

    func restorePurchases(
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping () -> Void
    ) {
        if let observerModeResolver {
            observerModeResolver.observerModeDidInitiateRestorePurchases(
                onStartRestore: onStart,
                onFinishRestore: onFinish
            )
        } else {
            Task { @MainActor in
                events.event_didStartRestore()

                onStart()
                do {
                    let profile = try await Adapty.restorePurchases()
                    events.event_didFinishRestore(with: profile)
                } catch {
                    events.event_didFailRestore(with: error.asAdaptyError)
                }
                onFinish()
            }
        }
    }

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
        events.event_didFailRendering(with: error)
    }

    func reportCustomerAnalyticEvent(name: String, params: [String: any Sendable]) {
        events.event_didReceiveAnalyticEvent(name: name, params: params)
    }

    func reportBackendAnalyticEvent(_ event: VS.AnalyticEvent) {
        Task {
            try? await Adapty.logFlowAnalyticsViaAdaptyUI(
                variationId: flow.variationId,
                viewConfigurationId: viewConfigurationId,
                params: event
            )
        }
    }
}

private extension VC.Action.WebOpenInParameter {
    var toURLOpenMode: AdaptyWebPresentation {
        switch self {
        case .browserInApp: .inAppBrowser
        case .browserOutApp: .externalBrowser
        }
    }
}

#endif
