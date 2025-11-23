//
//  AdaptyProfile.Subscription+Create.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

//import StoreKit
//
//extension AdaptyProfile.Subscription {
//    init(
//        transaction: StoreKit.Transaction,
//        sk2Product: StoreKit.Product?,
//        productInfo: BackendProductInfo.Period?,
//        now: Date = Date()
//    ) {
//        let isLifetime = backendPeriod == .lifetime
//
//        self.init(
//            store: "app_store",
//            vendorProductId: transaction.unfProductID,
//            vendorTransactionId: transaction.unfIdentifier,
//            vendorOriginalTransactionId: transaction.unfOriginalIdentifier,
//            isActive: <#T##Bool#>,
//            isLifetime: isLifetime,
//            activatedAt: <#T##Date#>,
//            renewedAt: <#T##Date?#>,
//            expiresAt: <#T##Date?#>,
//            startsAt: nil,
//            unsubscribedAt: <#T##Date?#>,
//            billingIssueDetectedAt: <#T##Date?#>,
//            isInGracePeriod: <#T##Bool#>,
//            isSandbox: transaction.isSandbox,
//            isRefund: <#T##Bool#>,
//            willRenew: <#T##Bool#>,
//            activeIntroductoryOfferType: <#T##String?#>,
//            activePromotionalOfferType: <#T##String?#>,
//            activePromotionalOfferId: <#T##String?#>,
//            offerId: <#T##String?#>,
//            cancellationReason: <#T##String?#>)
//    }
//}
