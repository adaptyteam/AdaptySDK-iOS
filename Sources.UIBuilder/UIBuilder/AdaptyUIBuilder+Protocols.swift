//
//  AdaptyUIBuilder+Protocols.swift
//  AdaptyUIBuilder
//
//  Created by Alexey Goncharov on 9/23/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyUITagResolver: Sendable {
    func replacement(for tag: String) -> String?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
public protocol AdaptyUITimerResolver: Sendable {
    func timerEndAtDate(for timerId: String) -> Date
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension [String: String]: AdaptyUITagResolver {
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

    func reportDidSelectProduct(_ product: ProductResolver, automatic: Bool)

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool

    func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async throws

    func getProducts(
        determineOffers: Bool
    ) async throws -> [ProductResolver]

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    )

    func openWebPaywall(for product: ProductResolver, in openIn: VC.WebOpenInParameter) async

    func restorePurchases(
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    )

    func reportDidFailRendering(with error: AdaptyUIBuilderError)
}
