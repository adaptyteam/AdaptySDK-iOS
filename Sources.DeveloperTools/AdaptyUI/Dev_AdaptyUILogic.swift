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
    func reportViewDidAppear() {}

    func reportViewDidDisappear() {}

    func reportDidPerformAction(_ action: AdaptyUIBuilder.Action) {}

    func reportDidSelectProduct(_ product: ProductResolver, automatic: Bool) {}

    func reportDidFailLoadingProductsShouldRetry(with error: Error) -> Bool { false }

    package func logShowPaywall(
        viewConfiguration: AdaptyUIConfiguration
    ) async {}

    package func getProducts(
        determineOffers: Bool
    ) async throws -> [ProductResolver] {
        []
    }

    private func getProductsInternal(
        determineOffers: Bool
    ) async throws -> ([ProductResolver], [String]) {
        ([], [])
    }

    func makePurchase(
        product: ProductResolver,
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    ) {}

    func openWebPaywall(
        for product: ProductResolver,
        in openIn: VC.Action.WebOpenInParameter
    ) async {}

    func restorePurchases(
        onStart: @MainActor @escaping () -> Void,
        onFinish: @MainActor @escaping () -> Void
    ) {}

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {}
}

#endif
