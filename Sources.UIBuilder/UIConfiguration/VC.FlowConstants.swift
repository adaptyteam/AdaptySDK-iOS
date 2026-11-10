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
        let value: VC.Value
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
            value = .compact([
                "flowProductId": VC.Value(flowProductId),
                "adaptyProductId": VC.Value(adaptyProductId),
                "adaptyAccessLevelId": VC.Value(adaptyAccessLevelId),
                "adaptyProductType": VC.Value(adaptyProductType),
                "paywallVariationId": VC.Value(paywallVariationId),
                "paywallName": VC.Value(paywallName),
            ])
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
            value = .compact([
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
                "regionCode": regionCode.map(VC.Value.init),
                "price": price.value,
                "subscription": subscription?.value,
            ])
        }
    }

    struct PriceConstants: Sendable {
        let value: VC.Value

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
            value = .compact([
                "amount": VC.Value(amount),
                "currencyCode": VC.Value(currencyCode),
                "currencySymbol": currencySymbol.map(VC.Value.init),
                "localizedString": VC.Value(localizedString),
            ])
        }
    }

    struct ProductSubscriptionConstants: Sendable {
        let value: VC.Value
        package init(
            groupIdentifier: String,
            period: SubscriptionPeriodConstants,
            localizedPeriod: String?,
            pricingTerms: SubscriptionPricingTermsConstants,
            offer: SubscriptionOfferConstants?
        ) {
            value = .compact([
                "groupIdentifier": VC.Value(groupIdentifier),
                "period": period.value,
                "localizedPeriod": localizedPeriod.map(VC.Value.init),
                "pricingTerms": pricingTerms.value,
                "offer": offer?.value,
            ])
        }
    }

    struct SubscriptionPricingTermsConstants: Sendable {
        let value: VC.Value
        package init(
            billingPlanId: String,
            billingPrice: PriceConstants,
            billingPeriod: SubscriptionPeriodConstants,
            commitmentInfo: SubscriptionCommitmentInfoConstants
        ) {
            value = .compact([
                "billingPlanId": VC.Value(billingPlanId),
                "billingPrice": billingPrice.value,
                "billingPeriod": billingPeriod.value,
                "commitmentInfo": commitmentInfo.value,
            ])
        }
    }

    struct SubscriptionCommitmentInfoConstants: Sendable {
        let value: VC.Value
        package init(
            price: PriceConstants,
            period: SubscriptionPeriodConstants
        ) {
            value = .compact([
                "price": price.value,
                "period": period.value,
            ])
        }
    }

    struct SubscriptionPeriodConstants: Sendable {
        let value: VC.Value
        package init(
            unit: String,
            numberOfUnits: Int
        ) {
            value = .compact([
                "unit": VC.Value(unit),
                "numberOfUnits": VC.Value(numberOfUnits),
            ])
        }
    }

    struct SubscriptionOfferConstants: Sendable {
        let value: VC.Value
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
            value = .compact([
                "id": VC.Value(id),
                "type": VC.Value(type),
                "phases": VC.Value([
                    VC.Value.compact([
                        "price": price?.value,
                        "paymentMode": VC.Value(paymentMode),
                        "period": period.value,
                        "numberOfPeriods": VC.Value(numberOfPeriods),
                        "localizedPeriod": localizedPeriod.map(VC.Value.init),
                        "localizedNumberOfPeriods": localizedNumberOfPeriods.map(VC.Value.init),
                    ]),
                ]),
            ])
        }
    }
}


private extension VC.Value {
    static func compact(_ object: [String: VC.Value?]) -> VC.Value {

        let compacted: [String: VC.Value] = object.compactMapValues { value in
            guard let value, !value.isNil else { return nil }
            return value
        }
        return VC.Value(compacted)
    }
}
