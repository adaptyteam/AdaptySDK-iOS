//
//  AdaptyProfile.NonSubscription+Create.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.08.2025.
//

//import StoreKit
//
//extension AdaptyProfile.NonSubscription {
//    init(
//        sk2Transaction: SK2Transaction
//    ) {
//        self.init(
//            purchaseId: UUID().uuidString,
//            store: "app_store",
//            vendorProductId: sk2Transaction.unfProductID,
//            vendorTransactionId: sk2Transaction.unfIdentifier,
//            purchasedAt: sk2Transaction.purchaseDate,
//            isSandbox: sk2Transaction.isSandbox,
//            isRefund: sk2Transaction.revocationDate != nil,
//            isConsumable: sk2Transaction.productType == .consumable
//        )
//    }
//}
