//
//  VC.FlowConstants.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.05.2026.
//

import Foundation
import JavaScriptCore

package extension VC {
    struct FlowConstants: Sendable {
        let placementId: String
        let variationId: String
        let abTestName: String
        let name: String
        let products: [ProductConstants]

        package init(
            placementId: String,
            variationId: String,
            abTestName: String,
            name: String,
            products: [ProductConstants]
        ) {
            self.placementId = placementId
            self.variationId = variationId
            self.abTestName = abTestName
            self.name = name
            self.products = products
        }
    }
}

package extension VC.FlowConstants {
    struct ProductConstants: Sendable {
        let values: [String: VC.AnyValue]
        let id: String
        package init(
            flowProductId: String,
            adaptyProductId: String,
            adaptyAccessLevelId: String,
            adaptyProductType: String,
            paywallVariationId: String,
            paywallName: String
        ) {
            id = flowProductId
            values = [
                "flowProductId": VC.AnyValue(flowProductId),
                "adaptyProductId": VC.AnyValue(adaptyProductId),
                "adaptyAccessLevelId": VC.AnyValue(adaptyAccessLevelId),
                "adaptyProductType": VC.AnyValue(adaptyProductType),
                "paywallVariationId": VC.AnyValue(paywallVariationId),
                "paywallName": VC.AnyValue(paywallName),
            ]
        }

        package init(
            flowProductId: String,
            adaptyProductId: String,
            adaptyAccessLevelId: String,
            adaptyProductType: String,
            paywallVariationId: String,
            paywallName: String,
            localizedDescription: String,
            localizedTitle: String,
            isFamilyShareable: Bool,
            regionCode: String?,
            price: PriceConstants,
            subscription: ProductSubscriptionConstants?
        ) {
            id = flowProductId
            values = [
                "flowProductId": VC.AnyValue(flowProductId),
                "adaptyProductId": VC.AnyValue(adaptyProductId),
                "adaptyAccessLevelId": VC.AnyValue(adaptyAccessLevelId),
                "adaptyProductType": VC.AnyValue(adaptyProductType),
                "paywallVariationId": VC.AnyValue(paywallVariationId),
                "paywallName": VC.AnyValue(paywallName),
                // vendors
                "localizedDescription": VC.AnyValue(localizedDescription),
                "localizedTitle": VC.AnyValue(localizedTitle),
                "isFamilyShareable": VC.AnyValue(isFamilyShareable),
                "regionCode": VC.AnyValue(regionCode),
                "price": VC.AnyValue(price.values),
                "subscription": VC.AnyValue(subscription?.values),
            ]
        }
    }

    struct PriceConstants: Sendable {
        let values: [String: VC.AnyValue]
        package init(
            amount: Double,
            currencyCode: String?,
            currencySymbol: String?,
            localizedString: String?
        ) {
            values = [
                "amount": VC.AnyValue(amount),
                "currencyCode": VC.AnyValue(currencyCode),
                "currencySymbol": VC.AnyValue(currencySymbol),
                "localizedString": VC.AnyValue(localizedString),
            ]
        }
    }

    struct ProductSubscriptionConstants: Sendable {
        let values: [String: VC.AnyValue]
        package init(
            groupIdentifier: String,
            period: SubscriptionPeriodConstants,
            localizedPeriod: String?,
            offer: SubscriptionOfferConstants?
        ) {
            values = [
                "groupIdentifier": VC.AnyValue(groupIdentifier),
                "period": VC.AnyValue(period.values),
                "localizedPeriod": VC.AnyValue(localizedPeriod),
                "offer": VC.AnyValue(offer?.values),
            ]
        }
    }

    struct SubscriptionPeriodConstants: Sendable {
        let values: [String: VC.AnyValue]
        package init(
            unit: String,
            numberOfUnits: Int
        ) {
            values = [
                "unit": VC.AnyValue(unit),
                "numberOfUnits": VC.AnyValue(numberOfUnits),
            ]
        }
    }

    struct SubscriptionOfferConstants: Sendable {
        let values: [String: VC.AnyValue]
        package init(
            id: String?,
            type: String,
            price: PriceConstants?,
            paymentMode: String,
            period: SubscriptionPeriodConstants,
            numberOfPeriods: Int,
            localizedPeriod: String?,
            localizedNumberOfPeriods: String?
        ) {
            values = [
                "id": VC.AnyValue(id),
                "type": VC.AnyValue(type),
                "phases": VC.AnyValue([
                    VC.AnyValue([
                        "price": VC.AnyValue(price?.values),
                        "paymentMode": VC.AnyValue(paymentMode),
                        "period": VC.AnyValue(period.values),
                        "numberOfPeriods": VC.AnyValue(numberOfPeriods),
                        "localizedPeriod": VC.AnyValue(localizedPeriod),
                        "localizedNumberOfPeriods": VC.AnyValue(localizedNumberOfPeriods),
                    ]),
                ]),
            ]
        }
    }
}

