//
//  StoreKit.Product.SubscriptionInfo.CommitmentInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 28.09.2026.
//

import StoreKit

#if compiler(>=6.3.2)

@available(iOS 26.4, macOS 26.4, tvOS 26.4, watchOS 26.4, visionOS 26.4, *)
extension StoreKit.Product.SubscriptionInfo.CommitmentInfo {
    var asAdaptySubscriptionCommitmentInfo: AdaptySubscriptionCommitmentInfo {
        .init(
            price: price,
            localizedPrice: displayPrice,
            period: period.asAdaptySubscriptionPeriod
        )
    }
}
#endif
