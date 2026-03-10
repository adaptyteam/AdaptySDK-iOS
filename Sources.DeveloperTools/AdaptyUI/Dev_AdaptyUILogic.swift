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
    
    init(
        logId: String,
        events: AdaptyUIEventsHandler
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
        events.event_didPerformAction(action)
    }

    func reportDidSelectProduct(_ product: ProductResolver, automatic: Bool) {
        events.event_didSelectProduct(product, automatic: automatic)
    }

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool { false }

    package func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async {
    }

    package func getProducts(
        determineOffers: Bool
    ) async throws -> [ProductResolver] {
        [
            Dev_MockProduct(id: "premium-free_trial-0-usd"),
            Dev_MockProduct(id: "premium-pay_as_you_go-1.99-usd"),
            Dev_MockProduct(id: "premium-pay_up_front-9.99-usd"),
            Dev_MockProduct(id: "basic-default-4.99-usd"),
        ]
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    ) {
        onStart()
        events.event_didStartPurchase(product: product)

        Task { @MainActor in
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            
            onFinish()
        }
    }

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter
    ) async {
        
    }

    func restorePurchases(
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    ) {
        events.event_didStartRestore()
    }

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
        events.event_didFailRendering(with: error)
    }
}

#endif
