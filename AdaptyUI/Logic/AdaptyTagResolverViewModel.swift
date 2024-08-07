//
//  AdaptyTagResolverViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Adapty
import Foundation

@available(iOS 15.0, *)
extension AdaptyUI {
    enum ProductTagReplacement {
        case notApplicable
        case value(String)
    }

    enum ProductTag: String {
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
}

@available(iOS 15.0, *)
public protocol AdaptyTagResolver {
    func replacement(for tag: String) -> String?
}

@available(iOS 15.0, *)
extension Dictionary<String, String>: AdaptyTagResolver {
    public func replacement(for tag: String) -> String? { self[tag] }
}

@available(iOS 15.0, *)
package class AdaptyTagResolverViewModel: ObservableObject, AdaptyTagResolver {
    let tagResolver: AdaptyTagResolver?
    
    package init(tagResolver: AdaptyTagResolver?) {
        self.tagResolver = tagResolver
    }
    
    package func replacement(for tag: String) -> String? {
        tagResolver?.replacement(for: tag)
    }
}

#endif
