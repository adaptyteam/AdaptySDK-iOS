//
//  Adapty+MakeWebPurchase.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2025
//

import Foundation

public extension Adapty {
    nonisolated static func makeWebPurchase(
        product: AdaptyPaywallProduct
    ) async throws -> AdaptyPurchaseResult {
        try await withActivatedSDK(
            methodName: .makeWebPurchase,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
            ]
        ) { _ in

            AdaptyPurchaseResult.pending
        }
    }
}
