//
//  Dev_AdaptyUILogic.swift
//  Adapty
//
//  Created by Alexey Goncharov on 10/23/25.
//

#if canImport(UIKit)

import AdaptyUIBuilder
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct Dev_AdaptyUILogic: AdaptyUIBuilderLogic {
 
    func reportViewDidAppear() {}

    func reportViewDidDisappear() {}

    func reportDidPerformAction(_ action: AdaptyUIBuilder.Action) {}

    func reportDidSelectProduct(_ product: ProductResolver) {}

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
        onStart: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {}

    func openWebPaywall(for product: ProductResolver) async {}

    func restorePurchases() async {
    }

    func reportDidFailRendering(with error: AdaptyUIBuilderError) {
    }
}

#endif
