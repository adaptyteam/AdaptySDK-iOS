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
//        transaction: StoreKit.Transaction
//    ) {
//        self.init(
//            purchaseId: UUID().uuidString,
//            store: "app_store",
//            vendorProductId: transaction.unfProductID,
//            vendorTransactionId: transaction.unfIdentifier,
//            purchasedAt: transaction.purchaseDate,
//            isSandbox: transaction.isSandbox,
//            isRefund: transaction.revocationDate != nil,
//            isConsumable: transaction.productType == .consumable
//        )
//    }
//}
