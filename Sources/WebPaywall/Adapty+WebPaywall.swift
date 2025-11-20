//
//  Adapty+WebPaywall.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.06.2025
//

import Foundation

#if os(iOS)
    import SafariServices
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public enum AdaptyURLOpenMode: String, Sendable {
    case externalBrowser
    case inAppBrowser
}

public extension Adapty {
    nonisolated static func openWebPaywall(
        for product: AdaptyPaywallProduct,
        in mode: AdaptyURLOpenMode = .externalBrowser
    ) async throws(AdaptyError) {
        try await withActivatedSDK(
            methodName: .openWebPaywall,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
                "web_purchase_url": (product as? WebPaywallURLProviding)?.webPaywallBaseUrl,
                "paywall_product_index": product.paywallProductIndex,
                "mode": mode.rawValue,
            ]
        ) { sdk throws(AdaptyError) in
            try await sdk.openWebPaywall(for: product, mode: mode)
        }
    }

    nonisolated static func createWebPaywallUrl(
        for product: AdaptyPaywallProduct
    ) async throws(AdaptyError) -> URL {
        try await withActivatedSDK(
            methodName: .createWebPaywallUrl,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
                "web_purchase_url": (product as? WebPaywallURLProviding)?.webPaywallBaseUrl,
                "paywall_product_index": product.paywallProductIndex,
                "product_locale": product.localizedPrice,
            ]
        ) { sdk throws(AdaptyError) in
            try sdk.createWebPaywallUrl(for: product)
        }
    }

    nonisolated static func openWebPaywall(
        for paywall: AdaptyPaywall,
        in mode: AdaptyURLOpenMode = .externalBrowser
    ) async throws(AdaptyError) {
        try await withActivatedSDK(
            methodName: .openWebPaywall,
            logParams: [
                "paywall_name": paywall.name,
                "variation_id": paywall.variationId,
                "web_purchase_url": paywall.webPaywallBaseUrl,
                "mode": mode.rawValue,
            ]
        ) { sdk throws(AdaptyError) in
            try await sdk.openWebPaywall(for: paywall, mode: mode)
        }
    }

    nonisolated static func createWebPaywallUrl(
        for paywall: AdaptyPaywall
    ) async throws(AdaptyError) -> URL {
        try await withActivatedSDK(
            methodName: .createWebPaywallUrl,
            logParams: [
                "paywall_name": paywall.name,
                "variation_id": paywall.variationId,
                "web_purchase_url": paywall.webPaywallBaseUrl,
            ]
        ) { sdk throws(AdaptyError) in
            try sdk.createWebPaywallUrl(for: paywall)
        }
    }

    private func openWebPaywall(
        for product: AdaptyPaywallProduct,
        mode: AdaptyURLOpenMode
    ) async throws(AdaptyError) {
        let url = try createWebPaywallUrl(for: product)
        guard await url.open(mode: mode) else {
            throw .failedOpeningWebPaywallUrl(url)
        }
        profileStorage.setLastOpenedWebPaywallDate()
    }

    private func openWebPaywall(
        for paywall: AdaptyPaywall,
        mode: AdaptyURLOpenMode
    ) async throws(AdaptyError) {
        let url = try createWebPaywallUrl(for: paywall)
        guard await url.open(mode: mode) else {
            throw .failedOpeningWebPaywallUrl(url)
        }
        profileStorage.setLastOpenedWebPaywallDate()
    }

    private func createWebPaywallUrl(
        for paywall: AdaptyPaywall
    ) throws(AdaptyError) -> URL {
        guard let webPaywallBaseUrl = paywall.webPaywallBaseUrl else {
            throw .paywallWithoutPurchaseUrl(paywall: paywall)
        }

        let parameters = [
            "adapty_profile_id": profileStorage.profileId,
            "adapty_variation_id": paywall.variationId,
        ]

        return try webPaywallBaseUrl.appendOrOverwriteQueryParameters(parameters)
    }

    private func createWebPaywallUrl(
        for product: AdaptyPaywallProduct
    ) throws(AdaptyError) -> URL {
        guard let webPaywallBaseUrl = (product as? WebPaywallURLProviding)?.webPaywallBaseUrl else {
            throw .productWithoutPurchaseUrl(adaptyProductId: product.adaptyProductId)
        }

        var parameters = [
            "adapty_profile_id": profileStorage.profileId,
            "adapty_variation_id": product.variationId,
            "adapty_product_id": product.adaptyProductId,
            "adapty_chosen_product_idx": String(product.paywallProductIndex),
            "adapty_product_locale": product.priceLocale.identifier,
        ]

        if let offer = product.subscriptionOffer {
            parameters["adapty_offer_category"] = offer.offerType.rawValue
            parameters["adapty_offer_type"] = offer.paymentMode.encodedValue ?? "unknown"
            let period = offer.subscriptionPeriod
            parameters["adapty_offer_period_units"] = period.unit.encodedValue
            parameters["adapty_offer_number_of_units"] = String(period.numberOfUnits)
        }

        return try webPaywallBaseUrl.appendOrOverwriteQueryParameters(parameters)
    }
}

private extension URL {
    @MainActor
    func open(mode: AdaptyURLOpenMode) async -> Bool {
        #if os(iOS)
            switch mode {
            case .externalBrowser:
                return await UIApplication.shared.open(self, options: [:])
            case .inAppBrowser:
                guard let topViewController = UIApplication.shared.topPresentedController else {
                    return await UIApplication.shared.open(self, options: [:])
                }
                
                let safariViewController = SFSafariViewController(url: self)
                topViewController.present(safariViewController, animated: true)
                return true
            }
        #elseif os(macOS)
            NSWorkspace.shared.open(self)
            return true
        #endif
    }

    func appendOrOverwriteQueryParameters(
        _ parameters: [String: String]
    ) throws(AdaptyError) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            throw .failedDecodingWebPaywallUrl(url: self)
        }

        var existingParams = components.queryItems?.reduce(into: [String: String]()) {
            $0[$1.name] = $1.value
        } ?? [:]

        for (key, value) in parameters {
            existingParams[key] = value
        }

        components.queryItems = existingParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components.url else {
            throw .failedDecodingWebPaywallUrl(url: self)
        }
        return url
    }
}
