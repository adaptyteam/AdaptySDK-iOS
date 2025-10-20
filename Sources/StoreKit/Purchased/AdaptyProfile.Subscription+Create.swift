//
//  AdaptyProfile.Subscription+Create.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

//import StoreKit
//
//@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
//extension AdaptyProfile.Subscription {
//    init(
//        sk2Transaction: SK2Transaction,
//        sk2Product: SK2Product?,
//        productInfo: BackendProductInfo.Period?,
//        now: Date = Date()
//    ) {
//        let isLifetime = backendPeriod == .lifetime
//
//        self.init(
//            store: "app_store",
//            vendorProductId: sk2Transaction.unfProductID,
//            vendorTransactionId: sk2Transaction.unfIdentifier,
//            vendorOriginalTransactionId: sk2Transaction.unfOriginalIdentifier,
//            isActive: <#T##Bool#>,
//            isLifetime: isLifetime,
//            activatedAt: <#T##Date#>,
//            renewedAt: <#T##Date?#>,
//            expiresAt: <#T##Date?#>,
//            startsAt: nil,
//            unsubscribedAt: <#T##Date?#>,
//            billingIssueDetectedAt: <#T##Date?#>,
//            isInGracePeriod: <#T##Bool#>,
//            isSandbox: sk2Transaction.isSandbox,
//            isRefund: <#T##Bool#>,
//            willRenew: <#T##Bool#>,
//            activeIntroductoryOfferType: <#T##String?#>,
//            activePromotionalOfferType: <#T##String?#>,
//            activePromotionalOfferId: <#T##String?#>,
//            offerId: <#T##String?#>,
//            cancellationReason: <#T##String?#>)
//    }
//}
