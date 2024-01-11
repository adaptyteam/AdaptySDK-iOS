//
//  AdaptyPurchasedInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.06.2023
//

import StoreKit

public struct AdaptyPurchasedInfo {
    /// An ``AdaptyProfile`` which contains the up-to-date inforation about the user.
    public let profile: AdaptyProfile

    /// A transaction object, which represents the payment.
    public let transaction: SKPaymentTransaction
}
