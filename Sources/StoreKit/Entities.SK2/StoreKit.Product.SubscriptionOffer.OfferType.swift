//
//  StoreKit.Product.SubscriptionOffer.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.11.2025.
//

import StoreKit

extension StoreKit.Product.SubscriptionOffer.OfferType {
    var asSubscriptionOfferType: AdaptySubscriptionOfferType? {
        switch self {
        case .introductory: .introductory
        case .promotional: .promotional
        default:
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *),
               self == .winBack
            {
                .winBack
            } else {
                nil
            }
        }
    }
}
