//
//  AdaptyPaywallProduct+UIBuilder.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.05.2026.
//

import AdaptyUIBuilder
import Foundation

extension [AdaptyPaywallProduct] {
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
                amount: price,
                currencyCode: currencyCode,
                currencySymbol: currencySymbol,
                localizedString: localizedPrice
            ),
            subscription: asUIBuilderFlowProductSubscription()
        )
    }

    func asUIBuilderFlowProductSubscription() -> VC.FlowConstants.ProductSubscriptionConstants? {
        guard let subscriptionGroupIdentifier,
              let subscriptionPeriod
        else { return nil }

        return .init(
            groupIdentifier: subscriptionGroupIdentifier,
            period: .init(
                unit: subscriptionPeriod.unit.encodedValue,
                numberOfUnits: subscriptionPeriod.numberOfUnits
            ),
            localizedPeriod: localizedSubscriptionPeriod,
            offer: subscriptionOffer?.asUIBuilderSubscriptionOffer()
        )
    }
}

private extension AdaptySubscriptionOffer {
    func asUIBuilderSubscriptionOffer() -> VC.FlowConstants.SubscriptionOfferConstants {
        .init(
            id: identifier,
            type: offerType.rawValue,

            price: .init(
                amount: price,
                currencyCode: currencyCode,
                currencySymbol: nil,
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

