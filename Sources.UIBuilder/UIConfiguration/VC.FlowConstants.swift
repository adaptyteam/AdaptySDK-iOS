//
//  VC.FlowConstants.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.05.2026.
//

import Foundation

package extension VC {
    struct FlowConstants: Sendable {
        let placementId: String
        let variationId: String
        let placementABTestName: String
        let name: String
        let products: [String: ProductConstants]

        package init(
            placementId: String,
            variationId: String,
            placementABTestName: String,
            name: String,
            products: [ProductConstants]
        ) {
            self.placementId = placementId
            self.variationId = variationId
            self.placementABTestName = placementABTestName
            self.name = name
            self.products = Dictionary(products.map { ($0.flowProductId, $0) }, uniquingKeysWith: { first, _ in first })
        }
    }
}

package extension VC.FlowConstants {
    struct ProductConstants: Sendable {
        let flowProductId: String
        let adaptyProductId: String
        let adaptyAccessLevelId: String
        let adaptyProductType: String
        let paywallVariationId: String
        let paywallName: String
        // vendors
        let localizedDescription: String?
        let localizedTitle: String?
        let isFamilyShareable: Bool?
        let regionCode: String?
        let price: PriceConstants?
        let subscription: ProductSubscriptionConstants?

        package init(
            flowProductId: String,
            adaptyProductId: String,
            adaptyAccessLevelId: String,
            adaptyProductType: String,
            paywallVariationId: String,
            paywallName: String,
            localizedDescription: String? = nil,
            localizedTitle: String? = nil,
            isFamilyShareable: Bool? = nil,
            regionCode: String? = nil,
            price: PriceConstants? = nil,
            subscription: ProductSubscriptionConstants? = nil
        ) {
            self.flowProductId = flowProductId
            self.adaptyProductId = adaptyProductId
            self.adaptyAccessLevelId = adaptyAccessLevelId
            self.adaptyProductType = adaptyProductType
            self.paywallVariationId = paywallVariationId
            self.paywallName = paywallName
            self.localizedDescription = localizedDescription
            self.localizedTitle = localizedTitle
            self.isFamilyShareable = isFamilyShareable
            self.regionCode = regionCode
            self.price = price
            self.subscription = subscription
        }
    }

    struct PriceConstants: Sendable {
        let amount: Decimal
        let currencyCode: String?
        let currencySymbol: String?
        let localizedString: String?

        package init(
            amount: Decimal,
            currencyCode: String?,
            currencySymbol: String?,
            localizedString: String?
        ) {
            self.amount = amount
            self.currencyCode = currencyCode
            self.currencySymbol = currencySymbol
            self.localizedString = localizedString
        }
    }

    struct ProductSubscriptionConstants: Sendable {
        let groupIdentifier: String
        let period: SubscriptionPeriodConstants
        let localizedPeriod: String?
        let offer: SubscriptionOfferConstants?

        package init(
            groupIdentifier: String,
            period: SubscriptionPeriodConstants,
            localizedPeriod: String?,
            offer: SubscriptionOfferConstants?
        ) {
            self.groupIdentifier = groupIdentifier
            self.period = period
            self.localizedPeriod = localizedPeriod
            self.offer = offer
        }
    }

    struct SubscriptionPeriodConstants: Sendable {
        let unit: String
        let numberOfUnits: Int

        package init(
            unit: String,
            numberOfUnits: Int
        ) {
            self.unit = unit
            self.numberOfUnits = numberOfUnits
        }
    }

    struct SubscriptionOfferConstants: Sendable {
        let id: String?
        let type: String
        // phase
        let price: PriceConstants?
        let paymentMode: String
        let period: SubscriptionPeriodConstants
        let numberOfPeriods: Int
        let localizedPeriod: String?
        let localizedNumberOfPeriods: String?

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
            self.id = id
            self.type = type
            self.price = price
            self.paymentMode = paymentMode
            self.period = period
            self.numberOfPeriods = numberOfPeriods
            self.localizedPeriod = localizedPeriod
            self.localizedNumberOfPeriods = localizedNumberOfPeriods
        }
    }
}

