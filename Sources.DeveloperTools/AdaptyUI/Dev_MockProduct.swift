//
//  Dev_MockProduct.swift
//  AdaptyDeveloperTools
//

#if canImport(UIKit)

import AdaptyUIBuilder
import Foundation

struct Dev_MockProduct: ProductResolver, Sendable {
    let flowId: String
    let adaptyProductId: String
    let paymentMode: PaymentModeValue

    let title: String?
    let price: String?
    let pricePerDay: String?
    let pricePerWeek: String?
    let pricePerMonth: String?
    let pricePerYear: String?
    let offerPrice: String?
    let offerPeriods: String?
    let offerNumberOfPeriods: String?

    func value(byTag tag: TextProductTag) -> TextTagValue? {
        let raw: String? = switch tag {
        case .title: title
        case .price: price
        case .pricePerDay: pricePerDay
        case .pricePerWeek: pricePerWeek
        case .pricePerMonth: pricePerMonth
        case .pricePerYear: pricePerYear
        case .offerPrice: offerPrice
        case .offerPeriods: offerPeriods
        case .offerNumberOfPeriods: offerNumberOfPeriods
        }
        return raw.map(TextTagValue.value) ?? .notApplicable
    }
}

extension Dev_MockProduct {
    init(from preview: Dev_PreviewProduct) {
        let priceString = preview.price?.localizedString
        let perPeriod: String? = {
            guard let priceString, let period = preview.subscription?.localizedPeriod else { return nil }
            return "\(priceString)/\(period)"
        }()
        let unit = preview.subscription?.period.unit

        flowId = preview.flowProductId
        adaptyProductId = preview.adaptyProductId
        paymentMode = preview.subscription?.offer?.paymentMode

        title = preview.localizedTitle
        price = priceString
        pricePerDay = unit == "day" ? perPeriod : nil
        pricePerWeek = unit == "week" ? perPeriod : nil
        pricePerMonth = unit == "month" ? perPeriod : nil
        pricePerYear = unit == "year" ? perPeriod : nil

        let offer = preview.subscription?.offer
        offerPrice = offer?.price?.localizedString
        offerPeriods = offer?.localizedPeriod
        offerNumberOfPeriods = offer?.localizedNumberOfPeriods
    }
}

#endif
