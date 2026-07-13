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
    let offerPricePerDay: String?
    let offerPricePerWeek: String?
    let offerPricePerMonth: String?
    let offerPricePerYear: String?

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
        case .offerPricePerDay: offerPricePerDay
        case .offerPricePerWeek: offerPricePerWeek
        case .offerPricePerMonth: offerPricePerMonth
        case .offerPricePerYear: offerPricePerYear
        }
        return raw.map(TextTagValue.value) ?? .notApplicable
    }
}

extension Dev_MockProduct {
    init(from preview: Dev_PreviewProduct) {
        let priceString = preview.price?.localizedString
        let currencyCode = preview.price?.currencyCode

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

        self.currencyCode = currencyCode
        currencySymbol = preview.price?.currencySymbol

        let subscription = preview.subscription
        pricePerDay = Dev_MockProduct.pricePer(.day, preview: preview)
        pricePerWeek = Dev_MockProduct.pricePer(.week, preview: preview)
        pricePerMonth = Dev_MockProduct.pricePer(.month, preview: preview)
        pricePerYear = Dev_MockProduct.pricePer(.year, preview: preview)

        subscriptionPeriod = subscription?.localizedPeriod

        let offer = subscription?.offer
        offerPrice = offer?.price?.localizedString
        offerPeriods = offer?.localizedPeriod
        offerNumberOfPeriods = offer?.localizedNumberOfPeriods

        offerPricePerDay = Dev_MockProduct.offerPricePer(.day, preview: preview)
        offerPricePerWeek = Dev_MockProduct.offerPricePer(.week, preview: preview)
        offerPricePerMonth = Dev_MockProduct.offerPricePer(.month, preview: preview)
        offerPricePerYear = Dev_MockProduct.offerPricePer(.year, preview: preview)
    }

    // MARK: - Price-per-period math (mirrors SDK constants in AdaptyProductSubscriptionPeriod+Extensions)

    private enum PeriodUnit: String {
        case day, week, month, year
    }

    private static func numberOfPeriods(unit: String, numberOfUnits: Int, in target: PeriodUnit) -> Double {
        let n = Double(numberOfUnits)
        switch (unit, target) {
        case ("day", .day): return n
        case ("day", .week): return n / 7
        case ("day", .month): return n / 30
        case ("day", .year): return n / 365
        case ("week", .day): return n * 7
        case ("week", .week): return n
        case ("week", .month): return n / (30.0 / 7.0)
        case ("week", .year): return n / 52
        case ("month", .day): return n * 30
        case ("month", .week): return n * (30.0 / 7.0)
        case ("month", .month): return n
        case ("month", .year): return n / 12
        case ("year", .day): return n * 365
        case ("year", .week): return n * 52
        case ("year", .month): return n * 12
        case ("year", .year): return n
        default: return 0
        }
    }

    private static func format(_ amount: Double, currencyCode: String?) -> String? {
        guard amount.isFinite else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let currencyCode {
            formatter.currencyCode = currencyCode
        }
        return formatter.string(from: NSNumber(value: amount))
    }

    private static func pricePer(_ target: PeriodUnit, preview: Dev_PreviewProduct) -> String? {
        guard let amount = preview.price?.amount,
              let subscription = preview.subscription else { return nil }
        let periods = numberOfPeriods(
            unit: subscription.period.unit,
            numberOfUnits: subscription.period.numberOfUnits,
            in: target
        )
        guard periods > 0 else { return nil }
        return format(amount / periods, currencyCode: preview.price?.currencyCode)
    }

    private static func offerPricePer(_ target: PeriodUnit, preview: Dev_PreviewProduct) -> String? {
        guard let offer = preview.subscription?.offer,
              let offerAmount = offer.price?.amount else { return nil }

        let (effectiveAmount, repeatCount): (Double, Int) =
            switch offer.paymentMode {
            case "pay_up_front":
                (offerAmount, offer.numberOfPeriods)
            case "free_trial":
                (0, 1)
            default: // pay_as_you_go and unknown
                (offerAmount, 1)
            }

        let periodsInOneBilling = numberOfPeriods(
            unit: offer.period.unit,
            numberOfUnits: offer.period.numberOfUnits,
            in: target
        )
        let totalPeriods = periodsInOneBilling * Double(repeatCount)
        guard totalPeriods > 0 else { return nil }

        return format(effectiveAmount / totalPeriods, currencyCode: offer.price?.currencyCode)
    }
}

#endif
