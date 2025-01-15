//
//  SK2Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
typealias SK2Product = Product

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product {
    @inlinable
    var unfCurrencyCode: String? {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return priceFormatStyle.currencyCode
        }

        guard let decoded = try? JSONSerialization.jsonObject(with: jsonRepresentation),
              let dict = decoded as? [String: Any],
              let attributes = dict["attributes"] as? [String: Any],
              let offers = attributes["offers"] as? [[String: Any]],
              let code = offers.first?["currencyCode"] as? String
        else {
            return nil
        }

        return code
    }

    @inlinable
    var unfPriceLocale: Locale {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return priceFormatStyle.locale
        }

        return .autoupdatingCurrent
    }

    @inlinable
    var unfPeriodLocale: Locale {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return subscriptionPeriodFormatStyle.locale
        }
        return .autoupdatingCurrent
    }

    @MainActor // TODO: discuss this
    func unfPurchase(
        options: Set<Product.PurchaseOption> = []
    ) async throws -> PurchaseResult {
#if canImport(UIKit) && (os(iOS) || os(tvOS)) && compiler(>=6.0.3)
        if #available(iOS 18.2, tvOS 18.2, visionOS 2.2, *),
           let viewController = UIApplication.shared.topPresentedController
        {
            try await purchase(confirmIn: viewController, options: options)
        } else {
            try await purchase(options: options)
        }
#elseif VISION_OS || os(visionOS)
        if let scene = UIApplication.shared.activeScene {
            try await purchase(confirmIn: scene, options: options)
        } else {
            // TODO: check the error
            throw AdaptyError.cantMakePayments()
        }
#else
        try await purchase(options: options)
#endif
    }
}
