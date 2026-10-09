//
//  PurchasedTransactionInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation
import StoreKit

struct PurchasedTransactionInfo: Sendable {
    let transactionId: UInt64
    let originalTransactionId: UInt64
    let vendorProductId: String
    let billingPlan: AdaptySubscriptionBillingPlan?
    let environment: String

    let billingPrice: Decimal?
    let priceCurrencyCode: String?
    let priceRegionCode: String?
    let subscriptionOffer: PurchasedSubscriptionOfferInfo?

    init(
        _ product: StoreKit.Product?,
        _ transaction: StoreKit.Transaction,
    ) {
        transactionId = transaction.id
        originalTransactionId = transaction.originalID
        vendorProductId = transaction.productID
        environment = transaction.unfEnvironment

        let billingPlan = transaction.unfBillingPlan ?? .upFront
        self.billingPlan = billingPlan

        subscriptionOffer = .init(
            billingPlan: billingPlan,
            subscription: product?.subscription,
            transaction: transaction
        )

        guard let product else {
            billingPrice = nil
            priceCurrencyCode = nil
            priceRegionCode = nil
            return
        }

        priceCurrencyCode = product.priceFormatStyle.currencyCode
        priceRegionCode = product.priceFormatStyle.locale.unfRegionCode

        #if compiler(>=6.3.2)
        if #available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *),
           let skPricingTerms = product.subscription?.pricingTerms(for: billingPlan.asSKBillingPlanType) {

            billingPrice = skPricingTerms.billingPrice
            return

        }
        #endif

        billingPrice = billingPlan == .upFront ? product.price : nil
    }
}



