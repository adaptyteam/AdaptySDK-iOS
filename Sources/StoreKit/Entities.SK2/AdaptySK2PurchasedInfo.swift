//
//  AdaptySK2PurchasedInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.09.2024
//
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct AdaptySK2PurchasedInfo: AdaptyPurchasedInfo {
    let profile: AdaptyProfile

    let transaction: SK2Transaction

    var sk1Transaction: SK1Transaction? { nil }

    var sk2Transaction: SK2Transaction? { transaction }

    init(profile: AdaptyProfile, sk2Transaction: SK2Transaction) {
        self.profile = profile
        self.transaction = sk2Transaction
    }
}
