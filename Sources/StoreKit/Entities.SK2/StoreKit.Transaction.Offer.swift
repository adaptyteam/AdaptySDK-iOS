//
//  StoreKit.Transaction.Offer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.11.2025.
//

import StoreKit

@available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
extension StoreKit.Transaction.Offer {
    var subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier? {
        guard let offerType = type.asSubscriptionOfferType else { return nil }
        return .init(offerId: id, offerType: offerType)
    }
}
