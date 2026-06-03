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

    package func logShowFlow() async throws {
        try await Adapty.logShowFlow(flow)
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
        let failedProductIds = flow.paywallsUniqueVendorProductIds.filter { !returnedIds.contains($0) }
        return (products, failedProductIds)
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) {
        guard let adaptyProduct = product as? AdaptyPaywallProduct
        else {
            Log.ui.error("#\(logId)# makePurchase error: product is not AdaptyPaywallProduct")
            Task { @MainActor in onFinish(.fail) }
            return
        }

        if let observerModeResolver {
            observerModeResolver.observerMode(
                didInitiatePurchase: adaptyProduct,
                onStartPurchase: onStart,
                onFinishPurchase: { Task { @MainActor in onFinish(.pending) } }
            )
        } else {
            Task { @MainActor in
                onStart()
                let result = await makePurchaseWithAdapty(product: adaptyProduct)
                onFinish(result)
            }
        }
    }

    private func makePurchaseWithAdapty(product: AdaptyPaywallProduct) async -> VS.PurchaseResult {
        events.event_didStartPurchase(product: product)

        do {
            let purchaseResult = try await Adapty.makePurchase(product: product)

            events.event_didFinishPurchase(
                product: product,
                purchaseResult: purchaseResult
            )

            switch purchaseResult {
            case .success: return .success
            case .pending: return .pending
            case .userCancelled: return .userCanceled
            }
        } catch {
            let adaptyError = error.asAdaptyError

            if adaptyError.adaptyErrorCode == .paymentCancelled {
                events.event_didFinishPurchase(
                    product: product,
                    purchaseResult: .userCancelled
                )
                return .userCanceled
            } else {
                events.event_didFailPurchase(
                    product: product,
                    error: adaptyError
                )
                return .fail
            }
        }
    }

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) async {
        guard let adaptyProduct = product as? AdaptyPaywallProduct
        else {
            Log.ui.error("#\(logId)# makePurchase error: product is not AdaptyPaywallProduct")
            await MainActor.run { onFinish(.fail) }
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
            await MainActor.run { onFinish(.pending) }
        } catch {
            events.event_didFinishWebPaymentNavigation(
                product: adaptyProduct,
                error: error
            )
            await MainActor.run { onFinish(.fail) }
        }
    }

    func restorePurchases(
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping (VS.RestorePurchasesResult) -> Void
    ) {
        if let observerModeResolver {
            observerModeResolver.observerModeDidInitiateRestorePurchases(
                onStartRestore: onStart,
                onFinishRestore: { Task { @MainActor in onFinish(.success) } }
            )
        } else {
            Task { @MainActor in
                events.event_didStartRestore()

                onStart()
                let result: VS.RestorePurchasesResult
                do {
                    let profile = try await Adapty.restorePurchases()
                    events.event_didFinishRestore(with: profile)
                    result = .success
                } catch {
                    events.event_didFailRestore(with: error.asAdaptyError)
                    result = .fail
                }
                onFinish(result)
            }
        }
    }

    func reportDidReceiveError(_ error: AdaptyUIBuilderError) {
        events.event_didReceiveError(error)
    }

    func reportCustomerAnalyticEvent(name: String, params: [String: any Sendable]) {
        events.event_didReceiveAnalyticEvent(name: name, params: params)
    }

    func reportBackendAnalyticEvent(_ event: VS.AnalyticEvent) {
        Task {
            try? await Adapty.logFlowAnalyticsViaAdaptyUI(
                variationId: flow.variationId,
                sessionId: nil, // TODO: run session of flow
                flowVersionId: viewConfigurationId, // TODO: layouts: flow.versionId
                flowLayoutId: viewConfigurationId,
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
