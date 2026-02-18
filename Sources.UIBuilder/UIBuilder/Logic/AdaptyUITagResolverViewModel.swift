//
//  AdaptyUITagResolverViewModel.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit) || canImport(AppKit)

import Foundation

public enum TextTagValue {
    case notApplicable
    case value(String)
}

public enum TextProductTag: String {
    case title = "TITLE"

    case price = "PRICE"
    case pricePerDay = "PRICE_PER_DAY"
    case pricePerWeek = "PRICE_PER_WEEK"
    case pricePerMonth = "PRICE_PER_MONTH"
    case pricePerYear = "PRICE_PER_YEAR"

    case offerPrice = "OFFER_PRICE"
    case offerPeriods = "OFFER_PERIOD"
    case offerNumberOfPeriods = "OFFER_NUMBER_OF_PERIOD"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
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
