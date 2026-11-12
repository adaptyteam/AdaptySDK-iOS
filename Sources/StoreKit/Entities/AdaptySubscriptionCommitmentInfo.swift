//
//  AdaptySubscriptionCommitmentInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.09.2026.
//

import Foundation
import StoreKit

public struct AdaptySubscriptionCommitmentInfo: Sendable, Hashable  {
    public let price: Decimal
    public let localizedPrice: String
    public let period: AdaptySubscriptionPeriod
    public let localizedPeriod: String?

    package init(
        price: Decimal,
        localizedPrice: String,
        period: AdaptySubscriptionPeriod,
        priceFormatStyle: Decimal.FormatStyle.Currency,
        periodFormatStyle: Date.ComponentsFormatStyle
    ) {
        self.price = price
        self.localizedPrice = localizedPrice
        self.period = period
        self.localizedPeriod = periodFormatStyle.localized(period: period)
    }
}
