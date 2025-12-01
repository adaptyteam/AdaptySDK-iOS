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

    func reportDidSelectProduct(_ product: ProductResolver, automatic: Bool) {
        events.event_didSelectProduct(product, automatic: automatic)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool {
        false
    }

    func logShowPaywall(viewConfiguration: AdaptyUIConfiguration) async {}

    func getProducts(determineOffers: Bool) async throws -> [ProductResolver] {
        products
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    ) {
        events.event_didStartPurchase(product: product)
    }

    func restorePurchases(
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    ) {
        events.event_didStartRestore()
    }

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter
    ) async {}

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
        events.event_didFailRendering(with: error)
    }
}

#endif
