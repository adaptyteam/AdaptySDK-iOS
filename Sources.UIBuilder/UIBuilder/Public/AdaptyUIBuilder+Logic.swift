//
//  AdaptyUIBuilder+Logic.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptyUIBuilderAppLogic: AdaptyUIBuilderLogic {
    let logId: String
    let events: AdaptyEventsHandler
    let products: [ProductResolver]

    init(
        logId: String,
        products: [ProductResolver],
        events: AdaptyEventsHandler
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

    func logShowPaywall(viewConfiguration: AdaptyUIConfiguration) async {}

    func getProducts(determineOffers: Bool) async throws -> [ProductResolver] {
        products
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {
        events.event_didStartPurchase(product: product)
    }

    func restorePurchases() async {
        events.event_didStartRestore()
    }

    func openWebPaywall(for product: any AdaptyUIBuider.ProductResolver) async {}
    
    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
        events.event_didFailRendering(with: error)
    }
}
