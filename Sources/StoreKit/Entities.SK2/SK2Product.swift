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
    var introductoryOfferEligibility: AdaptyEligibility {
        get async {
            guard
                let subscription,
                subscription.introductoryOffer != nil else {
                return .notApplicable
            }

            return await AdaptyEligibility(booleanLiteral: subscription.isEligibleForIntroOffer)
        }
    }

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

    func unfWinBackOffer(byId id: String?) -> SK2Product.SubscriptionOffer? {
        #if compiler(<6.0)
            return nil
        #else
            guard let id, #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) else {
                return nil
            }

            return subscription?.winBackOffers.first { $0.id == id }
        #endif
    }
}
