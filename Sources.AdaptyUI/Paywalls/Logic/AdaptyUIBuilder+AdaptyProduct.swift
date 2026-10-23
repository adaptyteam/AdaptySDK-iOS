//
//  AdaptyUIBuilder+AdaptyProduct.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

#if canImport(UIKit)

import Adapty
import AdaptyUIBuilder
import Foundation

extension AdaptyPaywallProduct: ProductResolver {
    public var flowId: String { flowProductId ?? adaptyProductId }

    public var billingPlan: BillingPlanId? {
        guard skProduct.subscription != nil else { return nil }
        let billingPlan = subscriptionPricingTerms?.billingPlan ?? .upFront
        return billingPlan.rawValue
    }

    public var paymentMode: PaymentModeId? {
        subscriptionOffer?.paymentMode.encodedValue
    }

    private func isApplicableForTag(_ tag: TextProductTag) -> Bool {
        switch tag {
        case .title, .description, .price, .priceAmount, .priceAmountInteger,
             .billingPrice, .billingPriceAmount, .billingPriceAmountInteger,
             .currencyCode, .currencySymbol:
            true
        case .priceAmountFraction, .billingPriceAmountFraction:
            maximumFractionDigits(for: priceLocale) > 0
        case .pricePerDay, .pricePerWeek, .pricePerMonth, .pricePerYear,
             .subscriptionPeriod, .subscriptionBillingPeriod:
            subscriptionPeriod != nil
        case .offerPrice, .offerPeriods, .offerNumberOfPeriods,
             .offerPricePerDay, .offerPricePerWeek, .offerPricePerMonth, .offerPricePerYear:
            subscriptionOffer != nil
        }
    }

    public func value(byTag tag: TextProductTag) -> TextTagValue? {
        guard isApplicableForTag(tag) else { return .notApplicable }

        let result: String? =
            switch tag {
            case .title:
                localizedTitle
            case .description:
                localizedDescription
            case .price:
                localizedPrice
            case .priceAmount:
                priceAmount(price, for: priceLocale)
            case .priceAmountInteger:
                priceAmountInteger(price, for: priceLocale)
            case .priceAmountFraction:
                priceAmountFraction(price, for: priceLocale)
            case .billingPrice:
                subscriptionPricingTerms?.localizedBillingPrice ?? localizedPrice
            case .billingPriceAmount:
                priceAmount(billingPrice, for: priceLocale)
            case .billingPriceAmountInteger:
                priceAmountInteger(billingPrice, for: priceLocale)
            case .billingPriceAmountFraction:
                priceAmountFraction(billingPrice, for: priceLocale)
            case .currencyCode:
                currencyCode
            case .currencySymbol:
                currencySymbol
            case .pricePerDay:
                pricePer(period: .day)
            case .pricePerWeek:
                pricePer(period: .week)
            case .pricePerMonth:
                pricePer(period: .month)
            case .pricePerYear:
                pricePer(period: .year)
            case .subscriptionPeriod:
                localizedSubscriptionPeriod
            case .subscriptionBillingPeriod:
                localizedBillingPeriod ?? localizedSubscriptionPeriod
            case .offerPrice:
                subscriptionOffer?.localizedPrice
            case .offerPeriods:
                subscriptionOffer?.localizedSubscriptionPeriod
            case .offerNumberOfPeriods:
                subscriptionOffer?.localizedNumberOfPeriods
            case .offerPricePerDay:
                offerPricePer(period: .day)
            case .offerPricePerWeek:
                offerPricePer(period: .week)
            case .offerPricePerMonth:
                offerPricePer(period: .month)
            case .offerPricePerYear:
                offerPricePer(period: .year)
            }

        if let result {
            return .value(result)
        } else {
            return nil
        }
    }

    func offerPricePer(period unit: AdaptySubscriptionPeriod.Unit) -> String? {
        guard let offer = subscriptionOffer else { return nil }

        let (effectivePrice, repeatCount): (Decimal, Int) =
            switch offer.paymentMode {
            case .payAsYouGo, .unknown:
                (offer.price, 1)
            case .payUpFront:
                (offer.price, offer.numberOfPeriods)
            case .freeTrial:
                (0, 1)
            }

        return formatPrice(
            effectivePrice,
            perTargetUnit: unit,
            billingPeriod: offer.subscriptionPeriod,
            repeatCount: repeatCount
        )
    }
}

extension AdaptyFlow {
    /// Whether `products` are exactly the products of this flow: one per
    /// product of every paywall, with nothing foreign or duplicated.
    func matches(products: [AdaptyPaywallProduct]) -> Bool {
        let expected = paywalls.flatMap { paywall in
            paywall.vendorProductIds.enumerated().map { [paywall.variationId, String($0.offset), $0.element] }
        }
        let provided = products.map { [$0.variationId, String($0.paywallProductIndex), $0.vendorProductId] }
        let providedSet = Set(provided)
        return providedSet.count == provided.count && providedSet == Set(expected)
    }
}

extension AdaptyProduct {
    /// Shared math behind `PRICE_PER_*` and `OFFER_PRICE_PER_*`.
    /// Contract: `price` is the total paid for `billingPeriod` repeated `repeatCount` times.
    /// Returns that total normalized to a single `targetUnit`, formatted in the storefront currency.
    func formatPrice(
        _ price: Decimal,
        perTargetUnit targetUnit: AdaptySubscriptionPeriod.Unit,
        billingPeriod: AdaptySubscriptionPeriod,
        repeatCount: Int = 1
    ) -> String? {
        let durationInTargetUnit = billingPeriod.numberOfPeriods(targetUnit) * Double(repeatCount)
        guard durationInTargetUnit > 0 else { return nil }

        let pricePerPeriod = price / Decimal(floatLiteral: durationInTargetUnit)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceFormatStyle.locale

        return formatter.string(from: NSDecimalNumber(decimal: pricePerPeriod))
    }

    /// Price of a single payment of the selected billing plan; the product price when there are no pricing terms.
    var billingPrice: Decimal {
        subscriptionPricingTerms?.billingPrice ?? price
    }

    func pricePer(period unit: AdaptySubscriptionPeriod.Unit) -> String? {
        guard let subscriptionPeriod else { return nil }
        return formatPrice(price, perTargetUnit: unit, billingPeriod: subscriptionPeriod)
    }

    func priceAmount(_ price: Decimal, for locale: Locale) -> String? {
        let digits = maximumFractionDigits(for: locale)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        return formatter.string(from: NSDecimalNumber(decimal: price))
    }

    func priceAmountInteger(_ price: Decimal, for locale: Locale) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.maximumFractionDigits = 0
        formatter.roundingMode = .down
        return formatter.string(from: NSDecimalNumber(decimal: price))
    }

    func priceAmountFraction(_ price: Decimal, for locale: Locale) -> String? {
        let fractionDigits = maximumFractionDigits(for: locale)
        guard fractionDigits > 0 else { return nil }

        let multiplier = pow(Decimal(10), fractionDigits)
        var rounded = Decimal()
        var unrounded = price * multiplier
        NSDecimalRound(&rounded, &unrounded, 0, .plain)

        let scaledInteger = NSDecimalNumber(decimal: rounded).int64Value
        let modulus = NSDecimalNumber(decimal: multiplier).int64Value
        let fraction = abs(scaledInteger) % modulus

        return String(format: "%0\(fractionDigits)lld", fraction)
    }

    func maximumFractionDigits(for locale: Locale) -> Int {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.maximumFractionDigits
    }
}

#endif

