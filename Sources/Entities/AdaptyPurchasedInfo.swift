//
//  AdaptyPurchasedInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 12.06.2023
//

import StoreKit

public struct AdaptyPurchasedInfo {
    public let profile: AdaptyProfile
    public let transaction: SKPaymentTransaction
}
