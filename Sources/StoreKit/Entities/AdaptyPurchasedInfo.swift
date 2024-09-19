//
//  AdaptyPurchasedInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.06.2023
//

import StoreKit

public protocol AdaptyPurchasedInfo: Sendable {
    /// An ``AdaptyProfile`` which contains the up-to-date inforation about the user.
    var profile: AdaptyProfile { get }

    /// A transaction object, which represents the payment.
    var sk1Transaction: SKPaymentTransaction? { get }

    /// A transaction object, which represents the payment.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    var sk2Transaction: Transaction? { get }
}
