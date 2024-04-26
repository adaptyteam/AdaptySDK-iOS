//
//  Text+ProductTag.swift
//
//
//  Created by Alexey Goncharov on 15.8.23..
//

import Adapty
import Foundation

extension AdaptyUI {
    enum ProductTagReplacement {
        case notApplicable
        case value(String)
    }

    typealias ProductTagConverter = (ProductTag) -> ProductTagReplacement?

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

extension AdaptyUI.ProductTag {
    static func fromRawMatch(_ match: String) -> Self? {
        let cleanedMatch = match
            .replacingOccurrences(of: "</", with: "")
            .replacingOccurrences(of: "/>", with: "")

        return .init(rawValue: cleanedMatch)
    }
}

extension String {
    private static let productTagPattern = "</[a-zA-Z_0-9-]+/>"

    func replaceProductTags(converter: AdaptyUI.ProductTagConverter) -> String? {
        guard let regex = try? NSRegularExpression(pattern: Self.productTagPattern) else {
            return self
        }

        var result = self
        var stop = false

        while !stop {
            let range = NSRange(result.startIndex ..< result.endIndex, in: result)

            guard let match = regex.firstMatch(in: result, range: range),
                  let matchRange = Range(match.range, in: result) else {
                stop = true
                break
            }

            let matchTag = result[matchRange]
            guard let tag = AdaptyUI.ProductTag.fromRawMatch(String(matchTag)),
                  let replacement = converter(tag) else {
                result = result.replacingOccurrences(of: matchTag, with: "")
                continue
            }

            switch replacement {
            case .notApplicable:
                // in case of notApplicable tag we are not able to render the full string
                return nil
            case let .value(replacementString):
                result = result.replacingOccurrences(of: matchTag, with: replacementString)
            }
        }

        return result
    }
}
