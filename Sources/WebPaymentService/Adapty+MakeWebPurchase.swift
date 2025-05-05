//
//  Adapty+MakeWebPurchase.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2025
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension Adapty {
    nonisolated static func makeWebPurchase(
        product: AdaptyPaywallProduct
    ) async throws -> AdaptyPurchaseResult {
        let purchaseUrl = (product as? WebPurchasable)?.purchaseUrl

        return try await withActivatedSDK(
            methodName: .makeWebPurchase,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
                "web_purchase_url": purchaseUrl,
                "paywall_product_index": product.paywallProductIndex
            ]
        ) { sdk in

            let url = try sdk.createWebPurchaseUrl(baseUrl: purchaseUrl, forProduct: product)

            guard await url.open() else {
                throw AdaptyError.failedOpeningPurchaseUrl(url)
            }
            
            return AdaptyPurchaseResult.pending
        }
    }

    nonisolated static func createWebPurchaseUrl(
        product: AdaptyPaywallProduct
    ) async throws -> URL {
        let purchaseUrl = (product as? WebPurchasable)?.purchaseUrl
        return try await withActivatedSDK(
            methodName: .createWebPurchaseUrl,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
                "web_purchase_url": purchaseUrl,
                "paywall_product_index": product.paywallProductIndex,
                "product_locale": product.localizedPrice
            ]
        ) { sdk in
            try sdk.createWebPurchaseUrl(baseUrl: purchaseUrl, forProduct: product)
        }
    }

    private func createWebPurchaseUrl(
        baseUrl: URL?,
        forProduct product: AdaptyPaywallProduct
    ) throws -> URL {
        guard let purchaseUrl = baseUrl else {
            throw AdaptyError.productWithoutPurchaseUrl(adaptyProductId: product.adaptyProductId)
        }

        var parameters = [
            "adapty_profile_id": profileStorage.profileId,
            "adapty_variation_id": product.variationId,
            "adapty_product_id": product.adaptyProductId,
            "adapty_choosen_product_idx": String(product.paywallProductIndex),
            "adapty_product_locale": product.priceLocale.identifier
        ]

        if let offer = product.subscriptionOffer {
            parameters["adapty_offer_category"] = offer.offerType.encodedValue
            parameters["adapty_offer_type"] = offer.paymentMode.encodedValue ?? "unknown"
            let period = offer.subscriptionPeriod
            parameters["adapty_offer_period_units"] = period.unit.encodedValue
            parameters["adapty_offer_number_of_units"] = String(period.numberOfUnits)
        }

        return try purchaseUrl.appendOrOverwriteQueryParameters(parameters)
    }
}

private extension URL {
    @MainActor
    func open() async -> Bool {
#if os(iOS)
        await UIApplication.shared.open(self, options: [:])
#elseif os(macOS)
        NSWorkspace.shared.open(self)
#endif
    }

    func appendOrOverwriteQueryParameters(
        _ parameters: [String: String]
    ) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            throw AdaptyError.failedDecodingPurchaseUrl(url: self)
        }

        var existingParams = components.queryItems?.reduce(into: [String: String]()) {
            $0[$1.name] = $1.value
        } ?? [:]

        for (key, value) in parameters {
            existingParams[key] = value
        }

        components.queryItems = existingParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            throw AdaptyError.failedDecodingPurchaseUrl(url: self)
        }
        return url
    }
}
