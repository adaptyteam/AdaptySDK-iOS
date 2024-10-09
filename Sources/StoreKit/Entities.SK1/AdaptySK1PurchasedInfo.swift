//
//  AdaptySK1PurchasedInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

struct AdaptySK1PurchasedInfo: AdaptyPurchasedInfo {
    let profile: AdaptyProfile

    let transaction: SK1Transaction

    var sk1Transaction: SK1Transaction? { transaction }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var sk2Transaction: SK2Transaction? { nil }
    
    init(profile: AdaptyProfile, sk1Transaction: SK1Transaction) {
        self.profile = profile
        self.transaction = sk1Transaction
    }
    
    init(profile: AdaptyProfile, sk1Transaction: SK1TransactionWithIdentifier) {
        self.profile = profile
        self.transaction = sk1Transaction.underlay
    }
}
