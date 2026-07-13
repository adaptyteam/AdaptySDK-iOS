//
//  AdaptyUITagResolverViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Foundation

public enum TextTagValue {
    case notApplicable
    case value(String)
}

public enum TextProductTag: String {
    case title = "TITLE"
    case description = "DESCRIPTION"

    case price = "PRICE"
    case priceAmount = "PRICE_AMOUNT"
    case priceAmountInteger = "PRICE_AMOUNT_INTEGER"
    case priceAmountFraction = "PRICE_AMOUNT_FRACTION"

    case currencyCode = "CURRENCY_CODE"
    case currencySymbol = "CURRENCY_SYMBOL"

    case pricePerDay = "PRICE_PER_DAY"
    case pricePerWeek = "PRICE_PER_WEEK"
    case pricePerMonth = "PRICE_PER_MONTH"
    case pricePerYear = "PRICE_PER_YEAR"

    case subscriptionPeriod = "SUBSCRIPTION_PERIOD"

    case offerPrice = "OFFER_PRICE"
    case offerPeriods = "OFFER_PERIOD"
    case offerNumberOfPeriods = "OFFER_NUMBER_OF_PERIOD"

    case offerPricePerDay = "OFFER_PRICE_PER_DAY"
    case offerPricePerWeek = "OFFER_PRICE_PER_WEEK"
    case offerPricePerMonth = "OFFER_PRICE_PER_MONTH"
    case offerPricePerYear = "OFFER_PRICE_PER_YEAR"
}

@MainActor
package final class AdaptyUITagResolverViewModel: ObservableObject, AdaptyUITagResolver {
    let tagResolver: AdaptyUITagResolver?

    package init(tagResolver: AdaptyUITagResolver?) {
        self.tagResolver = tagResolver
    }

    package func replacement(for tag: String) -> String? {
        tagResolver?.replacement(for: tag)
    }
}

#endif
