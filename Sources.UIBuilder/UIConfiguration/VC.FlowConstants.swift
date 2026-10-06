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
        let variationName: String?
        let abTestName: String
        let name: String
        let products: [ProductConstants]

        package init(
            placementId: String,
            variationId: String,
            variationName: String?,
            abTestName: String,
            name: String,
            products: [ProductConstants]
        ) {
            self.placementId = placementId
            self.variationId = variationId
            self.variationName = variationName
            self.abTestName = abTestName
            self.name = name
            self.products = products
        }
    }
}

package extension VC.FlowConstants {
    struct ProductConstants: Sendable {
        let values: [String: VC.Value]
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
                "flowProductId": VC.Value(flowProductId),
                "adaptyProductId": VC.Value(adaptyProductId),
                "adaptyAccessLevelId": VC.Value(adaptyAccessLevelId),
                "adaptyProductType": VC.Value(adaptyProductType),
                "paywallVariationId": VC.Value(paywallVariationId),
                "paywallName": VC.Value(paywallName),
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
                "flowProductId": VC.Value(flowProductId),
                "adaptyProductId": VC.Value(adaptyProductId),
                "adaptyAccessLevelId": VC.Value(adaptyAccessLevelId),
                "adaptyProductType": VC.Value(adaptyProductType),
                "paywallVariationId": VC.Value(paywallVariationId),
                "paywallName": VC.Value(paywallName),
                // vendors
                "localizedDescription": VC.Value(localizedDescription),
                "localizedTitle": VC.Value(localizedTitle),
                "isFamilyShareable": VC.Value(isFamilyShareable),
                "regionCode": VC.Value(regionCode),
                "price": VC.Value(price.values),
                "subscription": VC.Value(subscription?.values),
            ]
        }
    }

    struct PriceConstants: Sendable {
        let values: [String: VC.Value]

        package init(
            amount: Double,
            priceFormatStyle: Decimal.FormatStyle.Currency,
            localizedString: String
        ) {
            self.init(
                amount: amount,
                currencyCode: priceFormatStyle.currencyCode,
                currencySymbol: priceFormatStyle.locale.currencySymbol,
                localizedString: localizedString
            )
        }

        package init(
            amount: Double,
            currencyCode: String,
            currencySymbol: String?,
            localizedString: String
        ) {
            values = [
                "amount": VC.Value(amount),
                "currencyCode": VC.Value(currencyCode),
                "currencySymbol": VC.Value(currencySymbol),
                "localizedString": VC.Value(localizedString),
            ]
        }
    }

    struct ProductSubscriptionConstants: Sendable {
        let values: [String: VC.Value]
        package init(
            groupIdentifier: String,
            period: SubscriptionPeriodConstants,
            localizedPeriod: String?,
            pricingTerms: SubscriptionPricingTermsConstants,
            offer: SubscriptionOfferConstants?
        ) {
            values = [
                "groupIdentifier": VC.Value(groupIdentifier),
                "period": VC.Value(period.values),
                "localizedPeriod": VC.Value(localizedPeriod),
                "pricingTerms": VC.Value(pricingTerms.values),
                "offer": VC.Value(offer?.values),
            ]
        }
    }

    struct SubscriptionPricingTermsConstants: Sendable {
        let values: [String: VC.Value]
        package init(
            billingPlanId: String,
            billingPrice: PriceConstants,
            billingPeriod: SubscriptionPeriodConstants,
            commitmentInfo: SubscriptionCommitmentInfoConstants
        ) {
            values = [
                "billingPlanId": VC.Value(billingPlanId),
                "billingPrice": VC.Value(billingPrice.values),
                "billingPeriod": VC.Value(billingPeriod.values),
                "commitmentInfo": VC.Value(commitmentInfo.values),
            ]
        }
    }

    struct SubscriptionCommitmentInfoConstants: Sendable {
        let values: [String: VC.Value]
        package init(price: PriceConstants, period: SubscriptionPeriodConstants) {
            values = [
                "price": VC.Value(price.values),
                "period": VC.Value(period.values),
            ]
        }
    }

    struct SubscriptionPeriodConstants: Sendable {
        let values: [String: VC.Value]
        package init(
            unit: String,
            numberOfUnits: Int
        ) {
            values = [
                "unit": VC.Value(unit),
                "numberOfUnits": VC.Value(numberOfUnits),
            ]
        }
    }

    struct SubscriptionOfferConstants: Sendable {
        let values: [String: VC.Value]
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
                "id": VC.Value(id),
                "type": VC.Value(type),
                "phases": VC.Value([
                    VC.Value([
                        "price": VC.Value(price?.values),
                        "paymentMode": VC.Value(paymentMode),
                        "period": VC.Value(period.values),
                        "numberOfPeriods": VC.Value(numberOfPeriods),
                        "localizedPeriod": VC.Value(localizedPeriod),
                        "localizedNumberOfPeriods": VC.Value(localizedNumberOfPeriods),
                    ]),
                ]),
            ]
        }
    }
}
