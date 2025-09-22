//
//  AdaptyPaywallInterface.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Adapty
import Foundation
import AdaptyUIBuider

package enum AdaptyUIGetProductsResult: Sendable {
    case partial(products: [AdaptyPaywallProduct], failedIds: [String])
    case full(products: [AdaptyPaywallProduct])
}

@MainActor
package protocol AdaptyPaywallInterface {
    var placementId: String { get }
    var variationId: String { get }
    var locale: String? { get }
    var vendorProductIds: [String] { get }

    func getPaywallProductsWithoutDeterminingOffer() async throws -> [AdaptyPaywallProductWithoutDeterminingOffer]
    func getPaywallProducts() async throws -> AdaptyUIGetProductsResult
    func logShowPaywall(viewConfiguration: AdaptyUIConfiguration) async throws
}

extension AdaptyPaywall: AdaptyPaywallInterface {
    package var locale: String? { remoteConfig?.locale }

    package func getPaywallProductsWithoutDeterminingOffer() async throws -> [AdaptyPaywallProductWithoutDeterminingOffer] {
        try await Adapty.getPaywallProductsWithoutDeterminingOffer(paywall: self)
    }

    package func getPaywallProducts() async throws -> AdaptyUIGetProductsResult {
        let products = try await Adapty.getPaywallProducts(paywall: self)

        if products.count == vendorProductIds.count {
            return .full(products: products)
        } else {
            let failedIds = vendorProductIds.filter { productId in
                !products.contains(where: { $0.vendorProductId == productId })
            }
            return .partial(products: products, failedIds: failedIds)
        }
    }

    package func logShowPaywall(viewConfiguration: AdaptyUIConfiguration) async throws {
        await Adapty.logShowPaywall(self, viewConfiguration: viewConfiguration)
    }
}
