//
//  AdaptyPaywallProduct+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.05.2026.
//

import AdaptyUIBuilder
import Foundation

package extension [AdaptyPaywallProduct] {
    func asUIBuilderFlowProducts() -> [VC.FlowConstants.ProductConstants] {
        compactMap { $0.asUIBuilderFlowProduct() }
    }
}

private extension AdaptyPaywallProduct {
    func asUIBuilderFlowProduct() -> VC.FlowConstants.ProductConstants? {
        guard let flowProductId else { return nil }

        return VC.FlowConstants.ProductConstants(
            flowProductId: flowProductId,
            adaptyProductId: adaptyProductId,
            adaptyAccessLevelId: productInfo.accessLevelId,
            adaptyProductType: productInfo.period.rawValue,
            paywallVariationId: variationId,
            paywallName: paywallName,
            localizedDescription: localizedDescription,
            localizedTitle: localizedTitle,
            isFamilyShareable: isFamilyShareable,
            regionCode: regionCode,
            price: .init(
                amount: NSDecimalNumber(decimal: price).doubleValue,
                priceFormatStyle: skProduct.priceFormatStyle,
                localizedString: localizedPrice
            ),
            subscription: asUIBuilderFlowProductSubscription()
        )
    }

    func asUIBuilderFlowProductSubscription() -> VC.FlowConstants.ProductSubscriptionConstants? {
        guard let subscriptionGroupIdentifier,
              let subscriptionPeriod,
              let subscriptionPricingTerms
        else { return nil }

        let priceFormatStyle = skProduct.priceFormatStyle
        return .init(
            groupIdentifier: subscriptionGroupIdentifier,
            period: .init(
                unit: subscriptionPeriod.unit.encodedValue,
                numberOfUnits: subscriptionPeriod.numberOfUnits
            ),
            localizedPeriod: localizedSubscriptionPeriod,
            pricingTerms: subscriptionPricingTerms.asUIBuilderPricingTerms(
                priceFormatStyle: priceFormatStyle
            ),
            offer: subscriptionOffer?.asUIBuilderSubscriptionOffer(
                priceFormatStyle: priceFormatStyle
            )
        )
    }
}

extension AdaptySubscriptionPricingTerms {
    func asUIBuilderPricingTerms(
        priceFormatStyle: Decimal.FormatStyle.Currency
    ) -> VC.FlowConstants.SubscriptionPricingTermsConstants {
        .init(
            billingPlanId: billingPlan.rawValue,
            billingPrice: .init(
                amount: NSDecimalNumber(decimal: billingPrice).doubleValue,
                priceFormatStyle: priceFormatStyle,
                localizedString: localizedBillingPrice
            ),
            billingPeriod: .init(
                unit: billingPeriod.unit.encodedValue,
                numberOfUnits: billingPeriod.numberOfUnits
            ),
            commitmentInfo: .init(
                price: .init(
                    amount: NSDecimalNumber(decimal: commitmentInfo.price).doubleValue,
                    priceFormatStyle: priceFormatStyle,
                    localizedString: commitmentInfo.localizedPrice
                ),
                period: .init(
                    unit: commitmentInfo.period.unit.encodedValue,
                    numberOfUnits: commitmentInfo.period.numberOfUnits
                )
            )
        )
    }
}

private extension AdaptySubscriptionOffer {
    func asUIBuilderSubscriptionOffer(
        priceFormatStyle: Decimal.FormatStyle.Currency
    ) -> VC.FlowConstants.SubscriptionOfferConstants {
        .init(
            id: identifier,
            type: offerType.rawValue,
            price: .init(
                amount: NSDecimalNumber(decimal: price).doubleValue,
                priceFormatStyle: priceFormatStyle,
                localizedString: localizedPrice
            ),
            paymentMode: paymentMode.encodedValue ?? "unknown",
            period: .init(
                unit: subscriptionPeriod.unit.encodedValue,
                numberOfUnits: subscriptionPeriod.numberOfUnits
            ),
            numberOfPeriods: numberOfPeriods,
            localizedPeriod: localizedSubscriptionPeriod,
            localizedNumberOfPeriods: localizedNumberOfPeriods
        )
    }
}
