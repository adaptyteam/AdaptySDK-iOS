//
//  AdaptySubscriptionCommitmentInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.09.2026.
//

import Foundation

public struct AdaptySubscriptionCommitmentInfo: Sendable, Hashable  {
    public let price: Decimal
    public let localizedPrice: String
    public let period: AdaptySubscriptionPeriod

    package init(
        price: Decimal,
        localizedPrice: String,
        period: AdaptySubscriptionPeriod
    ) {
        self.price = price
        self.localizedPrice = localizedPrice
        self.period = period
    }
}
