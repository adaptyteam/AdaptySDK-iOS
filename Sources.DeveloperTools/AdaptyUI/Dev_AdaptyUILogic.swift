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
    /// How long mocked products, purchases and restores take to answer.
    let responseDelay: TimeInterval

    init(
        logId: String,
        events: AdaptyUIEventsHandler,
        products: [Dev_MockProduct],
        responseDelay: TimeInterval
    ) {
        self.logId = logId
        self.events = events
        self.products = products
        self.responseDelay = responseDelay
    }

    private var responseDelayNanoseconds: UInt64 {
        UInt64(max(responseDelay, 0) * 1_000_000_000)
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

    package func logShowFlow() async throws {}

    package func getProducts() async throws -> [ProductResolver] {
        try await Task.sleep(nanoseconds: responseDelayNanoseconds)
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
            try await Task.sleep(nanoseconds: responseDelayNanoseconds)
            events.event_didFinishPurchase(product: product, result: .success)
            onFinish(.success)
        }
    }

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter,
        onFinish: @MainActor @Sendable @escaping (VS.PurchaseResult) -> Void
    ) async {
        try? await Task.sleep(nanoseconds: responseDelayNanoseconds)
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
            try await Task.sleep(nanoseconds: responseDelayNanoseconds)
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

    func reportBackendAnalyticEvent(_ event: VS.AnalyticEvent, sessionId: UUID) {}
}

#endif
