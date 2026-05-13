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
    let description: String?
    let price: String?
    let priceAmount: String?
    let priceAmountInteger: String?
    let priceAmountFraction: String?
    let currencyCode: String?
    let currencySymbol: String?
    let pricePerDay: String?
    let pricePerWeek: String?
    let pricePerMonth: String?
    let pricePerYear: String?
    let subscriptionPeriod: String?
    let offerPrice: String?
    let offerPeriods: String?
    let offerNumberOfPeriods: String?

    func value(byTag tag: TextProductTag) -> TextTagValue? {
        let raw: String? = switch tag {
        case .title: title
        case .description: description
        case .price: price
        case .priceAmount: priceAmount
        case .priceAmountInteger: priceAmountInteger
        case .priceAmountFraction: priceAmountFraction
        case .currencyCode: currencyCode
        case .currencySymbol: currencySymbol
        case .pricePerDay: pricePerDay
        case .pricePerWeek: pricePerWeek
        case .pricePerMonth: pricePerMonth
        case .pricePerYear: pricePerYear
        case .subscriptionPeriod: subscriptionPeriod
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
        description = preview.localizedDescription
        price = priceString

        if let amount = preview.price?.amount {
            priceAmount = String(format: "%.2f", amount)
            priceAmountInteger = String(Int(amount))
            let fractionPart = Int((amount - floor(amount)) * 100 + 0.5)
            priceAmountFraction = String(format: "%02d", fractionPart)
        } else {
            priceAmount = nil
            priceAmountInteger = nil
            priceAmountFraction = nil
        }

        currencyCode = preview.price?.currencyCode
        currencySymbol = preview.price?.currencySymbol

        pricePerDay = unit == "day" ? perPeriod : nil
        pricePerWeek = unit == "week" ? perPeriod : nil
        pricePerMonth = unit == "month" ? perPeriod : nil
        pricePerYear = unit == "year" ? perPeriod : nil

        subscriptionPeriod = preview.subscription?.localizedPeriod

        let offer = preview.subscription?.offer
        offerPrice = offer?.price?.localizedString
        offerPeriods = offer?.localizedPeriod
        offerNumberOfPeriods = offer?.localizedNumberOfPeriods
    }
}

#endif
