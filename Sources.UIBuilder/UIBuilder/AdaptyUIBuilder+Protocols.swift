//
//  AdaptyUIBuilder+Protocols.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyTagResolver: Sendable {
    func replacement(for tag: String) -> String?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyTimerResolver: Sendable {
    func timerEndAtDate(for timerId: String) -> Date
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension [String: String]: AdaptyTagResolver {
    public func replacement(for tag: String) -> String? {
        self[tag]
    }
}

@MainActor
package protocol AdaptyUIBuilderObserverModeResolver: Sendable {
    func observerMode(
        didInitiatePurchase product: ProductResolver,
        onStartPurchase: @escaping () -> Void,
        onFinishPurchase: @escaping () -> Void
    )
}

@MainActor
package protocol AdaptyUIBuilderLogic {
    func reportViewDidAppear()

    func reportViewDidDisappear()

    func reportDidPerformAction(_ action: AdaptyUIBuilder.Action)

    func reportDidSelectProduct(_ product: ProductResolver)

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool

    func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async throws

    func getProducts(
        determineOffers: Bool
    ) async throws -> [ProductResolver]

    func makePurchase(product: ProductResolver) async

    func openWebPaywall(for product: ProductResolver) async

    func restorePurchases() async

    func didPerformAction(_ action: AdaptyUIBuilder.Action)
}
