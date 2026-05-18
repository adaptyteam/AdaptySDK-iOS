//
//  Dev_AdaptyUILogic.swift
//  Adapty
//
//  Created by Alexey Goncharov on 10/23/25.
//

#if canImport(UIKit)

import AdaptyUIBuilder
import Foundation

struct Dev_AdaptyUILogic: AdaptyUIBuilderLogic {
    let logId: String
    let events: AdaptyUIEventsHandler
    let products: [Dev_MockProduct]

    init(
        logId: String,
        events: AdaptyUIEventsHandler,
        products: [Dev_MockProduct]
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

    func reportDidSelectProduct(_ product: ProductResolver, automatic: Bool) {
        events.event_didSelectProduct(product, automatic: automatic)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool { false }

    package func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async {}

    package func getProducts() async throws -> [ProductResolver] {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        return products
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) {
        onStart()
        events.event_didStartPurchase(product: product)

        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_500_000_000)
            events.event_didFinishPurchase(product: product, result: .success)
            onFinish(.success)
        }
    }

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        events.event_didFinishPurchase(product: product, result: .success)
        onFinish(.success)
    }

    func restorePurchases(
        onStart: @MainActor @Sendable @escaping () -> Void,
        onFinish: @MainActor @Sendable @escaping (VS.RestorePurchasesResult) -> Void
    ) {
        onStart()
        events.event_didStartRestore()

        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1_500_000_000)
            events.event_didFinishRestore(result: .success)
            onFinish(.success)
        }
    }

    func reportDidReceiveError(_ error: AdaptyUIBuilderError) {
        events.event_didReceiveError(error)
    }

    func reportCustomerAnalyticEvent(
        name: String,
        params: [String: any Sendable]
    ) {
        events.event_didReceiveAnalyticEvent(name: name, params: params)
    }

    func reportBackendAnalyticEvent(_ event: VS.AnalyticEvent) {}
}

#endif
