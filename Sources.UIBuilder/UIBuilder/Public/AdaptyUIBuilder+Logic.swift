//
//  AdaptyUIBuilder+Logic.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

#if canImport(UIKit)

import Foundation

struct AdaptyUIBuilderAppLogic: AdaptyUIBuilderLogic {
    let logId: String
    let events: AdaptyUIEventsHandler
    let products: [ProductResolver]

    init(
        logId: String,
        products: [ProductResolver],
        events: AdaptyUIEventsHandler
    ) {
        self.logId = logId
        self.events = events
        self.products = products
    }

    func reportViewDidAppear() {
        events.event_viewDidAppear()
    }

    func reportViewDidDisappear() {
        events.event_viewDidDisappear()
    }

    func reportDidPerformAction(_ action: AdaptyUIBuilder.Action) {
        events.event_didPerformAction(action)
    }

    func reportDidSelectProduct(_ product: ProductResolver) {
        events.event_didSelectProduct(product)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool {
        false
    }

    func logShowFlow() async {}

    func getProducts() async throws -> [ProductResolver] {
        products
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) {
        events.event_didStartPurchase(product: product)
    }

    func restorePurchases(
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping (VS.RestorePurchasesResult) -> Void
    ) {
        events.event_didStartRestore()
    }

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) async {}

    func reportDidReceiveError(_ error: AdaptyUIBuilderError) {
        events.event_didReceiveError(error)
    }

    func reportCustomerAnalyticEvent(name: String, params: [String: any Sendable]) {}

    func reportBackendAnalyticEvent(_ event: VS.AnalyticEvent, sessionId: UUID) {}
}

#endif
